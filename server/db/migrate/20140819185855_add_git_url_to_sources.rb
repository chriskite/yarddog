class AddGitUrlToSources < ActiveRecord::Migration
  def change
    add_column :sources, :git_url, :string
  end
end
