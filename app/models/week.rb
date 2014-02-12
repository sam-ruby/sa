class Week < BaseModel
  self.table_name = 'pipeline_log_weekly'
  
  def self.all_weeks(year)
    select("distinct week, year").where([%q{year = ?}]).order("week DESC").map {|x|
      {week: x.week, year: x.year}}
  end

  def self.available_weeks
    @available_weeks = Week.select("distinct week, year").where([
    %q{(week,year) NOT IN (SELECT DISTINCT week, year FROm pipeline_log_weekly WHERE status != 1)}]).order(
        "year DESC, week DESC").map {|x| {week: x.week, year: x.year}}
  end
   
  def self.unavailable_weeks(year)
    all_weeks(year) - available_weeks(year)
  end
end
