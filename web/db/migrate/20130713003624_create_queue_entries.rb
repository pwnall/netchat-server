class CreateQueueEntries < ActiveRecord::Migration
  def change
    create_table :queue_entries do |t|
      t.references :user, null: false
      t.datetime :entered_at, null: false
      t.datetime :left_at, null: true
      t.boolean :abandoned, null: true
      t.references :match
    end

    add_index :queue_entries, [:user_id, :entered_at], unique: true
  end
end
