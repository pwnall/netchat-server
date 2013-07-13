class CreateChatStates < ActiveRecord::Migration
  def change
    create_table :chat_states do |t|
      t.references :match
      t.references :user1, index: true
      t.references :user2, index: true
      t.string :backend_url, null: false
      t.string :backend_http_url, null: false
      t.string :room_key, null: false
      t.string :join_key1, null: false
      t.string :join_key2, null: false

      t.timestamps
    end

    add_index :chat_states, :match_id, unique: true
  end
end
