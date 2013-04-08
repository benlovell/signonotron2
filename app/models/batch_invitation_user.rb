class BatchInvitationUser < ActiveRecord::Base
  belongs_to :batch_invitation

  validates :outcome, inclusion: { :in => [nil, "success", "failed", "skipped"] }

  scope :processed, where("outcome IS NOT NULL")

  def invite(inviting_user, applications_and_permissions)
    attributes = {
      name: self.name,
      email: self.email,
      permissions_attributes: applications_and_permissions
    }
    if User.find_by_email(self.email)
      self.update_column(:outcome, "skipped")
    else
      begin
        User.invite!(attributes, inviting_user)
        self.update_column(:outcome, "success")
      rescue StandardError => e
        self.update_column(:outcome, "failed")
      end
    end
  end
end
