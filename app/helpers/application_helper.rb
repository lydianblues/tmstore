module ApplicationHelper

  # This is a hybrid of the Rails 2.3.8 "error_messages_for" and the 
  # devise DeviseHelper#devise_error_messages! method.  I18N should be
  # implemented.
  def error_messages_for(resource_name, options = {})
    resource = instance_variable_get("@#{resource_name}")
    return "" if resource.errors.empty?
    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join

    sentence = if options.include?(:header_message)
      options[:header_message]
    else
      "#{pluralize(resource.errors.count, "error")} " +
        "prohibited this #{resource_name} from being saved:"
    end

    html = <<-HTML
    <div id="errorExplanation">
      <h2>#{sentence}</h2>
      <ul>#{messages}</ul>
    </div>
    HTML
    html.html_safe
  end

  # Use this helper when the list of classes is dynamically constructed
  # by Ruby code.  I can't see how to handle this directly in Haml.
  def div_with_opts(opts, &block)
    class_list = opts[:classes]
    if class_list.instance_of?(Array) && class_list.size > 0
      class_list.reject! { |c| c.blank? }
      class_list = class_list.join(" ")
    end
    content = with_output_buffer(&block)
    content_tag(:div, content, :class => class_list, :id => opts[:id])
  end

  # Return true if the presense of the attribute is required by a validator.
  # Code adapted from Ryan Bates Railscast 211. This can be used to mark
  # required form fields.
  def attr_required?(klass, attribute)
    klass.validators_on(attribute).map(&:class).include?(
      ActiveModel::Validations::PresenceValidator)
  end

end
