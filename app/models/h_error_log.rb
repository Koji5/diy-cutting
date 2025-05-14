class HErrorLog < ApplicationRecord
  self.table_name = 'h_error_logs'   # 明示すると安心
  # 追加のバリデーション等は不要（INSERT-only 前提）
end
