class CreateApiTokens < ActiveRecord::Migration
  def change
    create_table :api_tokens do |t|
      t.string :hex_value

      t.timestamps null: false
    end
  end
end
