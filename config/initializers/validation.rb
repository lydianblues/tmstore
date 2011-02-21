module ActiveModel
  class Errors < ActiveSupport::OrderedHash
    def full_messages(options = {})
      full_messages = []

      each do |attribute, messages|
        messages = Array.wrap(messages)
        next if messages.empty?

        if attribute == :base
          messages.each {|m| full_messages << m }
        else          
          unless options && options[:base_only]
            attr_name = attribute.to_s.gsub('.', '_').humanize
            attr_name = @base.class.human_attribute_name(attribute, :default => attr_name)
            options = { :default => "%{attribute} %{message}", :attribute => attr_name }
            messages.each do |m|
              if m =~ /^\^/
                full_messages << I18n.t(:"errors.format.full_message",
                  options.merge(:message => m[1..-1], :default => "%{message}"))
              else        
                full_messages << I18n.t(:"errors.format", options.merge(:message => m))
              end
            end
          end
        end
      end
      full_messages
    end
  end
end

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|
  if html_tag =~ /type="hidden"/ || html_tag =~ /<label/
    html_tag
  else
    field = <<-EOT
      <div class="field-error">#{html_tag}</div>
    EOT
    field.html_safe
  end
end

