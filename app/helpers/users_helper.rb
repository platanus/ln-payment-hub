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

module UsersHelper
  def register_user(slack_id)
    user = User.new
    user.slack_id = slack_id
    user.save
  end
end
