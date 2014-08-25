class CreateShareds < ActiveRecord::Migration
  def change
    create_table :shareds do |t|
      t.integer :device_id
      t.integer :user_id
      t.integer :user_shared_id

      t.boolean :visible, :default => true
      t.datetime :from_date
      t.datetime :to_date

      t.timestamps
    end
  end
end
