# This file is used by Rack-based servers to start the application.
# It must be renamed or removed when using Passenger in other than
# production mode, otherwise Passenger ALWAYS starts in production 
# mode, regardless of the value of RailsEnv.  

require ::File.expand_path('../config/environment',  __FILE__)
run Store::Application
