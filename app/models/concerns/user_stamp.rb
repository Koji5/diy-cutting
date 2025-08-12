# app/models/concerns/account_stamp.rb
#
# == 概要
# モデルの created_by_id / updated_by_id カラムを自動で Current.account.id に設定する Concern
#
# == 使い方
# 1. このファイルを app/models/concerns/ に置く（ファイル名は account_stamp.rb）
# 2. モデルに include する
#    class BoardPart < ApplicationRecord
#      include UserStamp
#    end
# 3. モデルのテーブルに下記カラムが存在すること
#    - created_by_id :bigint
#    - updated_by_id :bigint
# 4. コントローラなどで Current.account をセットしておく
#    class ApplicationController < ActionController::Base
#      before_action :set_current_account
#
#      private
#      def set_current_account
#        Current.account = current_account # Devise等で取得
#      end
#    end
#
# == 動作
# - 新規作成時(before_create)に created_by_id / updated_by_id を自動設定（未指定の場合）
# - 更新時(before_save)に updated_by_id を自動設定（変更があった場合）
#
module UserStamp
  extend ActiveSupport::Concern

  included do
    before_create :stamp_creator
    before_save   :stamp_updater
  end

  private

  # 作成時
  def stamp_creator
    return unless Current.account
    if respond_to?(:created_by_id=)   # 列があるモデルだけ
      self.created_by_id ||= Current.account.id
    end
    if respond_to?(:updated_by_id=)
      self.updated_by_id ||= Current.account.id
    end
  end

  # 更新時
  def stamp_updater
    return unless Current.account
    if respond_to?(:updated_by_id=) && changed?
      self.updated_by_id = Current.account.id
    end
  end
end
