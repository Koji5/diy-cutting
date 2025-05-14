class RatingJsonValidator < ActiveModel::EachValidator
  ALLOWED_KEYS = %w[quality support delivery].freeze
  RANGE        = (1..5).freeze

  def validate_each(record, attr, value)
    unless value.is_a?(Hash)
      record.errors.add(attr, 'は JSON オブジェクトである必要があります')
      return
    end

    unknown = value.keys - ALLOWED_KEYS
    record.errors.add(attr, "に未知のキー #{unknown} が含まれています") if unknown.present?

    ALLOWED_KEYS.each do |k|
      unless RANGE.cover?(value[k].to_i)
        record.errors.add(attr, "#{k} は 1〜5 の整数で入力してください")
      end
    end
  end
end
