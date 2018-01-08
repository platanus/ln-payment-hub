# == Schema Information
#
# Table name: payments
#
#  id         :integer          not null, primary key
#  pay_req    :string
#  amount     :integer
#  status     :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  r_hash     :string
#
# Indexes
#
#  index_payments_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

module PaymentsHelper
  def send_internal_payment(pay_req)
    recipient_payment = Payment.find_by(pay_req: pay_req)
    recipient_payment.status = 1
    recipient_payment.save
  end

  def lookup_internal_payment(r_hash)
    payment = Payment.find_by(r_hash: r_hash)
    payment.status == 1
  end

  def force_ln_refresh(user)
    payments = User.find_by(slack_id: user).payments
    payments = payments.where(status: 2)
    payments.each do |payment|
      unless payment.r_hash.nil?
        if lookup_ln_invoice(payment.r_hash).settled
          payment.status = 1
          payment.save
        end
      end
    end
  end
end
