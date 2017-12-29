class CreatePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :payments do |t|
      t.string :pay_req
      t.integer :amount
      t.string :status
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
