class Dashboard < Sinatra::Base 
	set :views, Proc.new { File.join(root, "views/dashboard") }

	get '/dashboard/index' do
		redirect to("/")
	end
	
end
