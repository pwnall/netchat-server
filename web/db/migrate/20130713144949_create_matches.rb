class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.boolean :rejected, null: true
      t.datetime :created_at, null: false
    end
  end
end
