require "httparty"
module NotificationsHelper
  def notify_user_payment(user, amount)
    HTTParty.post(ENV['LITA_SERVER'] + '/notify_payment',
                    :body => {  :user => user,
                                :satoshis => amount,
                    }.to_json,
                    :headers => { 'Content-Type' => 'application/json' })
  end

end
