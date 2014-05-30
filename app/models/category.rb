class Category < BaseModel
  self.table_name = 'categories'

  def self.autocomplete_categories(query)

    final_categories = Array.new
    conditions = ["p_category_name LIKE ? OR c_category_name LIKE ?", "%#{query}%", "%#{query}%"]

    starting_categories = Category.find(:all, conditions: conditions)

    starting_categories.each do |curr_category|
      category_trail = Array.new
      category_trail << curr_category
      if curr_category.p_category_id != 0
        self.find_category_trail(category_trail, curr_category.p_category_id)
      end

      final_categories << category_trail
    end

    return final_categories;
  end

  def self.find_category_trail(category_array, category_id)
    conditions = ["c_category_id = ?", category_id]

    categories = Category.find(:all, conditions: conditions)
    categories.each do |curr_category|
      category_array << curr_category
      if curr_category.p_category_id != 0
        find_category_trail(category_array, curr_category.p_category_id)
      else
        return category_array
      end

    end
  end

  def self.subcategories_by_parent_id(id, year, week)
    cat_week_join = %q{as cat join cat_metrics_week a on 
    a.cat_id = cat.c_category_id}

    conditions = [%q{cat.p_category_id = ? and a.year = ? and a.week = ? 
    and a.revenue > 0}, id, year, week]

    select(%q{cat.c_category_id, cat.c_category_name,
      (select count(*) from categories where 
       p_category_id = cat.c_category_id) children}).joins(
         cat_week_join).where(conditions).group('a.cat_id').order(
           "c_category_name asc").uniq()
  end
  
  def self.get_sibling_categories(s_id)
    cat_week_join = "join cat_metrics_week on cat_id = c_category_id"
    conditions = ["p_category_id = ? and revenue > 0", id]
    categories = category.select(:c_category_id, :c_category_name).distinct
      .joins(cat_week_join).distinct.where(conditions).order("c_category_name asc")
  end

  def is_child
    cat_week_join = "join cat_metrics_week on cat_id = c_category_id"
    conditions = ["p_category_id = ? and cat_revenue > 0", self.c_category_id]
    categories = Category.select(:c_category_id, :c_category_name).distinct.joins(cat_week_join).distinct.where(conditions).limit(1)
    if categories.count == 1
      return true
    else
      return false
    end
  end

  def is_parent
    categories = Category.find_by_p_category_id(self.c_category_id)
    if categories != nil
      return true
    else
      return false
    end
  end

end
