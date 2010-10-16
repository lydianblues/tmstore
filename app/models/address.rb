class Address < ActiveRecord::Base
  has_one :user
  has_one :order

  def filter_attributes(attributes)
    c = attributes.clone
    c.delete_if {|k, v| !respond_to?(k)}
  end

  EMAIL_PATTERN = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  validates_presence_of :email
  validates_format_of :email, :with => EMAIL_PATTERN

  validates_presence_of :first_name, :last_name, :city,
    :postal_code, :street_1, :country

  # Need to validate that a country is selected, OR a province is selected, OR
  # the Region text field is not blank.
  scope :billing, where(:address_type => 'billing')
  scope :shipping, where(:address_type => 'shipping')

  validate :test_valid

  # Convenience getter method.  Assumes that the database contains the name.
  def state_province_region_name
    if !state.blank?
      state
    elsif !province.blank?
      province
    else
      region
    end
  end

  # Convenience getter method.  Assumes that the database contains the name.
  def state_province_region_abbrev
    if !state.blank?
      USStates.name_to_abbrev(state)
    elsif !province.blank?
      province
    else
      region
    end
  end

  private
  def test_valid

    count = 0

    count += 1 unless state.blank?
    count += 1 unless province.blank?
    count += 1 unless region.blank?
    
    if count == 0
      errors.add(:base, "Must select a State, Province, or enter a Region")
    elsif count > 1
      errors.add(:base, "Must select only one of a State, Province, or Region")
    else
      if country == "United States"
        errors.add :state, "can't be blank" if state.blank?
      elsif country == "Canada"
        errors.add :province, "can't be blank" if province.blank?
      else
        errors.add :region, "must be filled in" if region.blank?
      end
    end

  end

end
