require 'test_helper'

class SnmpsControllerTest < ActionController::TestCase
  setup do
    @snmp = snmps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:snmps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create snmp" do
    assert_difference('Snmp.count') do
      post :create, snmp: { community_string: @snmp.community_string }
    end

    assert_redirected_to snmp_path(assigns(:snmp))
  end

  test "should show snmp" do
    get :show, id: @snmp
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @snmp
    assert_response :success
  end

  test "should update snmp" do
    patch :update, id: @snmp, snmp: { community_string: @snmp.community_string }
    assert_redirected_to snmp_path(assigns(:snmp))
  end

  test "should destroy snmp" do
    assert_difference('Snmp.count', -1) do
      delete :destroy, id: @snmp
    end

    assert_redirected_to snmps_path
  end
end
