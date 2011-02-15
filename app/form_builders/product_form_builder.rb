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

  # body is the same as text_field
  def text_area(method, options = {})
    label_text = options.delete(:label)
    label_text += "*" if attr_required?(method)
    @template.content_tag(:div, :class => "input-field") do
      label(method, label_text) +
      @template.content_tag(:span, "Error Message", :class => "field-error") +
      super
    end.html_safe
  end      

  def collection_select(method, collection, value_method, text_method,
    options = {}, html_options = {})
    label_text = options.delete(:label)
    label_text += "*" if attr_required?(method)
    @template.content_tag(:div, :class => "input-field") do
      label(method, label_text) +
      super +
      @template.content_tag(:span, "Error Message", :class => "field-error") 
    end
  end   

  # body is the same as collection_select
  def select(method, choices, options = { }, html_options = { }) 
    label_text = options.delete(:label)
    label_text += "*" if attr_required?(method)
    @template.content_tag(:div, :class => "input-field") do
      label(method, label_text) +
      super +
      @template.content_tag(:span, "Error Message", :class => "field-error") 
    end
  end

=begin 

<div class="input-field">
  <input name="product[shipping_cylinder]" type="hidden" value="0" />
  <input id="product_shipping_cylinder" name="product[shipping_cylinder]" type="checkbox" value="1" />
  <label for="product_shipping_cylinder">Cylinder</label>
  <span class="field-error">Error Message</span>
</div>
=end

  def check_box(method, options = { }, checked_value = "1", unchecked_value = "0")
    label_text = options.delete(:label)
    label_text += "*" if attr_required?(method)
    @template.content_tag(:div, :class => "input-field") do
      super +
      label(method, label_text) +
      @template.content_tag(:span, "Error Message", :class => "field-error") 
    end    
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
