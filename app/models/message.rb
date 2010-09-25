class Message < ActiveRecord::Base
  validates_presence_of :text, :recipient, :title
  belongs_to :recipient, :class_name => 'User'
  
  scope :in_date_range, lambda { |range|
    where(:created_at => range)
  }
   
end
