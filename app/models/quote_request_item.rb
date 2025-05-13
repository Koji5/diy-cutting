class QuoteRequestItem < ApplicationRecord
  belongs_to :quote_request
  belongs_to :quote_item   # 必須なので optional: false がデフォルト

  # ───────── バリデーション ─────────
  validates :quote_item_id,
            uniqueness: { scope: :quote_request_id }

  validates :unit_price,
            numericality: { greater_than_or_equal_to: 0 }

  validates :amount,
            numericality: { greater_than_or_equal_to: 0 }

  # ───────── コールバック ─────────
  before_validation :calc_amount

  private

  # 行単価 × 数量 → 小計
  def calc_amount
    return if quote_item.nil?               # 念のため nil ガード

    # BigDecimal 同士の演算にして精度を確保
    qty = quote_item.quantity.to_d
    self.amount = unit_price.to_d * qty
  end
end
