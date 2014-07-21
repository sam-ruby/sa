require 'job_monitoring'

namespace :monitoring do
  desc 'Check the Job completion status of Pipeline Log Daily'
  task :pipeline_daily => :environment do
    date_check = Date.today - 1.day
    unless JobMonitoring.pipeline_log_daily(date_check)
      JobMonitoringMailer.pipeline_log_daily(date_check).deliver! 
    end
  end

  desc 'Check the Data validation step of Jobs'
  task :data_validation => :environment do
    date_check = Date.today - 1.day
    unless JobMonitoring.data_validation(date_check)
      JobMonitoringMailer.data_validation(date_check).deliver! 
    end
  end
  
  desc 'Check the Job completion status of Pipleine Log Weekly'
  task :pipeline_weekly => :environment do
    base_controller = BaseController.new()
    date_check = Date.today - 1.day
    year_week = base_controller.get_week_from_date(date_check)
    unless JobMonitoring.pipeline_log_weekly(
      year_week[:week], year_week[:year])
      JobMonitoringMailer.pipeline_log_weekly(
        year_week[:week], year_week[:year]).deliver! 
    end
  end
end
