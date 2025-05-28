# app/models/concerns/user_stamp.rb
module UserStamp
  extend ActiveSupport::Concern

  included do
    before_create :stamp_creator
    before_save   :stamp_updater
  end

  private

  # 作成時
  def stamp_creator
    return unless Current.user
    if respond_to?(:created_by_id=)   # 列があるモデルだけ
      self.created_by_id ||= Current.user.id
    end
    if respond_to?(:updated_by_id=)
      self.updated_by_id ||= Current.user.id
    end
  end

  # 更新時
  def stamp_updater
    return unless Current.user
    if respond_to?(:updated_by_id=) && changed?
      self.updated_by_id = Current.user.id
    end
  end
end
