class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable, :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  validates :email, :on => :create, :presence => true # , :uniqueness => true
  validates :login, :on => :create, :presence => true, :uniqueness => true
  validates :password, :on => :create, :presence => true
  validates :password_confirmation, :on => :create, :presence => true
  validates_confirmation_of :password

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :login

#  acts_as_authentic
  
  has_many :orders
  
  belongs_to :billing_address, :class_name => 'Address'
  belongs_to :shipping_address, :class_name => 'Address'

  # acts_as_authentic do |c|
  #    c.my_config_option = my_value
  # end

 ########## Begin TEMPORARY Example from the RSpec Book ##################  

  has_many :received_messages, :class_name => 'Message',
    :foreign_key => "recipient_id"
    
  has_many :sent_messages, :class_name => 'Message',
    :foreign_key => "sender_id"
    
  belongs_to :subscription

  def send_message(message_attrs)
    if subscription.can_send_message?(self)
      sent_messages.create message_attrs
    end
  end 
 
################ End TEMPORARY Example ##################################

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.password_reset_instructions(self).deliver
  end

end
