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

