class AddNewFieldsToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :imei, :string
    add_column :devices, :last_ack, :datetime
    add_column :devices, :position_status, :integer, :default => 0 #0 perdido 1 parado , 2 movimiento
    add_column :devices, :gps_status, :boolean, :default => false

  end
end
