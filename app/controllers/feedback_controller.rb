class FeedbackController < BaseController

  before_filter :set_common_data

  def send_feedback
    from_user_id = params[:from_user_id]
    customer_name = from_user_id
    browser_info = params[:browser][:appVersion]
    url = params[:url]
    description = params[:note]
    
    if params[:img] 
      img_encoded = params[:img].split(',').last     
    else
      img_encoded = nil
    end

    # Pass nil for now, since the email address of the logged in
    # user is not available.
    FeedbackMailer.email_feedback(
      customer_name, nil, browser_info, url, description, img_encoded).deliver

    #render :nothing => true, :status => 200
    render :json => []
  end
end
