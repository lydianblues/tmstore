class FamilyBuilder < ActionView::Helpers::FormBuilder
  
  def fields_for(label, *args, &block)
    super
  end
  
  def text_field(label, *args)
    opts = {:rows => 1, :size => 20}
    opts.merge!(args[0]) if args[0]
    @template.content_tag("div", :class => 'family-text-field') do
      @template.content_tag("label", label.to_s.humanize,
        :for => "#{@object_name}_#{label}" ) + "<br/>" + super(label, opts)
    end
  end
  
  def text_area(label, *args)
    opts = {:rows => 6, :cols => 40}
    opts.merge!(args[0]) if args[0]
    @template.content_tag("div", :class => 'family-text-area') do 
      @template.content_tag("label", label.to_s.humanize,
        :for => "#{@object_name}_#{label}" ) + "<br/>" + super(label, opts)
    end
  end

end