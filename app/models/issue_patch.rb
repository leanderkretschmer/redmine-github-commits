module GithubCommits
  module IssuePatch
    def self.included(base)
      base.class_eval do
        has_many :issue_repositories, dependent: :destroy, class_name: 'IssueRepository'
        has_many :git_commits, dependent: :destroy, class_name: 'GitCommit'
      end
    end
  end
end

Issue.send(:include, GithubCommits::IssuePatch) unless Issue.included_modules.include?(GithubCommits::IssuePatch)

