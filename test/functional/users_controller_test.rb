require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "should_get_login" do
    get :login
    assert_response :success
  end

  test "should_login_successfully" do
    referer = 'http://test.host/'
    @request.env['HTTP_REFERER'] = referer
    assert_difference('User.count') do
      post(:login, {:username => "a", :password => "a"})
    end
    assert_equal "You have successfully logged in.", flash[:notice]
    assert_redirected_to referer
  end

  test "should_logout_successfully" do
    post(:logout, nil, {:user => "a"})
    assert_equal 'Logout successfull.', flash[:notice]
    assert_equal session[:user], nil
    assert_redirected_to "seminars/"
  end
end
