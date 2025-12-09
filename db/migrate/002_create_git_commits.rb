class CreateGitCommits < ActiveRecord::Migration[6.0]
  def change
    create_table :git_commits do |t|
      t.references :issue_repository, null: false, foreign_key: true, index: true
      t.references :issue, null: false, foreign_key: true, index: true
      t.string :sha, null: false
      t.text :message, null: false
      t.string :commit_url, null: false
      t.string :author_name, null: false
      t.string :author_email, null: false
      t.string :branch
      t.datetime :committed_at, null: false
      t.timestamps
    end
    
    add_index :git_commits, [:issue_repository_id, :sha], unique: true
    add_index :git_commits, [:issue_id, :committed_at]
  end
end

