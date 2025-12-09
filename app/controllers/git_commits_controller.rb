class GitCommitsController < ApplicationController
  before_action :find_issue
  before_action :authorize
  
  def index
    @repositories = @issue.issue_repositories.includes(:git_commits)
    @commits = GitCommit.where(issue_id: @issue.id)
                       .includes(:issue_repository)
                       .recent
                       .limit(100)
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

