module SessionsHelper

  # Logs in the given user
  def log_in(user)
    session[:user_id] = user.id
  end

  # returns the current user
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by id: session[:user_id]
      # if there is no session in place, look for cookies
    elsif cookies.signed[:user_id]
      temp_user = User.find_by id: cookies.signed[:user_id]
      if temp_user && temp_user.authenticated?(cookies[:remember_token])
        @current_user = temp_user
      end
    end
  end

  # returns if the user in question is the current user
  def current_user?(user)
    current_user == user
  end

  # Returns if the user is logged in
  def logged_in?
    !current_user.nil?
  end

  # logs user out
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  #remembers a user in a persistent session
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # forgets a user in a persistent session and deletes the cookies
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # redirects to stored location (or to the default)
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end

end