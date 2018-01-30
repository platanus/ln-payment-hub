class CheckPendingInvoicesJob < ApplicationJob
  include LightningHelper
  include PaymentsHelper
  include NotificationsHelper
  queue_as :default
  INVOICE_POOLING_DELTA = Integer(ENV['INVOICE_POOLING_DELTA'])

  def perform(r_hash, expiry)
    if lookup_ln_invoice(r_hash).settled || lookup_internal_payment(r_hash)
      payment = Payment.find_by(r_hash: r_hash)
      payment.status = :completed
      payment.save
      user = User.find(payment.user.id)
      notify_user_payment(user.slack_id, payment.amount)
    elsif expiry >= 0
      expiry -= INVOICE_POOLING_DELTA
      CheckPendingInvoicesJob.set(wait: INVOICE_POOLING_DELTA.second).perform_later r_hash, expiry
    end
  end
end
