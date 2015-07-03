class AddStoreIdToApiTokens < ActiveRecord::Migration
  def change
    add_column :api_tokens, :store_id, :integer
  end
end
