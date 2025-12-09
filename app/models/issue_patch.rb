module GithubCommits
  module IssuePatch
    def self.included(base)
      base.class_eval do
        # Keine ActiveRecord-Assoziation mehr, verwenden Custom Fields
        def issue_repositories
          IssueRepository.for_issue(self)
        end
      end
    end
  end
end

Issue.send(:include, GithubCommits::IssuePatch) unless Issue.included_modules.include?(GithubCommits::IssuePatch)

