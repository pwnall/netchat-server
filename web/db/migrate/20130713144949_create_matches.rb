class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.boolean :rejected, null: false
      t.datetime :created_at, null: false
    end
  end
end
