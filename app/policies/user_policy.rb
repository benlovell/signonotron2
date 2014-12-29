class UserPolicy < BasePolicy

  def new?
    current_user.superadmin? || current_user.admin? || current_user.organisation_admin?
  end

  def create?
    new?
  end

  def index?
    new?
  end

  def edit?
    return current_user.superadmin? if record.api_user?

    case current_user.role
    when 'superadmin'
      true
    when 'admin'
      !record.superadmin?
    when 'organisation_admin'
      record.normal? && current_user.organisation.subtree.pluck(:id).include?(record.organisation_id)
    when 'normal'
      current_user.id == record.id
    end
  end

  def update?
    edit?
  end

  def event_logs?
    current_user.normal? ? false : edit?
  end

  def suspension?
    edit?
  end

  class Scope < Scope
    def resolve
      if current_user.superadmin?
        scope.web_users
      elsif current_user.admin?
        scope.web_users.where(role: %w(admin organisation_admin normal))
      elsif current_user.organisation_admin?
        scope.web_users.where(role: %w(organisation_admin normal)).where(organisation_id: current_user.organisation_id)
      end
    end
  end
end
