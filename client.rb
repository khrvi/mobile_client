require 'rubygems'
require 'sinatra'
require 'haml'
require './vendor/right_api_client/lib/right_api_client'

get '/deployments' do
  client = RightApiClient.new('email', 'password', 'account_id')
  @deployment = client.deployments(:filters => ['name==khrvi_Rails_app']).first
  haml :deployments
end

