class AddFieldsToAlarmProximity < ActiveRecord::Migration
  def change
    add_column :alarm_locations, :location_id, :integer
    add_column :alarm_locations, :warns_on_in, :boolean, :default => true
    add_column :alarm_locations, :device_id, :integer
    add_column :alarm_locations, :current_state, :integer ,:default => false
    add_column :alarm_locations, :user_id, :integer
  end
end
