class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.json :customer_info
      t.json :items
      t.decimal :subtotal
      t.decimal :taxes
      t.decimal :total
      t.string :transaction_number
      t.integer :item_count
      t.string :payment_method
      t.decimal :tender_amount
      t.decimal :tip
      t.decimal :change_due

      t.timestamps null: false
    end
  end
end
