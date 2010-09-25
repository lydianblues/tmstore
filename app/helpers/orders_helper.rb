module OrdersHelper

  def format_time(time)
    if time
      time.getlocal.strftime('%m/%d/%Y %I:%M %Z')
    else
      ""
    end
  end

end
