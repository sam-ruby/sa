class URLMapping < BaseModel
  set_table_name 'url_mapping'
  attr_accessor :walmart_price

  def self.get_amazon_items(query_str)
    amazon_comparison_items = select(
      %q{distinct item_id,idd, name, brand, position,
       amazon.name, brand, imgurl as img_url, 
       amazon.url, newprice}).joins(%Q{RIGHT OUTER JOIN 
       (SELECT max(check_week), idd, query_str,position,brand,name,
       imgurl,url,newprice from amazon_scrape_weekly where query_str
       = '#{query_str}' group by idd) as amazon ON 
       url_mapping.retailer_id = amazon.idd order by position})
        
    walmart_items = []
    amazon_comparison_items.each do |curr_row|
    if curr_row.item_id != nil
      walmart_items << curr_row.item_id
     end
    end

    walmart_prices = AllItemAttrs.select(
      'item_id, curr_item_price').where(:item_id => walmart_items)

    amazon_comparison_items.each do |curr_row|
      if curr_row.item_id != nil
        walmart_prices.each do |curr_price|
          if curr_row.item_id.to_i == curr_price.item_id.to_i
            curr_row.walmart_price = curr_price.curr_item_price
          end
        end
      end
    end
    amazon_comparison_items;
  end
end
