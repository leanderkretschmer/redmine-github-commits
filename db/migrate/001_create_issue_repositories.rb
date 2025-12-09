class CreateIssueRepositories < ActiveRecord::Migration[6.0]
  def change
    create_table :issue_repositories do |t|
      t.references :issue, null: false, foreign_key: true, index: true
      t.string :repository_url, null: false
      t.string :repository_name, null: false
      t.string :webhook_secret, null: true
      t.timestamps
    end
    
    add_index :issue_repositories, :repository_url
  end
end

