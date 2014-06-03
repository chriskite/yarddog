class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.sha1 :string
      t.tgz :attachment

      t.timestamps
    end
  end
end
