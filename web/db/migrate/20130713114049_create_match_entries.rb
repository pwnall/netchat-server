class CreateMatchEntries < ActiveRecord::Migration
  def change
    create_table :match_entries do |t|
      t.references :user, null: false
      t.references :other_user, null: false
      t.datetime :created_at, null: false
      t.datetime :closed_at, null: true
      t.boolean :rejected, null: true
    end

    add_index :match_entries, [:user_id, :created_at], unique: true
  end
end
