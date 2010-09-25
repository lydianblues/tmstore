class Notifier < ActionMailer::Base
  default :from => "Thirdmode <noreply@thirdmode.com>"

  def password_reset_instructions(user)
   # @reset_url =  "http://localhost:3000/password_resets/#{user.perishable_token}/edit"
   # mail(:to => user.email, :subject => "Password Reset Instructions")
   @token = user.perishable_token
   mail(:to => "lydianblues@gmail.com", :subject => "Password Reset Instructions")
  end
  
end
