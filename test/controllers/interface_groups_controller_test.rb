require 'test_helper'

class InterfaceGroupsControllerTest < ActionController::TestCase
  setup do
    @interface_group = interface_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:interface_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create interface_group" do
    assert_difference('InterfaceGroup.count') do
      post :create, interface_group: { has_many: @interface_group.has_many, name: @interface_group.name }
    end

    assert_redirected_to interface_group_path(assigns(:interface_group))
  end

  test "should show interface_group" do
    get :show, id: @interface_group
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @interface_group
    assert_response :success
  end

  test "should update interface_group" do
    patch :update, id: @interface_group, interface_group: { has_many: @interface_group.has_many, name: @interface_group.name }
    assert_redirected_to interface_group_path(assigns(:interface_group))
  end

  test "should destroy interface_group" do
    assert_difference('InterfaceGroup.count', -1) do
      delete :destroy, id: @interface_group
    end

    assert_redirected_to interface_groups_path
  end
end
