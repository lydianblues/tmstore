require 'rubygems'
require 'oci8'

class NumberArrayType < OCI8::Object::Base
  attr_accessor :attributes
end
  conn = OCI8.new("store", "har526", "orcl2")

  arr = [1, 2, 3, 4]
  cursor = conn.parse('begin :result := sum_array_elements(:array); end;')
  cursor.bind_param(1, nil, Integer)
  cursor.bind_param(2, arr, NumberArrayType)
  cursor.exec
  result = cursor[1]
  
  puts "Array sum is #{result}"
  
  cursor = conn.parse('begin :result := get_number_array; end;')
  cursor.bind_param(1, nil, NumberArrayType)
  cursor.exec
  
  result = cursor[1].attributes
  
  puts "Array elements are: $#{result[0]} and $#{result[1]}"
 