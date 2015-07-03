class AddApiTokenToStore < ActiveRecord::Migration
  def change
    add_column :stores, :api_token, :string
  end
end
