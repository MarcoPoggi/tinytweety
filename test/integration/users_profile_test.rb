require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:anonymus)
  end

  test "profile display" do
    get user_path(@user)
    assert_template "users/show"
    assert_select "title", full_title(@user.name) #name | TinyTweety
    assert_select "section.profile-information>h1", text: @user.name
    assert_select "section.profile-information>a>img.user-gravatar"
    assert_match @user.posts.count.to_s, response.body
    assert_select "nav.pagination"

    @user.posts.page(1).per(10).each do |post|
      assert_match post.content, response.body
    end
  end
end
