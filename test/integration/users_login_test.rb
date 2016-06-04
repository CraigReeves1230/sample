require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  # Bring in fixture
  def setup
    @test_user = users(:michael)
  end

  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path session: {email: "", password: ""}
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information" do
    get login_path # go to login screen
    assert_template # make sure it shows up
    post login_path session: {email: @test_user.email, password: 'abc123'} #post (form_for :sesssion) login info
    assert_redirected_to user_path(@test_user) # assert that we're redirected to user profile
    follow_redirect! # take us to redirect
    assert_template "users/show" #assert that the page shows up
    #assert that the header is correct once logged in
    assert_select "a[href=?]", login_path, count: 0 #there should be no login path
    assert_select "a[href=?]", logout_path #there SHOULD be a logout path
    assert_select "a[href=?]", user_path(@test_user) #there should also be a path for our user
  end

end
