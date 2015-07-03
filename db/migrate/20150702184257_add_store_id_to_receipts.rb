class AddStoreIdToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :store_id, :integer
  end
end
