class AddInstanceRefToRuns < ActiveRecord::Migration
  def change
    add_reference :runs, :instance, index: true
  end
end
