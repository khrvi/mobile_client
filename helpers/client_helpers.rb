helpers do
  def authorized?
    @current_client ||= login_from_session
  end

  alias_method :current_client, :authorized?

  def login_from_session
    session[:client]
  end
end

