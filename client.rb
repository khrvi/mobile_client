require 'rubygems'
require 'sinatra'
require 'haml'
require './vendor/right_api_client/lib/right_api_client'
require './helpers/client_helpers'

enable :sessions

before do
  # Skip before filter
  if request.path_info == '/login'
    redirect to('/') if authorized?
  else
    redirect to('/login') unless authorized?
  end
end

get '/' do
  redirect to('api/deployments')
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

get '/api/deployments' do
  @deployments = current_client.deployments
  haml :"deployments/index"
end

get '/api/deployments/:id' do
  @deployment = Resource.process(self, *current_client.do_get("/api/deployments/#{params[:id]}"))
  haml :"deployments/show"
end

["inputs","servers"].each do |action|
  get "/api/deployments/:id/#{action}" do
    @deployment = Resource.process(self, *current_client.do_get("/api/deployments/#{params[:id]}"))
    @results = Resource.process(self, *current_client.do_get("/api/deployments/#{params[:id]}/#{action}"))
    haml :"deployments/#{action}"
  end
end

post "/api/deployments/:id/servers" do
  server_template_href = "/api/server_templates/65866"
  rackspace = current_client.clouds.first
    
  current_client.do_create("/api/deployments/#{params[:id]}" + "/servers", :server => {
    :name => params[:name],
      :deployment_href => "/api/deployments/#{params[:id]}",
      :instance => {
        :server_template_href => server_template_href,
        :cloud_href => rackspace.href
     }
   }
   )

  redirect to("/api/deployments/#{params[:id]}/servers")
end

delete "/api/servers/:id" do
  current_client.do_delete("/api/servers/#{params[:id]}")

  redirect to("/api/deployments/#{params[:id]}/servers")
end


# ------ Clouds ------
get '/api/clouds' do
  @clouds = current_client.clouds
  haml :'clouds/index'
end

get '/api/clouds/:id' do
  @cloud = Resource.process(self, *current_client.do_get('/api/clouds/' + params[:id]))
  haml :'clouds/show'
end
