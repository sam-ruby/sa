class FeedbackMailer < ActionMailer::Base

  def email_feedback(customer_name, customer_email_address, browser_info,
                     url, description, encoded_img)

    @customer_name = customer_name
    @customer_email_address = customer_email_address
    @browser_info = browser_info
    @url = url
    @description = description
    attachments['image.png'] = {
      mime_type: 'image/png',
      encoding: 'base64',
      content: encoded_img} if encoded_img

    mail_config = {from: Rails.configuration.feedback_mailer.from,
                   to: Rails.configuration.feedback_mailer.to,
                   subject: Rails.configuration.feedback_mailer.subject}
    mail_config[:cc] =  @customer_email_address if @customer_email_address
    
    # Send the email
    mail(mail_config)
  end
end
