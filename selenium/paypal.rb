# require "rubygems"
# gem "rspec"
# gem "selenium-client"
require "selenium/client"
require "selenium/rspec/spec_helper"

describe "t1" do
  attr_reader :selenium_driver
  alias :page :selenium_driver

  before(:all) do
    @verification_errors = []
    @selenium_driver = Selenium::Client::Driver.new \
      :host => "localhost",
      :port => 4444,
      :browser => "*firefox",
      :url => "http://store/",
      :timeout_in_second => 60
  end

  before(:each) do
    @selenium_driver.start_new_browser_session
  end
  
  append_after(:each) do
    @selenium_driver.close_current_browser_session
    @verification_errors.should == []
  end
  
  it "test_t1" do
    page.open "/"
    page.click "link=Products"
    page.wait_for_page_to_load "30000"
    page.click "//div[@id='center-content']/div[2]/a/div[1]/div"
    page.wait_for_page_to_load "30000"
    page.click "commit"
    page.wait_for_page_to_load "30000"
    sleep 5
    page.click "//img[@alt='Btn_xpresscheckout']"
    page.wait_for_page_to_load "30000"
    sleep 5
    page.type "login_password", "233697837"
    page.click "login.x"
    page.wait_for_page_to_load "30000"
    page.click "addInstructions"
    page.type "sellerNotesNew", "Here is a memo"
    page.click "saveNote"
    page.click "continue"
    page.wait_for_page_to_load "30000"
    page.click "commit"
    page.wait_for_page_to_load "30000"
    begin
        page.is_text_present("PayPal Express Purchase succeeded").should be_true
    rescue ExpectationNotMetError
        @verification_errors << $!
    end
  end
end

