class Admin::UsersController < Admin::BaseController
  include UserPermissionsControllerMethods

  respond_to :html
  before_filter :set_user, only: [:edit, :update, :unlock]

  def index
    @users = User.order("created_at desc")
  end

  def edit
    @applications_and_permissions = applications_and_permissions(@user)
  end

  def update
    if @user.update_attributes(translate_faux_signin_permission(params[:user]), as: :admin)
      flash[:notice] = "Updated user #{@user.email} successfully"
      redirect_to admin_users_path
    else
      applications_and_permissions = applications_and_permissions(@user)
      respond_with @user
    end
  end

  def unlock
    @user.unlock_access!
    flash[:notice] = "Unlocked #{@user.email}"
    redirect_to admin_users_path
  end

  private
    def set_user
      @user = User.find(params[:id])
    end
end
