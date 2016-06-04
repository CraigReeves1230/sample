require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "test invalid signup" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: {name: "Craig Reeves", email: "foo@invalid", password: "foo", password_confirmation: "bar"}
    end
    assert_template 'users/new'
  end

end
