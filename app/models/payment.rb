class Payment < ApplicationRecord
  belongs_to :user
end

# == Schema Information
#
# Table name: payments
#
#  id         :integer          not null, primary key
#  pay_req    :string
#  amount     :integer
#  status     :string
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_payments_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
