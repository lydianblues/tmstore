module FlashHelper
  def flash_error
    content_tag(:div, :id => "flash_error") do 
      flash.discard(:error)
    end
  end
  def flash_notice
    content_tag(:div, :id => "flash_notice") do 
      flash.discard(:notice)
    end
  end
end 
