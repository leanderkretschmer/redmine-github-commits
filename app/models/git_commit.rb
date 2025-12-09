# GitCommit ist jetzt ein einfaches Datenobjekt ohne ActiveRecord
class GitCommit
  attr_accessor :sha, :message, :commit_url, :author_name, :author_email, :branch, :committed_at, :issue_repository
  
  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value) if respond_to?("#{key}=")
    end
  end
  
  def self.from_github_api(commit_data, branch = nil)
    new(
      sha: commit_data[:sha] || commit_data['sha'],
      message: commit_data[:commit][:message] || commit_data['commit']['message'],
      commit_url: commit_data[:html_url] || commit_data['html_url'],
      author_name: commit_data[:commit][:author][:name] || commit_data['commit']['author']['name'],
      author_email: commit_data[:commit][:author][:email] || commit_data['commit']['author']['email'],
      branch: branch,
      committed_at: parse_timestamp(commit_data[:commit][:author][:date] || commit_data['commit']['author']['date'])
    )
  end
  
  def self.from_webhook(commit_data, repository_data)
    new(
      sha: commit_data[:id] || commit_data['id'],
      message: commit_data[:message] || commit_data['message'],
      commit_url: commit_data[:url] || commit_data['url'],
      author_name: commit_data[:author][:name] || commit_data['author']['name'],
      author_email: commit_data[:author][:email] || commit_data['author']['email'],
      branch: extract_branch(repository_data[:ref] || repository_data['ref']),
      committed_at: parse_timestamp(commit_data[:timestamp] || commit_data['timestamp'])
    )
  end
  
  def self.extract_branch(ref)
    return nil unless ref
    ref.split("/").last
  end
  
  def self.parse_timestamp(timestamp_str)
    return Time.current unless timestamp_str
    Time.parse(timestamp_str) rescue Time.current
  end
  
  def short_sha
    sha[0..7] if sha
  end
end
