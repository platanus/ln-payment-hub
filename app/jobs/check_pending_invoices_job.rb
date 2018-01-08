class CheckPendingInvoicesJob < ApplicationJob
  include LightningHelper
  include PaymentsHelper
  include NotificationsHelper
  queue_as :default

  def perform(r_hash, expiry)
    if (lookup_ln_invoice(r_hash).settled || lookup_internal_payment(r_hash)) && expiry >= 0
      payment = Payment.find_by(r_hash: r_hash)
      payment.status = :completed
      payment.save
      user = User.find(payment.user.id)
      notify_user_payment(user.slack_id, payment.amount)
    else
      expiry -= 4
      CheckPendingInvoicesJob.set(wait: 4.second).perform_later r_hash, expiry
    end
  end
end
