class HomeController < ApplicationController
  def show
    reset_url_history(:user)
  end
end
