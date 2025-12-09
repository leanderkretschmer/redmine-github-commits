module GithubCommits
  class ViewIssuesShowDescriptionBottomHook < Redmine::Hook::ViewListener
    render_on :view_issues_show_description_bottom, partial: 'issues/recent_commits_sidebar'
  end
end

