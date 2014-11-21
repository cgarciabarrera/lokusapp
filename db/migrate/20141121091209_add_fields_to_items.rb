class AddFieldsToItems < ActiveRecord::Migration
  def change
    create_table :items do |t|

      t.string :name
      t.decimal :price
      t.decimal :tax
      t.datetime :last_fix
      t.boolean :active, :default => true
      t.timestamps
    end


  end
end
