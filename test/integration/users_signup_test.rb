require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    @invalid_user = { name: "",
                      email: "user@invalid",
                      password: "foo",
                      password_confirmation: "bar" }

    @valid_user = { name: "example user",
                    email: "user@valid.com",
                    password: "pass1234",
                    password_confirmation: "pass1234" }

    @user_to_log_in = users(:anonymus)
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path #GET /signup

    assert_template "users/new"

    assert_no_difference "User.count" do
      post users_path, params: { user: @invalid_user }
    end

    assert_template "users/new"
    #message errors
    assert_select "span.sign-error"
  end

  test "valid signup information with account activation" do
    get signup_path #GET /signup
    assert_template "users/new"

    assert_difference "User.count", 1 do
      post users_path,
           params: { user: @valid_user }
    end

    assert_emails 1
    user = assigns(:user)
    assert_not user.activated?

    #log in before activation
    log_in_as(user)
    assert_not is_logged_in?
    #invalid token
    get edit_account_activation_path("randomtoken")
    assert_not is_logged_in?
    #valid token, wrong mail
    get edit_account_activation_path(user.activation_token, email: "randomemail")
    assert_not is_logged_in?
    #valid activation
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template "users/show"
    assert is_logged_in?
    # assert_select "div.alert-success>span", text: "🙋‍♀️ Welcome to TinyTweety"
    # assert_select "div.alert-success>button.popup-close", text: "❌"
  end

  test "should be close session if want register" do
    log_in_as(@user_to_log_in)
    get signup_path
    assert_redirected_to root_path
    assert_not flash.empty?
  end
end
