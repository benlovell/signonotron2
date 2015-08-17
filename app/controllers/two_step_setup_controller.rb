class TwoStepSetupController < ApplicationController
  before_filter :authenticate_user!, except: :show
  before_filter :authorize_user

  def show

  end

  def new
    # Set, but don't save a new key into the user. It will be POSTed back (from
    # a hidden field) and saved when/if they submit the form along with a
    # correct one-time-password.
    #
    # We don't want to save it yet because that would trash their existing
    # state.
    #
    # TODO we should think about encrypting/signing this value to prevent
    # tampering.
    current_user.otp_secret_key = ROTP::Base32.random_base32
  end

  def create
    # Note that we preserve the otp_secret_key so that the user can try again
    # if they submit the form. If they refresh it will reset though.
    current_user.otp_secret_key = params[:otp_secret_key]

    if current_user.authenticate_otp(params[:code])
      flash[:notice] = "Success!"
      current_user.save!
      redirect_to '/'
    else
      flash[:alert] = "Failed"
      render :new
    end
  end

  # def edit
  #   if current_user.otp_secret_key.blank?
  #     redirect_to new_path
  #   else
  #   end
  # end

  # def update
  # end

  def destroy
    current_user.reset_two_factor_authentication!
  end

private

  def authorize_user
    authorize current_user
  end
end
