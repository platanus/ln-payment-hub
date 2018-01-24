class AddFeeToPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :fee, :integer
  end
end
