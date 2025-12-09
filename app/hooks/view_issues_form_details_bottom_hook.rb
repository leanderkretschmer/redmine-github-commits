module GithubCommits
  class ViewIssuesFormDetailsBottomHook < Redmine::Hook::ViewListener
    render_on :view_issues_form_details_bottom, partial: 'issues/repository_form'
  end
end

