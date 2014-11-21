class ChangePrecision < ActiveRecord::Migration
  def change
    change_column :items, :price, :decimal, :default => 0, :precision => 8, :scale => 2

  end
end
