class ProductFormBuilder < ActionView::Helpers::FormBuilder

  def text_field(method, options = { })
    @template.content_tag(:div, :class => "input-field") do
      label(:for => "name") +
      @template.content_tag(:span, "Error Message", :class => "field-error") +
      @template.content_tag(:br) +
      @template.content_tag(:input, :type => "text", :size => options[:size]) 
      
    end      
  end

  private

  # This is also in application_helpers.rb, and in labeled_form_builder.rb.
  def attr_required?(klass, attribute)
    if klass.respond_to?(:validators_on)
      klass.validators_on(attribute).map(&:class).include?(
        ActiveModel::Validations::PresenceValidator)
    else
      false
    end
  end

  def field_label(method, options)
    klass = Kernel.const_get((self.object_name.to_s).camelize)
    if attr_required?(klass, method)
      options[:label] += '*'
    end
    label(method, options[:label], :class => "form-elt-left")
  end
  
end
