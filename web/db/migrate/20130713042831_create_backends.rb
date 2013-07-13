class CreateBackends < ActiveRecord::Migration
  def change
    create_table :backends do |t|
      t.string :kind, limit: 16, null: false
      t.string :url, limit: 128, null: false
      t.string :http_url, limit: 128, null: false

      t.timestamps
    end
  end
end
