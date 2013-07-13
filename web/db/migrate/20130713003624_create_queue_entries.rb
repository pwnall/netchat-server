class CreateQueueEntries < ActiveRecord::Migration
  def change
    create_table :queue_entries do |t|
      t.references :user, index: true
      t.datetime :queued_at, null: false
      t.datetime :left_queue_at, null: true

      t.timestamps
    end

    add_index :queue_entries, [:user_id, :queued_at], unique: true
  end
end
