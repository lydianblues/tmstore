# This gets ride of the warning:
# ~/.rvm/gems/ruby-1.9.2-head/gems/rack-1.2.1/lib/rack/utils.rb:16:
#   warning: regexp match /.../n against to UTF-8 string
# See http://openhood.com/rack/ruby/2010/07/15/rack-test-warning/ for an explanation.
module Rack
  module Utils
    def escape(s)
      EscapeUtils.escape_url(s)
    end
  end
end
