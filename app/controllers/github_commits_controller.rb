class GithubCommitsController < ApplicationController
   
  skip_before_action :check_if_login_required
  skip_before_action :verify_authenticity_token
  
  before_action :verify_signature?
  
  GITHUB_URL = "https://github.com/"
  REDMINE_ISSUE_NUMBER_PREFIX = "#rm"

  def create_comment
    resp_json = nil
    
    unless params[:commits].present? && params[:repository].present?
      return render json: {success: false, error: t('lables.no_commit_data_found')}, status: :ok
    end
    
    repository_data = {
      name: params[:repository][:name],
      full_name: params[:repository][:full_name],
      url: params[:repository][:html_url] || params[:repository][:url],
      ref: params[:ref]
    }
    
    # Finde verknüpfte Repositories basierend auf der Repository-URL
    issue_repositories = find_repositories_by_url(repository_data[:url])
    
    params[:commits].each do |commit_data|
      next unless commit_data[:distinct] == true # Nur neue Commits
      
      # 1. Verarbeite Commits für verknüpfte Repositories
      issue_repositories.each do |issue_repo|
        process_commit_for_repository(issue_repo, commit_data, repository_data)
      end
      
      # 2. Verarbeite Commits mit #rm123 Pattern (rückwärtskompatibel)
      if commit_data[:message].present? && commit_data[:message].include?(REDMINE_ISSUE_NUMBER_PREFIX)
        process_commit_with_pattern(commit_data, repository_data)
      end
    end
    
    render json: {success: true}, status: :ok
  end

  def verify_signature?
    # Prüfe ob ein Repository-spezifisches Secret vorhanden ist
    repository_secret = find_repository_secret_from_request
    
    secret_token = repository_secret || ENV["GITHUB_SECRET_TOKEN"]
    
    if request.env['HTTP_X_HUB_SIGNATURE'].blank? || secret_token.blank?
      render json: {success: false, error: 'Invalid signature'}, status: 500
      return false
    end
    
    request.body.rewind
    payload_body = request.body.read
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret_token, payload_body)
    
    unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
      render json: {success: false, error: 'Invalid signature'}, status: 500
      return false
    end
    
    true
  end

  private

  def find_repositories_by_url(repo_url)
    return [] unless repo_url.present?
    
    # Normalisiere URL (entferne .git, normalisiere Format)
    normalized_url = normalize_repository_url(repo_url)
    
    # Suche in allen Issues nach Repositories mit dieser URL
    repos = []
    Issue.joins(:custom_values).where(
      "custom_values.value LIKE ?", 
      "%#{normalized_url}%"
    ).each do |issue|
      issue.issue_repositories.each do |repo|
        if repo.repository_url == normalized_url || repo.repository_url == normalized_url + ".git"
          repos << repo
        end
      end
    end
    
    repos
  end
  
  def normalize_repository_url(url)
    return nil unless url.present?
    
    # Entferne .git am Ende falls vorhanden
    url = url.gsub(/\.git$/, '')
    # Stelle sicher, dass es mit http:// oder https:// beginnt
    url = "https://#{url}" unless url.match?(/\Ahttps?:\/\//)
    url
  end
  
  def find_repository_secret_from_request
    return nil unless params[:repository].present?
    
    repo_url = params[:repository][:html_url] || params[:repository][:url]
    return nil unless repo_url.present?
    
    normalized_url = normalize_repository_url(repo_url)
    repos = find_repositories_by_url(normalized_url)
    
    repos.first&.webhook_secret
  end

  def process_commit_for_repository(issue_repository, commit_data, repository_data)
    commit = GitCommit.from_webhook(commit_data, repository_data)
    create_journal_entry(issue_repository.issue, commit)
  end

  def process_commit_with_pattern(commit_data, repository_data)
    message = commit_data[:message]
    issue_id = message.partition(REDMINE_ISSUE_NUMBER_PREFIX).last.split(" ").first.to_i
    
    return if issue_id.zero?
    
    issue = Issue.find_by(id: issue_id)
    return unless issue.present?
    
    # Finde oder erstelle Repository-Verknüpfung für dieses Issue
    repo_url = repository_data[:url] || "#{GITHUB_URL}#{repository_data[:full_name]}"
    normalized_url = normalize_repository_url(repo_url)
    
    issue_repo = issue.issue_repositories.find { |r| r.repository_url == normalized_url }
    
    unless issue_repo
      issue_repo = IssueRepository.new(
        issue: issue,
        repository_url: normalized_url,
        repository_name: repository_data[:name] || repository_data[:full_name]
      )
      issue_repo.save
    end
    
    commit = GitCommit.from_webhook(commit_data, repository_data)
    create_journal_entry(issue, commit)
  end

  def create_journal_entry(issue, commit)
    email = EmailAddress.find_by(address: commit.author_email)
    user = email.present? ? email.user : User.where(admin: true).first
    
    notes = t('commit.message', 
              author: commit.author_name, 
              branch: commit.branch, 
              message: commit.message, 
              commit_id: commit.short_sha,
              commit_url: commit.commit_url)
    
    issue.init_journal(user, notes)
    issue.save
  end
end
