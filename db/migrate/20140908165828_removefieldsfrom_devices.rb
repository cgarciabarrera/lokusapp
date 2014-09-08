class RemovefieldsfromDevices < ActiveRecord::Migration
  def change
    remove_column :devices, :last_lat
    remove_column :devices, :last_lon
    remove_column :devices, :last_fix

  end
end
