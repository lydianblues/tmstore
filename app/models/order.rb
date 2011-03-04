class Order < ActiveRecord::Base
  
  has_many :line_items, :dependent => :destroy
  has_many :products, :through => :line_items
  has_many :paypal_notifications, :dependent => :destroy
  has_many :paypal_transactions, :dependent => :destroy
  
  belongs_to :billing_address, :class_name => "Address"
  belongs_to :shipping_address, :class_name => "Address"
  belongs_to :user

  include Paypal::Encryption
  include Paypal::Options
  include Paypal::StateMachine
  include Paypal::OrderUtils
  
  before_create :init_order
  
  has_many :order_transactions, :dependent => :destroy
  has_many :braintree_transactions, :dependent => :destroy
 
  # Begin methods from Paypal Gem.  
  def subtotal
    subtotal = 0
    line_items.each do |item|
      subtotal += item.unit_price * item.quantity
    end
    subtotal
  end

  def total
    amt = subtotal
    amt += shipping_cost if shipping_cost
    amt += handling_cost if handling_cost
    amt += sales_tax if sales_tax
    amt
  end

  def add_shipping_address(attrs)
    attrs.merge!(:address_type => 'shipping')
    self.create_shipping_address(attrs)
  end

  def add_billing_address(attrs)
    attrs.merge!(:address_type => 'billing')
    self.create_billing_address(attrs)
  end
  # End methods from Paypal Gem

  def create_or_update_shipping_address(user, attrs)
    attrs[:address_type] = 'shipping'
    address = shipping_address
    if address
      address.update_attributes(attrs)
    else
      address = create_shipping_address(attrs)
      save! # Needed to persist the 'shipping_address_id' in the order.
    end

    # Try to update the shipping address associated with the
    # user.  It is not a problem if this fails.
    if user && address.valid?
      if user.shipping_address
        user.shipping_address.update_attributes(attrs)
      else
        user.create_shipping_address(attrs)
        save!
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
      address = create_billing_address(attrs)
      save! # Needed to persist the 'billing_address_id' in the order.
    end
    # Try to update the billing address associated with the
    # user.  It is not a problem if this fails.
    if user && address.valid?
      if user.billing_address
        user.billing_address.update_attributes(attrs)
      else
        user.create_billing_address(attrs)
        save!
      end
    end
    address
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
  
  private
  
  def init_order
    assign_invoice_number
    self.payment_action = APP_CONFIG[:paypal_default_payment_action]
    self.currency_code = "USD"
    self.transaction_fee = 0
    self.gross_total = 0
    self.amount_authorized = 0
    self.total_captured = 0
    self.sales_tax = 0
    self.handling_cost = 0
    self.shipping_cost = 0
  end

  def assign_invoice_number
    # This is temporary.  We should create a sequence in the database.  TODO.
    # Generate a random 12 digit invoice number not starting with a zero.
    rng = Random.new
    self.invoice_number = rng.rand(10**11..10**12 - 1)
  end

end
