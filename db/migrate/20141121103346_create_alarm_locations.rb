class CreateAlarmLocations < ActiveRecord::Migration
  def change
    create_table :alarm_locations do |t|

      t.timestamps
    end
  end
end
