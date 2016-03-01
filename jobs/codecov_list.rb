require 'httparty'
require 'octokit'
require 'dotenv'
Dotenv.load

projects = [
  { user: '', repo: '', branch: '' }
]

# For future reference we should probably use 'outcome' rather than 'status'
def translate_coverage_to_class(commits)
  if (commits.last[:coverage].to_f - commits.first[:coverage].to_f).round(2) >= ENV['CODECOV_TOLERANCE'].to_f
    return :falling
  elsif (commits.first[:coverage].to_f - commits.last[:coverage].to_f).round(2) <= -ENV['CODECOV_TOLERANCE'].to_f
    return :rising
  else
    return :flat
  end
end

def update_coverage(project, auth_token)
  api_url = 'https://codecov.io/api/%s/%s/%s/commits?branch=%s&access_token=%s'
  api_url = api_url % [ENV['CODECOV_SOURCE'], project[:user], project[:repo], project[:branch], auth_token]
  api_response =  HTTParty.get(api_url, :headers => { "Accept" => "application/json" } )
  api_json = JSON.parse(api_response.body, symbolize_names: true)
  return {} if api_json.empty?

  # For future reference we should probably use 'lifecycle' rather than 'status'
  commits = api_json[:commits]
  return {} unless commits
  commits.select! { |c| c[:branch] == project[:branch]}
  latest_build = commits.first
  return {} unless latest_build

  committer = latest_build[:username]
  client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
  github_user = client.user(committer)

  recent_commits = commits.first(ENV['CODECOV_HORIZON'].to_i)
  data = {
    repo: "#{project[:repo]}",
    branch: "#{latest_build[:branch]}",
    coverage: "%02f%" % latest_build[:coverage].to_f,
    coverage_change: "%+0.2f%" % (recent_commits.first[:coverage].to_f - recent_commits.last[:coverage].to_f),
    widget_class: "#{translate_coverage_to_class(recent_commits)}",
    avatar_url: github_user[:avatar_url],
    username: github_user[:name]
  }
  return data
end

SCHEDULER.every '60s', :first_in => 0  do
  items = projects.map{ |p| update_coverage(p, ENV['CODECOV_TOKEN']) }
  send_event('codecov-list', items: items)
end
