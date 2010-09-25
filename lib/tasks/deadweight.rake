begin
  require 'deadweight'
rescue LoadError
  puts "Cant' load deadweight"
end

desc "run Deadweight CSS check (requires script/server)"
task :deadweight do
  dw = Deadweight.new
  #dw.stylesheets = ["/stylesheets/standard.css", "/stylesheets/application-base.css", "/stylesheets/application.css" ]
  dw.stylesheets = ["/stylesheets/common.css", "/stylesheets/application.css"]
  dw.ignore_selectors = /flash_notice|flash_error|errorExplanation|fieldWithErrors/
  dw.pages = ["/products"]
  puts dw.run
end
