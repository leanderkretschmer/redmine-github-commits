class CreateIssueRepositories < ActiveRecord::Migration[6.0]
  def self.up
    unless table_exists?(:issue_repositories)
      create_table :issue_repositories do |t|
        t.integer :issue_id, null: false
        t.string :repository_url, null: false, limit: 500
        t.string :repository_name, null: false, limit: 255
        t.string :webhook_secret, null: true, limit: 255
        t.string :github_token, null: true, limit: 255  # Für private Repos
        t.timestamps
      end
      
      add_index :issue_repositories, :issue_id
      add_index :issue_repositories, :repository_url
    end
  end

  def self.down
    drop_table :issue_repositories if table_exists?(:issue_repositories)
  end
end

