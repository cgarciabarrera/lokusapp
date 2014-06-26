class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :name
      t.integer :user_id
      t.integer :type_id
      t.float :last_lat
      t.float :last_lon
      t.datetime :last_fix
      t.boolean :active, :default => true
      t.boolean :available, :default => true


      t.timestamps
    end
  end
end
