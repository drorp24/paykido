require 'test_helper'

class PayerRuleCategoriesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:payer_rule_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create payer_rule_category" do
    assert_difference('PayerRuleCategory.count') do
      post :create, :payer_rule_category => { }
    end

    assert_redirected_to payer_rule_category_path(assigns(:payer_rule_category))
  end

  test "should show payer_rule_category" do
    get :show, :id => payer_rule_categories(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => payer_rule_categories(:one).to_param
    assert_response :success
  end

  test "should update payer_rule_category" do
    put :update, :id => payer_rule_categories(:one).to_param, :payer_rule_category => { }
    assert_redirected_to payer_rule_category_path(assigns(:payer_rule_category))
  end

  test "should destroy payer_rule_category" do
    assert_difference('PayerRuleCategory.count', -1) do
      delete :destroy, :id => payer_rule_categories(:one).to_param
    end

    assert_redirected_to payer_rule_categories_path
  end
end
