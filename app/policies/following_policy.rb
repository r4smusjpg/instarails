class FollowingPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def destroy?
    user.present?
  end
end
