# Load the blueprints from over in spec support.
require "#{Rails.root}/spec/support/blueprints"

# Reset the Machinist cache before each scenario.
Before { Machinist.reset_before_test }
