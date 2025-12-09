Redmine::Plugin.register :github_commits do
  name 'Github commits plugin'
  author 'Botree Technologies'
  description 'Redmine plugin to push github updates on Redmine issues directly via Github webhook'
  version '0.0.3'
  url 'https://github.com/BoTreeConsultingTeam/github_commits'
  author_url 'https://github.com/BoTreeConsultingTeam'
  
  requires_redmine :version_or_higher => '6.0.0'
end
