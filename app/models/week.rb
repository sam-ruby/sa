class Week < BaseModel
  self.table_name = 'pipeline_log_weekly'
  
  def self.all_weeks
    @all_weeks = Week.select("distinct week, year").order(
      "week DESC").map {|x|  {week: x.week, year: x.year}}
  end

  def self.available_weeks
    @available_weeks = Week.select("distinct week, year").where([
      %q{week NOT IN (SELECT DISTINCT week FROM 
      pipeline_log_weekly WHERE status != 1)}]).order(
        "week DESC").map {|x| {week: x.week, year: x.year}}
  end
   
  def self.unavailable_weeks
    @unavailable_weeks = Week.all_weeks - Week.available_weeks
  end

end
