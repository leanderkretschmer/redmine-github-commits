# IssueRepository ist jetzt ein einfaches Objekt ohne ActiveRecord
# Verwendet Custom Fields für die Speicherung
class IssueRepository
  CUSTOM_FIELD_PREFIX = 'github_repo_'
  
  attr_accessor :issue, :repository_url, :repository_name, :webhook_secret, :github_token
  
  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value) if respond_to?("#{key}=")
    end
  end
  
  def self.find_or_create_custom_field(name)
    field = IssueCustomField.find_by(name: name)
    return field if field
    
    field = IssueCustomField.new(
      name: name,
      field_format: 'string',
      is_required: false,
      is_for_all: true,
      is_filter: false,
      visible: true
    )
    field.save
    field
  end
  
  def self.for_issue(issue)
    return [] unless issue.present?
    
    repos = []
    # Suche nach Custom Fields die mit github_repo_ beginnen
    issue.custom_field_values.includes(:custom_field).each do |cfv|
      next unless cfv.custom_field&.name&.start_with?(CUSTOM_FIELD_PREFIX)
      next if cfv.value.blank?
      
      repo_data = parse_repository_data(cfv.value)
      next unless repo_data && repo_data[:url]
      
      repos << new(
        issue: issue,
        repository_url: repo_data[:url],
        repository_name: repo_data[:name] || extract_name_from_url(repo_data[:url]),
        webhook_secret: repo_data[:webhook_secret],
        github_token: repo_data[:github_token]
      )
    end
    
    repos
  end
  
  def self.parse_repository_data(value)
    # Format: "url|name|secret|token" oder einfach nur "url"
    parts = value.split('|')
    {
      url: parts[0],
      name: parts[1],
      webhook_secret: parts[2],
      github_token: parts[3]
    }
  end
  
  def self.extract_name_from_url(url)
    return nil unless url
    match = url.match(/github\.com[\/:]([^\/]+)\/([^\/]+?)(?:\.git)?\/?$/)
    return nil unless match
    "#{match[1]}/#{match[2]}"
  end
  
  def save
    return false unless issue && repository_url.present?
    
    require 'digest'
    
    field_name = "#{CUSTOM_FIELD_PREFIX}#{issue.id}_#{Digest::MD5.hexdigest(repository_url)[0..7]}"
    field = self.class.find_or_create_custom_field(field_name)
    
    value = [repository_url, repository_name, webhook_secret, github_token].compact.join('|')
    
    # Prüfe ob bereits vorhanden
    existing = issue.custom_field_values.find { |cfv| cfv.custom_field_id == field.id }
    
    if existing
      existing.value = value
      existing.save
    else
      issue.custom_field_values.build(
        custom_field: field,
        value: value
      )
    end
    
    issue.save
  end
  
  def destroy
    return false unless issue
    
    issue.custom_field_values.each do |cfv|
      if cfv.custom_field.name.start_with?(CUSTOM_FIELD_PREFIX) && 
         cfv.value&.start_with?(repository_url)
        cfv.destroy
      end
    end
    issue.save
  end
  
  # Extrahiert GitHub Repository-Informationen aus URL
  def github_owner_and_repo
    return nil unless repository_url&.include?('github.com')
    
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
