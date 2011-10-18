class HomeController < ApplicationController
#  ssl_required :show
  def show
    reset_url_history(:user)
  end
end
