class CreateChatStates < ActiveRecord::Migration
  def change
    create_table :chat_states do |t|
      t.references :match, index: true
      t.string :backend_url
      t.string :backend_http_url
      t.references :user1, index: true
      t.references :user2, index: true
      t.string :join_key1
      t.string :join_key2

      t.timestamps
    end
  end
end
