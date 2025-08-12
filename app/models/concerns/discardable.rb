# app/models/concerns/discardable.rb
#
# == 概要
# discard gem（論理削除）を既存の deleted_at / deleted_by_id / deleted_flag に
# あわせて使いやすくする Concern。
#
# == 使い方
# 1. Gem を導入（Gemfile）
#    gem "discard"
#
# 2. モデルに include する
#    class BoardPart < ApplicationRecord
#      include Discardable
#    end
#
# 3. 必要なカラム
#    - 必須: deleted_at :datetime(6)
#    - 任意: deleted_by_id :bigint, deleted_flag :boolean
#
# 4. コントローラで Current.account をセット
#    class ApplicationController < ActionController::Base
#      before_action :set_current_account
#      private
#      def set_current_account
#        Current.account = current_account # Devise等で取得
#      end
#    end
#
# 5. 主な使い方
#    record.discard     # => deleted_at を現在時刻に、（あれば）deleted_by_id / deleted_flag を更新
#    record.undiscard   # => deleted_at を nil に戻し、（あれば）deleted_by_id / deleted_flag を戻す
#    Model.kept         # => 未削除のみ
#    Model.discarded    # => 論理削除済みのみ
#
#    ※ discard は「未削除のみ」を返す default_scope(:kept) が有効です。
#      削除済みも含めて全件みたい場合は Model.with_discarded を使ってください。
#
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
