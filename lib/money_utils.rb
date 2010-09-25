module MoneyUtils
   
   # Convert any dollar value that a user might reasonably enter to cents: e.g. anything
   # in %q[23.09 23.00 23 23. 23.0 23.00 0.12 .10 .01 .23].  A leading '$' is optional.
   def self.parse(val)
     return nil if val.blank? || !val.instance_of?(String)
     av = val.gsub /^\$/, "" # strip optional leading '$'

     begin
       if av.match /(.*)\.(.*)/ 
         dollars_string = $1
         cents_string = $2
         if cents_string.length == 0
           cents = 0
         elsif cents_string.length == 1
           if cents_string == "0"
             cents = 0
           else
             cents = Integer(cents_string) * 10
           end
         elsif cents_string.length == 2
           cents_string = cents_string.gsub(/^0*/, "")
           cents_string = "0" if cents_string.blank?
           cents = Integer(cents_string)
         else
           return nil
         end

         if (dollars_string.blank?)
           dollars = 0
         else
           dollars = Integer(dollars_string) 
         end
       else # there was no decimal point
         cents = 0
         dollars = Integer(av)
       end  
     rescue ArgumentError # Integer function couldn't convert
       return nil
     end
     return dollars * 100 + cents # convert all to cents
   end
   
   def self.format(cents, currency = "USD")
     if cents.blank?
       nil
     else
       Money.new(cents, currency).format
     end
   end
  
  # Converts "223" to "2.23", for example.
  def self.format_for_paypal(cents)
    cents = 0 unless cents
    Money.new(cents, "USD").format(:symbol => false)
  end

  # Convert "0.02" to 2, "0.20" to 20, "2.00" to 200, for example.
  def self.paypal_to_cents(amt)
    Integer(amt.sub(/^0+/, "").sub(/\./, ""))
  end

end
