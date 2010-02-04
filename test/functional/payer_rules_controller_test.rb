require 'test_helper'

class PayerRulesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:payer_rules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create payer_rule" do
    assert_difference('PayerRule.count') do
      post :create, :payer_rule => { }
    end

    assert_redirected_to payer_rule_path(assigns(:payer_rule))
  end

  test "should show payer_rule" do
    get :show, :id => payer_rules(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => payer_rules(:one).to_param
    assert_response :success
  end

  test "should update payer_rule" do
    put :update, :id => payer_rules(:one).to_param, :payer_rule => { }
    assert_redirected_to payer_rule_path(assigns(:payer_rule))
  end

  test "should destroy payer_rule" do
    assert_difference('PayerRule.count', -1) do
      delete :destroy, :id => payer_rules(:one).to_param
    end

    assert_redirected_to payer_rules_path
  end
end
