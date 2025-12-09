module GithubCommits
  class ViewIssuesShowTabsHook < Redmine::Hook::ViewListener
    render_on :view_issues_show_tabs, partial: 'issues/git_tab'
  end
end

