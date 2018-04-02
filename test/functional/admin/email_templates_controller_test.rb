require 'test_helper'

class Admin::EmailTemplatesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_email_templates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create email_template" do
    assert_difference('Admin::EmailTemplate.count') do
      post :create, :email_template => { }
    end

    assert_redirected_to email_template_path(assigns(:email_template))
  end

  test "should show email_template" do
    get :show, :id => admin_email_templates(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => admin_email_templates(:one).to_param
    assert_response :success
  end

  test "should update email_template" do
    put :update, :id => admin_email_templates(:one).to_param, :email_template => { }
    assert_redirected_to email_template_path(assigns(:email_template))
  end

  test "should destroy email_template" do
    assert_difference('Admin::EmailTemplate.count', -1) do
      delete :destroy, :id => admin_email_templates(:one).to_param
    end

    assert_redirected_to admin_email_templates_path
  end
end
