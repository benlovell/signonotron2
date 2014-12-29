class Superadmin::ApiUsersController < ApplicationController
  include UserPermissionsControllerMethods

  before_filter :authenticate_user!
  before_filter :load_api_user, only: [:edit, :update]
  helper_method :applications_and_permissions

  respond_to :html

  def new
    @api_user = ApiUser.new
  end

  def create
    password = SecureRandom.urlsafe_base64
    @api_user = ApiUser.new(params[:api_user].merge(password: password, password_confirmation: password))
    @api_user.skip_confirmation!
    @api_user.api_user = true

    if @api_user.save
      EventLog.record_event(@api_user, EventLog::API_USER_CREATED, current_user)
      redirect_to [:edit, :superadmin, @api_user], notice: "Successfully created API user"
    else
      render :new
    end
  end

  def index
    @api_users = ApiUser.includes(permissions: :application)
  end

  def update
    @api_user.skip_reconfirmation!

    if @api_user.update_attributes(translate_faux_signin_permission(params[:api_user]), as: current_user.role.to_sym)
      @api_user.permissions.reload
      PermissionUpdater.perform_on(@api_user)

      redirect_to [:superadmin, :api_users], notice: "Updated API user #{@api_user.email} successfully"
    else
      render :edit
    end
  end

private

  def load_api_user
    @api_user = ApiUser.find(params[:id])
  end
end
