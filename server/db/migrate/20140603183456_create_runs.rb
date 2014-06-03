class CreateRuns < ActiveRecord::Migration
  def change
    create_table :runs do |t|
      t.references :source, index: true
      t.references :user, index: true
      t.string :instance_type

      t.timestamps
    end
  end
end
