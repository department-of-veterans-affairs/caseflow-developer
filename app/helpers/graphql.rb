require 'httparty'
require 'json'

module Graphql
  def Graphql.query(query_str, variables)
    Rails.logger.debug "Making graphql query: #{query_str} with variables #{variables}"

    response = HTTParty.post(
      'https://api.github.com/graphql', 
      headers: {
        'Authorization' => "bearer #{ENV['GITHUB_ACCESS_TOKEN']}", 
        'User-Agent' => 'HTTParty'
      }, 
      body: {
        query: query_str,
        variables: variables
      }.to_json,
      timeout: 20
    ).parsed_response

    Rails.logger.debug "Got graphql response: #{response}"

    if response['errors']
      raise "GraphQL query response had errors: #{response['errors']}"
    end

    response['data']
  end
end

