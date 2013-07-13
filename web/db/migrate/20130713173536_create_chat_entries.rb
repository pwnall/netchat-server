class CreateChatEntries < ActiveRecord::Migration
  def change
    create_table :chat_entries do |t|
      t.references :user, null: false
      t.references :other_user, null: false
      t.references :match, null: false
      t.datetime :created_at, null: false
      t.datetime :closed_at, null: true
    end

    add_index :chat_entries, [:user_id, :created_at], unique: true
    add_index :chat_entries, :match_id, unique: false
  end
end
