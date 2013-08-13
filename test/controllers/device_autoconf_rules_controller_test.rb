require 'test_helper'

class DeviceAutoconfRulesControllerTest < ActionController::TestCase
  setup do
    @device_autoconf_rule = device_autoconf_rules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:device_autoconf_rules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create device_autoconf_rule" do
    assert_difference('DeviceAutoconfRule.count') do
      post :create, device_autoconf_rule: { enabled: @device_autoconf_rule.enabled, hostname_regex: @device_autoconf_rule.hostname_regex, mask: @device_autoconf_rule.mask, network: @device_autoconf_rule.network }
    end

    assert_redirected_to device_autoconf_rule_path(assigns(:device_autoconf_rule))
  end

  test "should show device_autoconf_rule" do
    get :show, id: @device_autoconf_rule
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @device_autoconf_rule
    assert_response :success
  end

  test "should update device_autoconf_rule" do
    patch :update, id: @device_autoconf_rule, device_autoconf_rule: { enabled: @device_autoconf_rule.enabled, hostname_regex: @device_autoconf_rule.hostname_regex, mask: @device_autoconf_rule.mask, network: @device_autoconf_rule.network }
    assert_redirected_to device_autoconf_rule_path(assigns(:device_autoconf_rule))
  end

  test "should destroy device_autoconf_rule" do
    assert_difference('DeviceAutoconfRule.count', -1) do
      delete :destroy, id: @device_autoconf_rule
    end

    assert_redirected_to device_autoconf_rules_path
  end
end
