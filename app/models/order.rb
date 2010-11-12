class Order < ActiveRecord::Base

  has_many :line_items, :dependent => :destroy
  has_many :products, :through => :line_items

  has_many :order_transactions, :dependent => :destroy
  has_many :paypal_transactions, :dependent => :destroy
  has_many :paypal_notifications, :dependent => :destroy
  has_many :braintree_transactions, :dependent => :destroy

  belongs_to :billing_address, :class_name => 'Address'
  belongs_to :shipping_address, :class_name => 'Address'
  belongs_to :user

  before_create :init_order

  state_machine :state, :initial => :shopping do
    event :freeze do
      transition :shopping => :frozen
      transition :frozen => :frozen
    end

    event :prepare do
      transition :frozen => :prepared
    end

    event :wait_for_review do
      transition :prepared => :pending
    end

    event :cancel do
      transition :completed => :frozen
    end

    event :approve do
      transition :completed => :approved
      transition :frozen => :approved
    end

    event :complete do
      transition :prepared => :completed
    end

    event :decline do
      transition :frozen => :declined
      transition :prepared => :declined
    end

    event :authorize do
      transition :prepared => :authorized
    end

    event :refund do
      transition :authorized => :authorized
      transition :approved => :approved
    end

    event :capture do
      transition :authorized => :authorized
    end

    event :void do
      transition :authorized => :authorized
    end

    event :retry do
      transition :declined => :frozen
    end

    event :ship do
      transition :authorized => :shipped
      transition :approved => :shipped
    end

  end

=begin
  #
  # AASM section.
  #

  include AASM
  # XXX This is a hack.  In the AASM gem, I commented out the following line:
  #
  # base.respond_to?(:before_validation_on_create) ?
  #  base.before_validation_on_create(:aasm_ensure_initial_state) :
  #  base.before_validation(:aasm_ensure_initial_state, :on => :create)
  #
  # This line should have worked.  Instead Rails still gives a method_missing exception on 
  # before_validation_on_create.  So instead, we do the before validation call here.  FIXME.
  before_validation(:aasm_ensure_initial_state, :on => :create)

  aasm_initial_state :initial => :shopping
  aasm_column :state

  aasm_state :shopping   # the order is acting as a shopping cart.
  aasm_state :frozen     # no more items can be added or removed from the cart.
  aasm_state :prepared   # we have a token for the transaction
  aasm_state :declined   # last transaction has been declined.
  aasm_state :authorized # payment has been authorized, but not captured.
  aasm_state :completed  # waiting for PayPal "Instant Payment Notification"
  aasm_state :approved   # payment has been approved.
  aasm_state :pending    # pending review
  aasm_state :ipnwaiting # not OK to ship unless we receive IPN (PayPal Standard Only?)
  aasm_state :shipped    # order has been shipped.

  aasm_event :freeze do
    transitions :from => :shopping, :to => :frozen
    transitions :from => :frozen, :to => :frozen
  end

  aasm_event :prepare do
    transitions :from => :frozen, :to => :prepared
  end

  aasm_event :wait_for_review do
    transitions :from => :prepared, :to => :pending
  end

  aasm_event :cancel do
    transitions :from => :completed, :to => :frozen
  end

  aasm_event :approve do
    transitions :from => :completed, :to => :approved
    transitions :from => :frozen, :to => :approved
  end

  aasm_event :complete do
    transitions :from => :prepared, :to => :completed
  end

  aasm_event :decline do
    transitions :from => :frozen, :to => :declined
    transitions :from => :prepared, :to => :declined
  end

  aasm_event :authorize do
    transitions :from => :prepared, :to => :authorized
  end

  aasm_event :refund do
    transitions :from => :authorized, :to => :authorized
    transitions :from => :approved, :to => :approved
  end

  aasm_event :capture do
    transitions :from => :authorized, :to => :authorized
  end

  aasm_event :void do
    transitions :from => :authorized, :to => :authorized
  end

  aasm_event :retry do
    transitions :from => :declined, :to => :frozen
  end

  aasm_event :ship do
    transitions :from => :authorized, :to => :shipped
    transitions :from => :approved, :to => :shipped
  end
   
  # end AASM
=end

  def create_or_update_shipping_address(user, attrs)
    attrs[:address_type] = 'shipping'
    address = self.shipping_address
    if address
      address.update_attributes(attrs)
    else
      address = self.create_shipping_address(attrs)
      save! # Needed to persist the 'shipping_address_id' in the order.
    end

    # Try to update the shipping address associated with the
    # user.  It is not a problem if this fails.
    if user && address.valid?
      if user.shipping_address
        user.shipping_address.update_attributes(attrs)
      else
        user.create_shipping_address(attrs)
      end
    end
    address
  end

  def create_or_update_billing_address(user, attrs)
    address = self.billing_address
    attrs[:address_type] = 'billing'
    if address
      address.update_attributes(attrs)
    else
      address = self.create_billing_address(attrs)
      save! # Needed to persist the 'billing_address_id' in the order.
    end
    # Try to update the billing address associated with the
    # user.  It is not a problem if this fails.
    if user && address.valid?
      if user.billing_address
        user.billing_address.update_attributes(attrs)
      else
        user.create_billing_address(attrs)
      end
    end
    address
  end

  def number
      SecureRandom.hex(16)
  end

  def subtotal
    # convert to array so it doesn't try to do sum on database directly
    line_items.to_a.sum(&:full_price)
  end

  def sales_tax
    self.subtotal * 0.08 # CA only XXX
  end

  def total_without_shipping
    subtotal + sales_tax
  end

  def estimated_total
    subtotal + sales_tax + ((c = shipping_cost) ? c : 0)
  end

  def price_in_cents
    # Do conversion here if currency is not USD. Gross total may be
    # zero when this is called...
    estimated_total
  end

  # Return the the maximum amount (in cents) that is possible to capture.
  # If previous captures have been done, then they must be subtracted from
  # this amount to get the remaining amount that can be captured.
  def paypal_capture_limit
    if self.amount_authorized.nil?
      0
    else
      [(amount_authorized * 1.15).floor, amount_authorized + 7500, 1000000].min
    end
  end

  def capture(params, logger)
    final = params[:final_capture] == "yes"
    if params[:capture_type] == "partial"
      cents = MoneyUtils.parse(params[:capture_amount])
    else
      cents = self.amount_authorized - self.total_captured
    end
    response = PaypalTransaction.capture(self, final, cents)
    if response.success?
      attrs = { 
        :total_captured => total_captured + response.amount,
        :transaction_fee => transaction_fee + response.transaction_fee,
        :sales_tax  => sales_tax + response.sales_tax,
      }
      if final
        attrs[:status] = "Complete"
      end
      update_attributes(attrs)
    end
    response
  end

  def void(params, logger)
    response = PaypalTransaction.void(self)
    if response.success?
      update_attribute(:status, "Complete")
    end
    response
  end

  def cancel
    false
  end

  # Callback from the PayPal gem.
  def notify(order_attrs, address_attrs, misc_attrs)

    # Note params[:gross_total] is what the customer actually paid.  params[:gross_total]
    # minus params[:transaction_fee] is what was actually deposited to the merchant's
    # account.
    consistent = (currency_code == order_attrs[:currency_code] &&
      gross_total + order_attrs[:sales_tax] + order_attrs[:shipping_cost] + 
        order_attrs[:handling_cost] + order_attrs[:transaction_fee] == 
        order_attrs[:gross_total]
      order_attrs[:payment_status] == "Completed" &&
      APP_CONFIG[:paypal_receiver_email] == misc_attrs[:receiver_email])

    raise "IPN not consistent" unless consistent

    # Always use the shipping address from PayPal.
    create_or_update_shipping_address(user, address_attrs)    

    # If this is PayPal Standard, then the cart is in the "shopping" state.
    # We can't transition directly from "shopping" to "approved".
    if misc_attrs[:txn_type] == "cart"
      freeze! 

      # Update some attributes of the order, based on the IPN data.

      update_attributes(order_attrs)
    end
    approve!
  end

  private
  
  def init_order
    # This is temporary.  We should create a sequence in the database.  TODO.
    rng = Random.new
    self.invoice_number = rng.rand(10**11..10**12 - 1)
    self.currency_code = "USD" # default value

    # XXX the following initializations should not be done.  We should leave
    # these values nil to indicate "unknown".
    self.transaction_fee = 0
    self.gross_total = 0
    self.sales_tax = 0
    self.handling_cost = 0
    self.shipping_cost = 0
  end

end
