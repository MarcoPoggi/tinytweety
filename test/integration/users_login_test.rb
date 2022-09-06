require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:anonymus)
  end

  test "login with invalid credentials" do
    get login_path
    assert_template "sessions/new"
    post login_path, params: { session: { email: "", password: "" } } #invalid
    assert_template "sessions/new"
    assert_not flash.empty?, "flash hash should be not empty"
    get root_path
    assert flash.empty?, "flash hash should be empty"
  end

  test "login with valid credentials" do
    get login_path
    post login_path, params: { session: { email: @user.email, password: "password" } }
    assert_redirected_to @user
    follow_redirect!
    assert_template "users/show" #profile
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
end
