class AddDefaultValuesToLatLononDevices < ActiveRecord::Migration
  def change
    change_column :devices, :last_lat, :float, :default => 0
    change_column :devices, :last_lon, :float, :default => 0
  end

end
