class AddColumnRHashToPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :r_hash, :string
  end
end
