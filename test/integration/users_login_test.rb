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

  test "login with valid credentials & logout" do
    get login_path
    post login_path, params: { session: { email: @user.email, password: "password" } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template "users/show" #profile
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)

    #logout
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_path # redirect to "/"
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0

    #simulate a user logout in another window
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "authenticated method should return false for a user with nil digest token" do
    assert_not @user.authenticated?(:remember,  "")
  end

  test "login with remember password" do
    log_in_as(@user, remember_me: "1")
    assert_not_nil cookies["remember_token"]
  end

  test "login without remember password" do
    log_in_as(@user, remember_me: "0")
    assert_nil cookies["remember_token"]
  end
end
