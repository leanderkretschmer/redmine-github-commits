# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

# Webhook endpoint
post 'github_commits/create_comment.json', to: 'github_commits#create_comment'

# Issue repository management
resources :issues do
  resources :issue_repositories, path: 'repositories', only: [:create, :destroy]
  resources :git_commits, path: 'commits', only: [:index]
end
