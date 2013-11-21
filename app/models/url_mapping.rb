class URLMapping < BaseModel
  self.table_name = 'url_mapping'
  attr_accessor :walmart_price

  def self.get_amazon_items(query_str, weeks, year=nil)
    amazon_comparison_items = find_by_sql([
      %Q{select distinct url_mapping.item_id, amazon.idd, amazon.name, 
       amazon.brand, amazon.position, walmart_items.position as 
       walmart_position,
       amazon.name, amazon.brand, amazon.imgurl as img_url, 
       amazon.url, amazon.newprice, all_item_attrs.curr_item_price
       from url_mapping left outer join 
       (select item, position from walmart_query_top_32_items where 
       year = #{year} and week = #{weeks.last} and query = '#{query_str}') 
       as walmart_items
       on walmart_items.item = url_mapping.item_id,
       (select max(check_week), idd, query_str,
       position,brand,name, imgurl, url,newprice from amazon_scrape_weekly 
       where check_year = ? and check_week in (?) and 
       query_str = ? group by idd) as 
       amazon, all_item_attrs 
       where url_mapping.retailer_id = amazon.idd and
       all_item_attrs.item_id = concat(url_mapping.item_id) 
      order by position}, year, weeks, query_str]) 
   
    in_top_32 = amazon_comparison_items.select do |item| 
      !item.walmart_position.nil?  
    end
    not_in_top_32 = amazon_comparison_items.select do |item|
      item.walmart_position.nil?
    end 
    {:in_top_32 => in_top_32,
     :not_in_top_32 => not_in_top_32,
     :all_items => amazon_comparison_items}
  end
end
