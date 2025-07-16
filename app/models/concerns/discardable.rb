# app/models/concerns/discardable.rb
module Discardable
  extend ActiveSupport::Concern
  include Discard::Model               # gem 本体

  included do
    self.discard_column = :deleted_at  # 既存カラムを利用

    # まだカラムがあるモデルだけ実行（respond_to? で安全に）
    before_discard do
      if respond_to?(:deleted_by_id=)
        self.deleted_by_id = Current.account.id
      end
      if respond_to?(:deleted_flag=)
        self.deleted_flag = true
      end
    end
    before_undiscard do
      if respond_to?(:deleted_by_id=)
        self.deleted_by_id = nil
      end
      if respond_to?(:deleted_flag=)
        self.deleted_flag = false
      end
    end
  end
end
