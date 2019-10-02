require 'test_helper'

class EmployeesControllerTest < ActionDispatch::IntegrationTest
  test "should get import" do
    get employees_import_url
    assert_response :success
  end

end
