require 'test_helper'

class AlertsControllerTest < ActionController::TestCase
  setup do
    @alert = alerts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:alerts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create alert" do
    assert_difference('Alert.count') do
      post :create, alert: { contact_group_id: @alert.contact_group_id, days_out: @alert.days_out, description: @alert.description, enabled: @alert.enabled, int_type: @alert.int_type, link_type_id,: @alert.link_type_id,, match_regex: @alert.match_regex, name: @alert.name, percentile: @alert.percentile, watermark: @alert.watermark }
    end

    assert_redirected_to alert_path(assigns(:alert))
  end

  test "should show alert" do
    get :show, id: @alert
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @alert
    assert_response :success
  end

  test "should update alert" do
    patch :update, id: @alert, alert: { contact_group_id: @alert.contact_group_id, days_out: @alert.days_out, description: @alert.description, enabled: @alert.enabled, int_type: @alert.int_type, link_type_id,: @alert.link_type_id,, match_regex: @alert.match_regex, name: @alert.name, percentile: @alert.percentile, watermark: @alert.watermark }
    assert_redirected_to alert_path(assigns(:alert))
  end

  test "should destroy alert" do
    assert_difference('Alert.count', -1) do
      delete :destroy, id: @alert
    end

    assert_redirected_to alerts_path
  end
end
