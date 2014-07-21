class JobMonitoringMailer < ActionMailer::Base
  def pipeline_log_daily(data_date)
    @data_date = data_date
    mail_config = {
      from: Rails.configuration.feedback_mailer.from,
      to: Rails.configuration.feedback_mailer.to,
      subject: "PipeLine Log Daily Job Failed: #{data_date}"}
    # Send the email
    mail(mail_config)
  end
  
  def data_validation(data_date)
    @data_date = data_date
    mail_config = {
      from: Rails.configuration.feedback_mailer.from,
      to: Rails.configuration.feedback_mailer.to,
      subject: "Data Validation Daily Job Failed: #{data_date}"}
    # Send the email
    mail(mail_config)
  end
  
  def pipeline_log_weekly(week, year)
    @week = week
    @year = year
    mail_config = {
      from: Rails.configuration.feedback_mailer.from,
      to: Rails.configuration.feedback_mailer.to,
      subject: "PipeLine Log Weekly Job Failed: week-#{week}, year-#{year}"}
    mail(mail_config)
  end
end
