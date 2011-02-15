class LabeledFormBuilder < ActionView::Helpers::FormBuilder

  %w[text_field text_area].each do |method_name|
    define_method(method_name) do |method,  *args| 
      options = args.last.class == Hash ? args.last : nil
      @template.content_tag(:div, :class => "form-row-box") do 
        field_label(method, options) + 
          super(method, options.merge({:class => "form-elt-right"}))
       end
    end
  end

  def select(method, choices, options = {}, html_options = {})
    html_options.merge!({:class => "form-elt-right"})
    @template.content_tag(:div, :class => "form-row-box") do
      field_label(method, html_options) + 
        super(method, choices, options, html_options)
    end
  end
  
  # Put a group of submit buttons in a single row.
  def submit(*args)
    opts = {:spacer => "2em"}
    opts.merge!(args.extract_options!)
    
    @template.content_tag(:div, :class => "center-button") do
      # Construct a string like:
      #   super("Submit Changes") + separator + super("Delete")
      # then eval it.
      separator = @template.content_tag(:div,
        :style => "display:inline-block;width:#{opts[:spacer]};") do
      end
      eval(args.map {|e| "super(\"#{e}\")"}.join(" + separator + "))
    end
  end
  
  def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    @template.content_tag(:div, :class => "form-row-box") do
      field_label(method, options) +
        super(method, options, checked_value, unchecked_value)
    end
  end

=begin  # Unused
  # This only supports two choices due to the CSS classes involved.
  def type_choice(method, choices)
    choices[0].merge! :css_class => "form-elt-left"
    choices[1].merge! :css_class => "form-elt-right"
    @template.content_tag(:div, :class => "form-row-box") do
      choices.map do |c| 
        @template.content_tag(:div, :class => c[:css_class]) do
          if c[:checked]
            radio_button(method, c[:value], :checked => true, :class => "radio-button")
          else
            radio_button(method, c[:value], :style => "margin-left:0em;", :class => "radio-button")
          end +
          label(method, c[:label], :for => "#{object_name}_#{method.to_s}_#{c[:value]}")
        end
      end.join("\n")
    end 
  end
=end
  
  private
  
  def field_label(method, options)
    label(method, options[:label], :class => "form-elt-left")
  end
  
end