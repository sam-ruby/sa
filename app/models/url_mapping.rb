class URLMapping < BaseModel
  self.table_name = 'url_mapping'
  attr_accessor :walmart_price

  def self.get_amazon_items(query_str, four_weeks_info)
    # three_weeks_info is array of [{week,year},{week,year}] cuz it might 
    # contain 3 week that cross years
    latest_year = four_weeks_info[0]["year"]
    latest_weeks = four_weeks_info[0]["weeks"]
    previous_year = four_weeks_info[1]["year"]
    previous_weeks = four_weeks_info[1]["weeks"]
    
    amazon_comparison_items = find_by_sql([
      %Q{select distinct url_mapping.item_id, amazon.idd, amazon.name,
      amazon.brand, amazon.position, walmart_items.position as
      walmart_position,
      amazon.name, amazon.brand, amazon.imgurl as img_url,
      amazon.url, amazon.newprice,
      (select curr_item_price from all_item_attrs
      where item_id = concat(url_mapping.item_id) limit 1) as curr_item_price
      from url_mapping 
      left outer join
      (select item, position from walmart_query_top_32_items where
      year = ? and week = ? and query = '#{query_str}')
      as walmart_items
      on walmart_items.item = url_mapping.item_id,
      (select max(week), idd, query,
      position,brand,name, imgurl, url,newprice from amazon_scrape_weekly
      where 
     (year = ? and week in (?) OR year = ? and week in (?))
      and query = ? group by idd) as
      amazon
      where url_mapping.retailer_id = amazon.idd
      group by amazon.idd order by position}, latest_year,
      latest_weeks.last, latest_year, latest_weeks, previous_year, 
      previous_weeks,query_str])
   
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

