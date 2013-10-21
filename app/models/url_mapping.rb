class URLMapping < BaseModel
  set_table_name 'url_mapping'
  attr_accessor :walmart_price

  def self.get_amazon_items(query_str, weeks, year=nil)
    amazon_comparison_items = find_by_sql([
      %Q{select distinct url_mapping.item_id, amazon.idd, amazon.name, 
       amazon.brand, amazon.position,
       amazon.name, amazon.brand, amazon.imgurl as img_url, 
       amazon.url, amazon.newprice, all_item_attrs.curr_item_price
       from url_mapping, (select max(check_week), idd, query_str,
       position,brand,name, imgurl, url,newprice from amazon_scrape_weekly 
       where check_year = ? and check_week in (?) and 
       query_str = ? group by idd) as 
       amazon, all_item_attrs 
       where url_mapping.retailer_id = amazon.idd and
       all_item_attrs.item_id = concat(url_mapping.item_id) 
      order by position}, year, weeks, query_str])
 
    walmart_top_32_items = ::WalmartTop32Items.select(
      %q{query, item, position}).where(
        'year = ? and week = ? and query = ?', year, weeks.last, query_str).map do 
          |item| item['item'] end
    
    if walmart_top_32_items and walmart_top_32_items.size > 0 
      {:in_top_32 => amazon_comparison_items.select do |item| 
        walmart_top_32_items.include?(item[:item_id].to_s) end,
          :not_in_top_32 => amazon_comparison_items.select do |item|
          !walmart_top_32_items.include?(item[:item_id].to_s) end, 
            :all_items => amazon_comparison_items}
    else
      {:in_top_32 => [], :not_in_top_32 => [],
       :all_items => amazon_comparison_items}
    end
  end
end
