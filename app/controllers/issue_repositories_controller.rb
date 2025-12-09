class IssueRepositoriesController < ApplicationController
  before_action :find_issue
  before_action :authorize
  
  def create
    @repository = IssueRepository.new(
      issue: @issue,
      repository_url: params[:issue_repository][:repository_url],
      repository_name: params[:issue_repository][:repository_name],
      webhook_secret: params[:issue_repository][:webhook_secret],
      github_token: params[:issue_repository][:github_token]
    )
    
    if @repository.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to issue_path(@issue)
    else
      flash[:error] = 'Failed to save repository'
      redirect_to issue_path(@issue)
    end
  end
  
  def destroy
    repo_url = params[:repository_url] || params[:id]
    @repository = @issue.issue_repositories.find { |r| r.repository_url == repo_url }
    
    if @repository
      @repository.destroy
      flash[:notice] = l(:notice_successful_delete)
    else
      flash[:error] = 'Repository not found'
    end
    
    redirect_to issue_path(@issue)
  end
  
  private
  
  def find_issue
    @issue = Issue.find(params[:issue_id])
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def authorize
    unless @issue.editable?
      deny_access
    end
  end
end
