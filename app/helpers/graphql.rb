require 'HTTParty'
require 'json'

module Graphql
  def Graphql.query(query_str, variables)
    Rails.logger.debug "Making graphql query: #{query_str} with variables #{variables}"
    HTTParty.post(
      'https://api.github.com/graphql', 
      headers: {
        'Authorization' => "bearer #{ENV['GITHUB_ACCESS_TOKEN']}", 
        'User-Agent' => 'HTTParty'
      }, 
      body: {
        query: query_str,
        variables: variables
      }.to_json
    ).parsed_response['data']
  end
end

