class RemoveApiTokenFromStores < ActiveRecord::Migration
  def change
    remove_column :stores, :api_token
  end
end
