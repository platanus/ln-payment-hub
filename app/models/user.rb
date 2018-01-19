class User < ApplicationRecord
  has_many :payments
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable
  validates :slack_id, presence: true, uniqueness: true

  def available_balance
    payments = self.payments.where(status: [0, 1])
    available_balance = 0
    payments.each do |payment|
      available_balance += payment.amount
    end
    available_balance
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  slack_id               :string
#
# Indexes
#
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
