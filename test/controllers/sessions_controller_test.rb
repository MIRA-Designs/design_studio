require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should render new session page" do
    get new_session_url
    assert_response :success
    assert_select "form[action=?]", login_path
  end

  test "should log in with valid credentials" do
    user = users(:valid_user) # Assuming a valid user fixture exists
    post sessions_path, params: { email: user.email, password: "valid_password123" }
    assert_redirected_to (session.delete(:return_to_after_authenticating) || root_url)
    assert_equal "Logged in successfully.", flash[:notice]
  end

  test "should not log in with invalid credentials" do
    post sessions_path, params: { email: "invalid@example.com", password: "wrong_password" }
    assert_redirected_to new_session_path
    assert_equal "Try another email address or password.", flash[:alert]
  end

  test "should rate limit login attempts" do
    11.times do
      post sessions_path, params: { email: "invalid@example.com", password: "wrong_password" }
    end
    assert_redirected_to new_session_url
    assert_equal "Try again later.", flash[:alert]
  end

  test "should log out and redirect to new session path" do
    delete session_path # Assuming RESTful route for destroy action
    assert_redirected_to new_session_path
  end
end
