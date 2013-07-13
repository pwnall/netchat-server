class CreateQueueStates < ActiveRecord::Migration
  def change
    create_table :queue_states do |t|
      t.references :user, null: false
      t.string :join_key, limit: 64, null: false
      t.string :match_key, limit: 64, null: false
      t.string :backend_url, limit: 128, null: false
    end

    add_index :queue_states, :user_id, unique: true
  end
end
