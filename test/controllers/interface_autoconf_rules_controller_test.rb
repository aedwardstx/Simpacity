require 'test_helper'

class InterfaceAutoconfRulesControllerTest < ActionController::TestCase
  setup do
    @interface_autoconf_rule = interface_autoconf_rules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:interface_autoconf_rules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create interface_autoconf_rule" do
    assert_difference('InterfaceAutoconfRule.count') do
      post :create, interface_autoconf_rule: { description_regex: @interface_autoconf_rule.description_regex, enabled: @interface_autoconf_rule.enabled, link_type_id: @interface_autoconf_rule.link_type_id, name_regex: @interface_autoconf_rule.name_regex }
    end

    assert_redirected_to interface_autoconf_rule_path(assigns(:interface_autoconf_rule))
  end

  test "should show interface_autoconf_rule" do
    get :show, id: @interface_autoconf_rule
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @interface_autoconf_rule
    assert_response :success
  end

  test "should update interface_autoconf_rule" do
    patch :update, id: @interface_autoconf_rule, interface_autoconf_rule: { description_regex: @interface_autoconf_rule.description_regex, enabled: @interface_autoconf_rule.enabled, link_type_id: @interface_autoconf_rule.link_type_id, name_regex: @interface_autoconf_rule.name_regex }
    assert_redirected_to interface_autoconf_rule_path(assigns(:interface_autoconf_rule))
  end

  test "should destroy interface_autoconf_rule" do
    assert_difference('InterfaceAutoconfRule.count', -1) do
      delete :destroy, id: @interface_autoconf_rule
    end

    assert_redirected_to interface_autoconf_rules_path
  end
end
