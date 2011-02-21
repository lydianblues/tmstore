class ProductFormBuilder < ActionView::Helpers::FormBuilder

  def text_field(method, options = {})
    label_text = options.delete(:label)
    label_text += "*" if attr_required?(method)
    @template.content_tag(:div, :class => "input-field") do
      @template.content_tag(:div, :class => "input-field-header") do
        label(method, label_text) +
          error_html(method)
      end +
      super
    end.html_safe
  end

  # body is the same as text_field
  def text_area(method, options = {})
    label_text = options.delete(:label)
    label_text += "*" if attr_required?(method)
    @template.content_tag(:div, :class => "input-field") do
      @template.content_tag(:div, :class => "input-field-header") do
        label(method, label_text) +
          error_html(method)
      end +
      super
    end.html_safe
  end

  def collection_select(method, collection, value_method, text_method,
    options = {}, html_options = {})
    label_text = options.delete(:label)
    label_text += "*" if attr_required?(method)
    @template.content_tag(:div, :class => "inline-input-field") do
      label(method, label_text) +
      super +
      error_html(method)
    end
  end   

  # body is the same as collection_select
  def select(method, choices, options = { }, html_options = { }) 
    label_text = options.delete(:label)
    label_text += "*" if attr_required?(method)
    @template.content_tag(:div, :class => "inline-input-field") do
      label(method, label_text) +
      super +
      error_html(method)
    end
  end

  def check_box(method, options = { }, checked_value = "1", unchecked_value = "0")
    label_text = options.delete(:label)
    label_text += "*" if attr_required?(method)
    @template.content_tag(:div, :class => "input-field") do
      @template.content_tag(:div, :style => "float:left;") do
        super
      end +
      label(method, label_text) +
      error_html(method)
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

  def error_html(method)
    @myobject ||= @template.instance_variable_get("@#{ @object_name}") 
    errors = @myobject.errors[method]
    err_html = ""
    unless errors.empty?
      err_msg = errors.first.sub(/^\^/, '')
      err_html = @template.content_tag(:span, err_msg,
        :class => "field-error-message")
    end
    err_html
  end

end
