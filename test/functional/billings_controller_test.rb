require 'test_helper'

class BillingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:billings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create billing" do
    assert_difference('Billing.count') do
      post :create, :billing => { }
    end

    assert_redirected_to billing_path(assigns(:billing))
  end

  test "should show billing" do
    get :show, :id => billings(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => billings(:one).to_param
    assert_response :success
  end

  test "should update billing" do
    put :update, :id => billings(:one).to_param, :billing => { }
    assert_redirected_to billing_path(assigns(:billing))
  end

  test "should destroy billing" do
    assert_difference('Billing.count', -1) do
      delete :destroy, :id => billings(:one).to_param
    end

    assert_redirected_to billings_path
  end
end
