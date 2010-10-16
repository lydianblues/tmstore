require 'spec_helper'

describe "test store environment" do
  
  it "should have correct inital structure" do
    build_store
    verify_overall_counts
    verify_product_families
    verify_category_attributes
    verify_category_families
    verify_family_attributes
  end

end

