require 'HTTParty'
require 'json'

module Graphql
  def Graphql.query(query_str)
    HTTParty.post(
      'https://api.github.com/graphql', 
      headers: {
        'Authorization' => "bearer #{ENV['GITHUB_ACCESS_TOKEN']}", 
        'User-Agent' => 'HTTParty'
      }, 
      body: {
        query: query_str
      }.to_json
    ).parsed_response
  end
end

