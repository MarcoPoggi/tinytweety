require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @base_title = "TiniTweety"
  end

  test "should get home" do
    get root_url
    assert_response :success
    assert_select "title", text: @base_title
  end

  test "should get help" do
    get help_url
    assert_response :success
    assert_select "title", text: "Help | #{@base_title}"
  end

  test "should get about" do
    get about_url
    assert_response :success
    assert_select "title", text: "About | #{@base_title}"
  end

  test "should get contact" do
    get contact_url
    assert_response :success
    assert_select "title", text: "Contact | #{@base_title}"
  end
end
