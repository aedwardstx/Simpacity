require 'test_helper'

class MeasurementsControllerTest < ActionController::TestCase
  setup do
    @measurement = measurements(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:measurements)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create measurement" do
    assert_difference('Measurement.count') do
      post :create, measurement: { collectedAt: @measurement.collectedAt, interface: @measurement.interface, period: @measurement.period, rx: @measurement.rx, sharedRiskLinkGroup: @measurement.sharedRiskLinkGroup, tx: @measurement.tx }
    end

    assert_redirected_to measurement_path(assigns(:measurement))
  end

  test "should show measurement" do
    get :show, id: @measurement
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @measurement
    assert_response :success
  end

  test "should update measurement" do
    patch :update, id: @measurement, measurement: { collectedAt: @measurement.collectedAt, interface: @measurement.interface, period: @measurement.period, rx: @measurement.rx, sharedRiskLinkGroup: @measurement.sharedRiskLinkGroup, tx: @measurement.tx }
    assert_redirected_to measurement_path(assigns(:measurement))
  end

  test "should destroy measurement" do
    assert_difference('Measurement.count', -1) do
      delete :destroy, id: @measurement
    end

    assert_redirected_to measurements_path
  end
end
