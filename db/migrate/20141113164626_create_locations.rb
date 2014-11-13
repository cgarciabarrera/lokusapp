class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.integer :user_id
      t.string :name
      t.float :lat
      t.float :lon
      t.integer :radius

      t.timestamps
    end
  end
end
