class OrderTransaction < ActiveRecord::Base
  belongs_to :order

  def filter_attributes(attributes)
    c = attributes.clone
    c.delete_if {|k, v| !respond_to?(k)}
  end

end
