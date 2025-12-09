Redmine::Plugin.register :github_commits do
  name 'Github commits plugin'
  author 'Botree Technologies'
  description 'Redmine plugin to link GitHub repositories with issues and track commits'
  version '0.1.0'
  url 'https://github.com/BoTreeConsultingTeam/github_commits'
  author_url 'https://github.com/BoTreeConsultingTeam'
  
  requires_redmine :version_or_higher => '6.0.0'
end

# Lade Patches und Models
Rails.configuration.to_prepare do
  require_dependency 'issue_patch'
  require_dependency 'issue_repository'
  require_dependency 'git_commit'
end
