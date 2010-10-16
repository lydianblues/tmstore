class Admin::CategoriesController < ApplicationController

  layout "admin"
 
  before_filter :require_admin
  before_filter :admin_store_url, :except => "index"
  
  # Display all the root categories.
  def index
    catid = Category.root_id
    redirect_to admin_category_path(catid)
  end

  # Display information about a category.
  def show
    begin
      catid = Integer(params[:id])
      @category = Category.find(catid)
    rescue
      @category = Category.find(Category.root_id)
    end
    
    init_vars
    
    # The view template will be show.html.erb. This action
    # always renders the whole page, so there is no need
    # for a Javascript format.
    
  end

  # Create a new category.
  def create
    catparams = params[:category]
    @category = Category.find(catparams[:parent_id])
    @category.add_subcat(catparams[:name])

    if @category.errors.empty?
      flash[:notice] = 'Category was successfully created.'
    end
    @subcats = Category.where("parent_id = ?", @category.id).order("name ASC")

    respond_to do |format|
       format.html { init_vars; render 'show' }
       format.js # The view template will be create.js.erb.
     end
  end

  def update
    @category = Category.find(params[:id])
    command = params[:command]

    if command == 'rename'
      rename(params)
    elsif command == 'reparent'
      reparent(params)
    elsif command == 'add_family'
      add_family(params)
    elsif command == 'remove_family'
      remove_family(params)
    end
   
  end

  # Destroy (or delete) a category. 
  def destroy

    @category = Category.find(params[:id])

    begin
      # before_destroy callback could raise exception.
      @category.destroy
    rescue Exception => e
      @category.errors.add(:base, "Category deletion failed: #{e}")
    end
    
    if @category.errors.empty?
      flash[:notice] = 'Category was successfully deleted.'
    end
    
    respond_to do |format|
      format.html do
        if @category.errors.empty?
          @category = Category.find(@category.parent_id)
        end
        init_vars
        render :action => 'show'
      end
      format.js do
        if @category.errors.empty?
          @new_page = admin_category_path(:id => @category.parent_id)
        else
          @new_page = admin_category_path(@category)
        end
        render :action => 'destroy'
      end
    end
  end
  
  private
  
  # Initialize all the instance variables needed to render
  # the whole "admin/categories/show" page.
  def init_vars
    return unless @category
    unless @parent
      if @category.parent_id
        @parent = Category.find(@category.parent_id)
      end
    end
    unless @subcats
      @subcats = Category.where("parent_id = ?", @category.id).order("name ASC")
    end
    unless @families
      @families = @category.product_families.default_sort
    end
    unless @attributes
      @attributes = @category.product_attributes.default_sort
    end
  end
  
  def add_family(params)
    sleep(5)
    find_family_by_name_or_id(params[:family][:name], params[:family][:id])
    if @family
      @category.add_family(@family)
    end
    @families = @category.product_families.default_sort
    @attributes = @category.product_attributes.default_sort
    if @category.errors.empty?
      flash.now[:notice] = "Successfully added product family."
    end
    respond_to do |format|
       format.html { init_vars; render 'show' }
       format.js {render 'add_family'}
     end
  end
  
  def remove_family(params)
    @family = ProductFamily.find(params[:fam_id])
    if @family
      @category.remove_family(@family.id)
    else
      @category.errors.add_to_base "Product family not found."
    end
    @families = @category.product_families.default_sort
    @attributes = @category.product_attributes.default_sort
    if @category.errors.empty?
      flash.now[:notice] = "Successfully removed product family."
    end
    respond_to do |format|
       format.html { init_vars; render 'show' }
       format.js { render 'remove_family'}
     end
  end
  
  def rename(params)
    if @category.update_attributes :name => params[:name]
      flash.now[:notice] = "Successfully renamed category."
    end
    respond_to do |format|
       format.html {init_vars; 'show' }
       format.js {render 'rename'}
     end
  end
  
  def reparent(params)
    pid = params[:new_parent_id]
    if pid.blank?
      new_parent_id = Category.path_to_id(params[:new_parent_path])
    else
      new_parent_id = Integer(pid)
    end
    if new_parent_id
      @category.reparent(new_parent_id)
    else
      @category.errors.add(:base, "Category path is invalid")
    end
    if @category.errors.empty?
      flash.now[:notice] = "Successfully reparented category."
    end
    respond_to do |format|
       format.html { init_vars; render 'show' }
       format.js { render 'reparent'}
     end
  end

  private 
  
  def find_family_by_name_or_id(fam_name, fam_id)
    begin
      if fam_id.blank?
        @family = ProductFamily.where(:name => fam_name).first
        unless @family
          raise "Product family with name \"#{fam_name}\" could not be found."
        end
      else
        @family = ProductFamily.find(fam_id)
      end
    rescue Exception => e
      @category.errors.add(:base, "#{e}")
    end
  end
  
end
