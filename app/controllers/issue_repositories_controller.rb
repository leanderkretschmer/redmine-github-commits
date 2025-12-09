class IssueRepositoriesController < ApplicationController
  before_action :find_issue
  before_action :authorize
  
  def create
    @repository = @issue.issue_repositories.build(repository_params)
    
    if @repository.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to issue_path(@issue)
    else
      flash[:error] = @repository.errors.full_messages.join(', ')
      redirect_to issue_path(@issue)
    end
  end
  
  def destroy
    @repository = @issue.issue_repositories.find(params[:id])
    @repository.destroy
    flash[:notice] = l(:notice_successful_delete)
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
  
  def repository_params
    params.require(:issue_repository).permit(:repository_url, :repository_name, :webhook_secret)
  end
end

