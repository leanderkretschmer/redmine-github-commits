class IssueRepository < ActiveRecord::Base
  belongs_to :issue
  
  validates :repository_url, presence: true, format: { with: /\Ahttps?:\/\/.+\z/, message: "muss eine gültige URL sein" }
  validates :repository_name, presence: true
  validates :issue_id, presence: true
  
  # Extrahiert GitHub Repository-Informationen aus URL
  def github_owner_and_repo
    return nil unless repository_url.include?('github.com')
    
    match = repository_url.match(/github\.com[\/:]([^\/]+)\/([^\/]+?)(?:\.git)?\/?$/)
    return nil unless match
    
    { owner: match[1], repo: match[2] }
  end
  
  def github_full_name
    info = github_owner_and_repo
    return nil unless info
    "#{info[:owner]}/#{info[:repo]}"
  end
  
  # Ruft Commits direkt von GitHub API ab
  def fetch_commits(limit = 100)
    return [] unless github_owner_and_repo
    
    info = github_owner_and_repo
    token = github_token.presence || ENV['GITHUB_API_TOKEN']
    GithubCommits::ApiClient.new(token).fetch_commits(info[:owner], info[:repo], limit)
  rescue => e
    Rails.logger.error "Failed to fetch commits: #{e.message}"
    []
  end
end


