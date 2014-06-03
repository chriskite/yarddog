class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string :sha1
      t.attachment :tgz

      t.timestamps
    end
  end
end
