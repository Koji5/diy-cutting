# app/models/concerns/auditable.rb
#
# == 概要
# 作成者・更新者の自動記録（UserStamp）と論理削除（Discardable）を
# ひとまとめにして、関連 (created_by/updated_by/deleted_by) も定義。
#
module Auditable
  extend ActiveSupport::Concern

  included do
    include UserStamp      # created_by_id / updated_by_id を自動セット
    include Discardable    # deleted_at / deleted_by_id / deleted_flag を連動

    # 監査用の関連（カラムが無いモデルでも optional 指定で安全）
    belongs_to :created_by, class_name: "Account", optional: true
    belongs_to :updated_by, class_name: "Account", optional: true
    belongs_to :deleted_by, class_name: "Account", optional: true

    # よく使うスコープを別名で（任意）
    scope :active, -> { kept }               # 未削除
    scope :deleted, -> { discarded }         # 論理削除済み
    scope :with_deleted, -> { with_discarded }
  end
end
