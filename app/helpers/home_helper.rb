module HomeHelper
  def formt_site_revenue(revenue)
    if revenue.nil?
      '-'
    else 
      #formt_integer(revenue.to_i.round)
      number_to_currency(revenue.round, :precision => 0)
    end
  end
  
  def get_image_url(item)
    if item and !item['images'].nil? and !item['images'].empty? 
      item['images'][0]['url'] rescue nil
    else
      nil
    end
  end

  def get_table_height(list, images=false, std_height=25)
    if list.size > 22
      std_height
    else
      if images
        list.size * 10 > std_height ? std_height : list.size * 10
      else
        'auto'
      end
    end
  end

  def get_default_url_params
    url_params = {}
    url_params[:view] = @view
    url_params[:controller] = :home
    url_params[:date] = @date if @date
    url_params[:year] = @year if @year
    url_params[:week] = @week if @week
    url_params
  end

  def get_weeks
    now = Time.now
    jan_1 = Time.local(now.year, 1, 1)
    jan_1 += (6 - jan_1.wday) > 0 ?  (6 - jan_1.wday).days : 0.days 
    jan_1 += 21.days
    weeks = (now.to_i - jan_1.to_i)/(24*60*60*7)
    start_date = jan_1 - 7.days
    (1..weeks).to_a.map do |wk|
      start_date += 7.days
      {:week => wk, :start_date => start_date,
       :end_date => start_date + 6.days}
    end.reverse
  end

  alias_method :formt_revenue, :formt_site_revenue
end
