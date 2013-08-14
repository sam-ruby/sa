class Category < BaseModel
  self.table_name = 'categories'
  @@cat_map = []
  
  def self.get_cats_with_revenue(cat_ids, week=23)
    cat_ids = [cat_ids] unless cat_ids.is_a? Array
    joins('INNER JOIN cat_metrics_week on ' +
          'cat_metrics_week.cat_id = categories.c_category_id').select(
            'c_category_id, c_category_name, p_category_id, ' +
            'p_category_name').where(
              "p_category_id in (?) and channel = 'TOTAL' and " +
              'cat_metrics_week.week = ? and ' +
              'cat_metrics_week.cat_revenue > 0', cat_ids, week).order(
                'c_category_name')
  end
  
  def self.get_cat_map(flat=false)
    cats = []
    root_categories = get_cats_with_revenue(0);
    first_level_categories = get_cats_with_revenue(
      root_categories.map {|cat| cat.c_category_id})
    second_level_categories = get_cats_with_revenue(
      first_level_categories.map {|cat| cat.c_category_id }) 

    root_categories.each do |x| 
      next if x.c_category_name.strip.empty?
      root_cat = {:cat_ids => x.c_category_id,
                  :cat_id => x.c_category_id,
                  :label => x.c_category_name.strip,
                  :name => x.c_category_name.strip,
                  :category => 'All'}
      cats << root_cat
      root_cat['children'] = []
      first_level_categories.select do |y|
        y.p_category_id == x.c_category_id end.each do |y|
          next if y.c_category_name.strip.empty?
          f_cat = {:cat_ids => "#{x.c_category_id},#{y.c_category_id}",
                   :cat_id => y.c_category_id,
                   :label => y.c_category_name.strip,
                   :name => y.c_category_name.strip,
                   :category => "#{x.c_category_name}"}
          root_cat['children'] << f_cat
          f_cat['children'] = []
          second_level_categories.select do |z|
            z.p_category_id == y.c_category_id end.each do |z|
              next if z.c_category_name.strip.empty?
              cat_ids = "#{x.c_category_id},#{y.c_category_id}," +
                "#{z.c_category_id}"
              label = "#{y.c_category_name.strip}->#{z.c_category_name.strip}"
              s_cat = {:cat_ids => cat_ids,
                       :cat_id => z.c_category_id,
                       :label => label,
                       :name => z.c_category_name.strip,
                       :category => "#{x.c_category_name}"}
              f_cat['children'] << s_cat
          end
      end
    end
    if (flat) 
      Rails.cache.fetch(:flat_category_map, :expires_in => 4.hours) do 
        flatten_cats(cats)
      end
    else
      Rails.cache.fetch(:category_map, :expires_in => 4.hours) do
        cats
      end
    end
  end

  def self.get_category_names(cat_ids)
    cat_map = {}
    Category.where(:c_category_id => cat_ids).each do |cat|
      cat_map[cat.c_category_id] = cat.c_category_name
    end
    cat_map
  end
  
  def self.flatten_cats(cats)
    result = []
    add_child = Proc.new {|cat|
      result << cat
      if cat['children'] and !cat['children'].empty?
        cat['children'].each {|child_cat| add_child.call(child_cat)}
      end
    }
    cats.each {|item| add_child.call(item) }
    result
  end
end
