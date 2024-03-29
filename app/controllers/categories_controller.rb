class CategoriesController < BaseController
  before_filter :set_common_data
  def index
    query = params[:query]
    if query != nil
      @categories = Category.autocomplete_categories(query)
    else
      @categories = Hash.new
    end

    respond_to do |format|
      format.json { render :json => @categories }
    end		        
  end

  def get_cats
    cat_ids = params[:cat_ids]
    respond_to do |format|
      format.json do 
        render :json => Category.where(c_category_id: cat_ids)
      end
    end
  end

  def remove_saved_category 
    @saved_categories = SavedCategory.where(
      user_id: session[:user_id], category_trail:params[:trail]);
    @saved_categories.destroy_all

    respond_to do |format|
      format.json { render :json => true }
    end		
  end

  def save_category
    @saved_categories = SavedCategory.where(user_id: session[:user_id]);
    cat_found = false;
    @saved_categories.each do |curr_cat|
      if (curr_cat.category_trail == params[:trail])
        curr_cat.favorite = params[:favorite]
        curr_cat.save!
        cat_found = true;
      elsif (params[:favorite] == true)
        curr_cat.favorite = false;
        curr_cat.save!
      end
    end

    if !cat_found
      @saved_category = SavedCategory.new(category_name: params[:name], user_id: session[:user_id], category_trail: params[:trail], favorite: params[:favorite])
      @saved_category.save!
    end

    respond_to do |format|
      format.json { render :json => @saved_category }
    end	
  end

  def get_saved_categories
    @saved_categories = SavedCategory.where(user_id: session[:user_id]);
    respond_to do |format|
      format.json { render :json => @saved_categories }
    end	
  end

  def category_by_id
    id = params[:id].to_i
    if id == 0
      cat_has = {c_category_name: 'All Departments',
                 c_category_id: 0,
                 is_parent: true}
    else
      category = Category.find_by_c_category_id(id)
      cat_hash = category.attributes
      cat_hash[:is_parent] = category.is_parent
    end
    respond_to do |format|
      format.json { render :json => cat_hash }
    end	
  end

  def get_children
    year_week = get_week_from_date(@date)
    curr_cat_name = 'All Departments'
    cats = []
    c_id = params[:cat_id] || 0
    if c_id.kind_of?(Array) 
      last_c_id = c_id.last.to_i
    else
      last_c_id = c_id.to_i
      c_id = [c_id]
    end

    categories = Category.subcategories_by_parent_id(
      last_c_id, year_week[:year], year_week[:week])
    if (c_id.kind_of?(Array) || c_id.to_i != 0)
      Category.select('c_category_name, c_category_id').where(
        c_category_id: c_id).uniq.order(
          'Field(c_category_id, ' + c_id.join(',') + ')').each do |rec|
        cats.push(
          {cat_id: rec.c_category_id,
           cat_name: rec.c_category_name})
      end
    end

    result = {}
    result[:sub_categories] = categories.to_json
    result['cats'] = cats
    respond_to do |format|
      format.json { render :json => result}
    end		        
  end
end
