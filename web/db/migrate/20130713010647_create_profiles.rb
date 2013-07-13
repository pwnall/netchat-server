class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.references :user
      t.string :name, null: false
    end
    # Enforce one profile per user.
    add_index :profiles, :user_id, unique: true
  end
end
