class MessagesController < ApplicationController
  
  before_filter :login_required

  # Works for messages_controller_spec
  def old_create
    @message = Message.new params[:message]
    if (@message.save)
       flash[:notice] = "The message was saved successfully."
       redirect_to messages_path
    else
      render :template => 'new'
    end
  end
  
  # Works for the user_spec.rb
  def create
    @message = current_user.send_message params[:message]
    if @message.new_record?
      render :action => "new"
    else
      flash[:notice] = "The message was saved successfully."
      redirect_to messages_path
    end
  end
  
  def new
    @message = Message.new
    respond_to do |format|
      format.js {  render :template => "new.js.erb"}
      format.html do
        
      end
    end
  end

  private
  def login_required
    require_user "You must be logged in to send messages."
  end
end