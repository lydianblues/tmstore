Before("@admin2") do
  #a = Factory(:admin2)
  #a.save!
end

Before("@tree") do
  puts "Building Standard Category Tree..."
  table = [["root", "A", "B"],
          ["A", "C", "D"],
          ["C", "E"],
          ["D", "F", "G"],
          ["F", "H", "I"]]
  table.each do |r|
    parent = Category.find_by_name(r.shift)
    r.each do |c|
      parent.add_subcat(c)
    end
  end
end

