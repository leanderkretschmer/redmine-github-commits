module GithubCommits
  module IssuePatch
    def self.included(base)
      base.class_eval do
        has_many :issue_repositories, dependent: :destroy, class_name: 'IssueRepository'
      end
    end
  end
end

Issue.send(:include, GithubCommits::IssuePatch) unless Issue.included_modules.include?(GithubCommits::IssuePatch)

