module Admin::ProductFamiliesHelper
  
  def category_display_path(cat)
    path = cat.full_path
    if path == '/'
      path = '/ (anonymous root category)'
    end
    path
  end
end