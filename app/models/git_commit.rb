class GitCommit < ActiveRecord::Base
  belongs_to :issue_repository
  belongs_to :issue
  
  validates :sha, presence: true, uniqueness: { scope: :issue_repository_id }
  validates :message, presence: true
  validates :commit_url, presence: true
  validates :author_name, presence: true
  validates :author_email, presence: true
  
  scope :recent, -> { order(committed_at: :desc) }
  
  # Findet oder erstellt einen Commit
  def self.find_or_create_from_webhook(issue_repository, commit_data, repository_data)
    commit = find_or_initialize_by(
      sha: commit_data[:id],
      issue_repository_id: issue_repository.id
    )
    
    was_new = commit.new_record?
    
    commit.assign_attributes(
      issue_id: issue_repository.issue_id,
      message: commit_data[:message],
      commit_url: commit_data[:url],
      author_name: commit_data[:author][:name],
      author_email: commit_data[:author][:email],
      branch: extract_branch(repository_data[:ref]),
      committed_at: parse_timestamp(commit_data[:timestamp])
    )
    
    commit.save
    commit.instance_variable_set(:@was_new_record, was_new)
    commit
  end
  
  def was_new_record?
    @was_new_record == true
  end
  
  def self.extract_branch(ref)
    return nil unless ref
    ref.split("/").last
  end
  
  def self.parse_timestamp(timestamp_str)
    return Time.current unless timestamp_str
    Time.parse(timestamp_str) rescue Time.current
  end
end

