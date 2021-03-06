ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # returns true if a test user is logged in
  def is_logged_in?
    !session[:user_id].nil?
  end

  # logs in a test user
  def log_in_as(user, options = {})
    password = options[:password] || 'password'
    remember_me = options[:remember_me] || '1'
    if integration_test?
      post login_path, session: {email: user.email, password: user.password, remember_me: remember_me}
    else
      session[:user_id] = user.id
    end
  end

  # returns whether or not this is an integration test by determining if post_via_redirect works
  def integration_test?
    defined?(post_via_redirect)
  end

  # returns the full title
  def full_title(string)
    string + " | Ruby on Rails Tutorial Sample App"
  end

end
