require 'test_helper'

class GradingControllerTest < ActionController::TestCase
  test "should get identify_correct" do
    get :identify_correct
    assert_response :success
  end

  test "should get identify_incorrect" do
    get :identify_incorrect
    assert_response :success
  end

  test "should get verify" do
    get :verify
    assert_response :success
  end

end
