class ProductFormBuilder < ActionView::Helpers::FormBuilder

  # Generate the following html:
  #  <div class='input-field'>
  #    <label for='name'>
  #      label text from options[:label]
  #    </label>
  #    <span class='field-error'>
  #      Error message
  #    </span>
  #    <input size='40' type='text' />
  # </div>
  #
  def text_field(method, options = {})
    label_text = options.delete(:label)
    label_text += "*" if attr_required?(method)
    @template.content_tag(:div, :class => "input-field") do
      label(method, label_text) +
      @template.content_tag(:span, "Error Message", :class => "field-error") +
      super
    end.html_safe
  end

  def text_area(method, options = {})
    label_text = options.delete(:label)
    label_text += "*" if attr_required?(method)
    @template.content_tag(:div, :class => "input-field") do
      label(method, label_text) +
      @template.content_tag(:span, "Error Message", :class => "field-error") +
      super
    end.html_safe
  end      

  private

  def attr_required?(attribute)
    klass = Kernel.const_get((object_name.to_s).camelize)
    if klass.respond_to?(:validators_on)
      klass.validators_on(attribute).map(&:class).include?(
        ActiveModel::Validations::PresenceValidator)
    else
      false
    end
  end

  
end
