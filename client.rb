require 'rubygems'
require 'sinatra'
require 'haml'
require './vendor/right_api_client/lib/right_api_client'
enable :sessions

helpers do
  def authorized?
    @current_client ||= login_from_session
  end

  def current_client
    authorized?
  end

  def login_from_session
    session[:client]
  end
end

before do
  # Skip before filter
  if request.path_info == '/login'
    redirect to('/') if authorized?
  else
    redirect to('/login') unless authorized?
  end
end

get '/' do
  redirect to('/deployments')
end

get '/login' do
  haml :login
end

post '/login' do
  if client = RightApiClient.new(params[:email], params[:password], params[:account])
    puts client
    session[:client] = client
    redirect '/'
  else
    redirect '/login'
  end
end

get '/logout' do
  session.delete :client
  redirect to('login')
end

get '/deployments' do
  @deployment = current_client.deployments
  haml :deployments
end
