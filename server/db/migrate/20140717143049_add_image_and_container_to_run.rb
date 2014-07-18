class AddImageAndContainerToRun < ActiveRecord::Migration
  def change
    add_column :runs, :image_id, :string
    add_column :runs, :container_id, :string
  end
end
