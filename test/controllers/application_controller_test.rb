require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to products path on home" do
    get root_path
    assert_redirected_to products_path
  end
end
