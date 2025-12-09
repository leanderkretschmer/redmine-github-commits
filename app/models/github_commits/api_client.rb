module GithubCommits
  class ApiClient
    BASE_URL = 'https://api.github.com'
    
    def initialize(token = nil)
      @token = token || ENV['GITHUB_API_TOKEN']
    end
    
    def fetch_commits(owner, repo, limit = 100)
      return [] unless owner && repo
      
      require 'net/http'
      require 'json'
      
      url = "#{BASE_URL}/repos/#{owner}/#{repo}/commits?per_page=#{limit}"
      response = make_request(url)
      
      return [] unless response && response.is_a?(Array)
      
      response.map do |commit_data|
        GitCommit.from_github_api(commit_data)
      end
    rescue => e
      Rails.logger.error "GitHub API Error: #{e.message}"
      []
    end
    
    private
    
    def make_request(url)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10
      http.open_timeout = 10
      
      request = Net::HTTP::Get.new(uri)
      request['Accept'] = 'application/vnd.github.v3+json'
      request['Authorization'] = "token #{@token}" if @token
      
      response = http.request(request)
      
      case response.code.to_i
      when 200
        JSON.parse(response.body)
      when 404
        Rails.logger.warn "Repository not found: #{url}"
        nil
      when 403
        Rails.logger.error "GitHub API Rate limit or access denied: #{url}"
        nil
      else
        Rails.logger.error "GitHub API Error #{response.code}: #{response.body}"
        nil
      end
    end
  end
end

