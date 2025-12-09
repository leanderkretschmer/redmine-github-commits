class GitCommitsController < ApplicationController
  before_action :find_issue
  before_action :authorize
  
  def index
    @repositories = @issue.issue_repositories
    @commits = []
    
    # Sammle Commits von allen verknüpften Repositories
    @repositories.each do |repo|
      repo_commits = repo.fetch_commits(100)
      repo_commits.each { |c| c.issue_repository = repo }
      @commits.concat(repo_commits)
    end
    
    # Sortiere nach Datum (neueste zuerst)
    @commits.sort_by! { |c| c.committed_at || Time.at(0) }.reverse!
    @commits = @commits.first(100) # Limit auf 100
  end
  
  private
  
  def find_issue
    @issue = Issue.find(params[:issue_id])
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def authorize
    unless User.current.allowed_to?(:view_issues, @project)
      deny_access
    end
  end
end

