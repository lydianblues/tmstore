class LineItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :order

  validates_numericality_of :unit_price, :only_integer => true
  validates_numericality_of :quantity, :only_integer => true

  def full_price
    unit_price * quantity
  end
end
