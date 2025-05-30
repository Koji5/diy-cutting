# frozen_string_literal: true
# ------------------------------------------------------------
# DimensionValidator
#   GLOBAL_DIM_RULE（+ 形状別 dims_rule_json）を評価し
#   Part に寸法エラーを付与する共通バリデータ
# ------------------------------------------------------------
class DimensionValidator < ActiveModel::Validator
  # ======== 入口 ============================================
  def validate(record)
    rules = merged_rules(record)

    ctx = build_context(record)

    check_fields(rules[:fields]     || {}, record, ctx)
    check_relations(rules[:relations] || [], record, ctx)
    check_dynamic(rules[:dynamic]     || [], record, ctx)
  end

  # ======== ルールマージ (共通 + 形状) =======================
  def merged_rules(record)
    shape_extra = record.shape&.dims_rule_json&.deep_symbolize_keys || {}
    GLOBAL_DIM_RULE.deep_symbolize_keys.deep_merge(shape_extra)
  end
  private :merged_rules

  # ======== コンテキスト生成 (SafeEval 用) ===================
  def build_context(record)
    # ① モデルの属性（カラム直値）を投入
    ctx = record.attributes.symbolize_keys

    # ② store_accessor で定義したキーをすべて補完
    record.class.stored_attributes.values.flatten.each do |k|
      ctx[k.to_sym] = record.public_send(k)  # nil でもそのまま入れる
    end

    %i[tl tr bl br].each do |pos|
      # コーナー加工コード
      proc = record.public_send("corner_#{pos}")
      ctx["corner_#{pos}_code".to_sym] = proc&.dig("proc") || proc&.[]("code")

      # 丸穴フラグ
      hole = record.public_send("hole_#{pos}")
      ctx["hole_#{pos}_flag".to_sym] = hole&.dig("flag") || false

      # 四角穴フラグ
      sqh = record.public_send("sqhole_#{pos}")
      ctx["sqhole_#{pos}_flag".to_sym] = sqh&.dig("flag") || false
    end

    # ③ 丸穴径（自由入力優先／コード→径変換）
    %i[tl tr bl br].each do |pos|
      dia_mm = record.public_send("hole_#{pos}_dia_mm")
      dia_cd = record.public_send("hole_#{pos}_dia_code")
      ctx["hole_#{pos}_dia_mm_or_code".to_sym] =
        dia_mm.presence || HOLE_DIAMETERS[dia_cd]
    end

    ctx
  end
  private :build_context

  # ======== fields セクション ===============================
  def check_fields(defs, record, ctx)
    defs.each do |attr, cfg|
      val       = record[attr]
      required  = cfg[:required] ||
                  (cfg[:required_if] && SafeEval.evaluate(cfg[:required_if], ctx))

      if required && blank?(val)
        record.errors.add(attr, "を入力してください")
        next
      end
      next if blank?(val) # 任意入力で空ならスキップ

      if cfg[:min] && val.to_f < cfg[:min].to_f
        record.errors.add(attr, "は #{cfg[:min]}mm 以上にしてください")
      end
      if cfg[:max] && val.to_f > cfg[:max].to_f
        record.errors.add(attr, "は #{cfg[:max]}mm 以下にしてください")
      end
      if cfg[:integer_only] && val.present? && val.to_f % 1 != 0
        record.errors.add(attr, "は整数で入力してください")
      end
    end
  end
  private :check_fields

  # ======== relations セクション =============================
  def check_relations(list, record, ctx)
    list.each do |rel|
      next if rel[:if] && !SafeEval.evaluate(rel[:if], ctx)

      ok = SafeEval.evaluate(rel[:expr], ctx)
      record.errors.add(:base, "寸法関係エラー: #{rel[:expr]}") unless ok
    end
  end
  private :check_relations

  # ======== dynamic セクション (max_expr / min_expr) =========
  def check_dynamic(list, record, ctx)
    list.each do |r|
      # ルールの if 条件が false ならスキップ
      next if r[:if] && !SafeEval.evaluate(r[:if], ctx)

      target_val = record[r[:target]]
      next if target_val.blank? # 値が無いときは動的評価しない

      if r[:max_expr]
        max = SafeEval.evaluate(r[:max_expr], ctx)
        if target_val.to_f > max.to_f
          record.errors.add(r[:target], "は #{max}mm 以下にしてください")
        end
      end

      if r[:min_expr]
        min = SafeEval.evaluate(r[:min_expr], ctx)
        if target_val.to_f < min.to_f
          record.errors.add(r[:target], "は #{min}mm 以上にしてください")
        end
      end
    end
  end
  private :check_dynamic

  # ======== blank? helper ===================================
  def blank?(v)
    v.nil? || (v.respond_to?(:empty?) && v.empty?)
  end
  private :blank?
end
