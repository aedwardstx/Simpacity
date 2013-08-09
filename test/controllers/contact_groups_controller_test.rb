require 'test_helper'

class ContactGroupsControllerTest < ActionController::TestCase
  setup do
    @contact_group = contact_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contact_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contact_group" do
    assert_difference('ContactGroup.count') do
      post :create, contact_group: { description: @contact_group.description, email_addresses: @contact_group.email_addresses, name: @contact_group.name }
    end

    assert_redirected_to contact_group_path(assigns(:contact_group))
  end

  test "should show contact_group" do
    get :show, id: @contact_group
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contact_group
    assert_response :success
  end

  test "should update contact_group" do
    patch :update, id: @contact_group, contact_group: { description: @contact_group.description, email_addresses: @contact_group.email_addresses, name: @contact_group.name }
    assert_redirected_to contact_group_path(assigns(:contact_group))
  end

  test "should destroy contact_group" do
    assert_difference('ContactGroup.count', -1) do
      delete :destroy, id: @contact_group
    end

    assert_redirected_to contact_groups_path
  end
end
