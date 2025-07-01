# frozen_string_literal: true
# ------------------------------------------------------------
# PartDimensionValidator
#   GLOBAL_DIM_RULE（+ 形状別 dims_rule_json）を評価し
#   Part に寸法エラーを付与する共通バリデータ
# ------------------------------------------------------------
class PartDimensionValidator < ActiveModel::Validator
  include GeometryChecks
  # ======== 入口 ============================================
  def validate(record)
    ctx   = build_context(record)          # ← 先に ctx を作る
    normalizedCtx = CtxNormalizer.call(ctx)
    record._outer = OuterShapeBuilder.build_outer_path(normalizedCtx)
    record._holes = HoleParamExtractor.build_holes(ctx)

    Rails.logger.debug "[CTX] #{ctx.inspect}"
    Rails.logger.debug "[NormalizedCTX] #{normalizedCtx.inspect}"
    rules = merged_rules(record)

    check_fields(rules[:fields]       || {}, record, ctx)
    check_relations(rules[:relations] || [], record, ctx)
    check_dynamic(rules[:dynamic]     || [], record, ctx)
    check_geometry(record, record._outer, record._holes)
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

    # ③ 丸穴径（自由入力優先／コード→径変換）
    %i[tl tr bl br].each do |pos|
      mm = record.public_send("hole_#{pos}_dia_mm")
      cd = record.public_send("hole_#{pos}_dia_code")
      ctx["hole_#{pos}_dia_mm_or_code".to_sym] =
        mm.presence || HOLE_DIAMETERS[cd]
    end

    # =========================================================
    # NEW ►  OuterShapeBuilder 用 :corners ハッシュを生成
    # =========================================================
    ctx[:corners] = {}.tap do |h|
      %i[tl tr bl br].each do |pos|
        h[pos] = {
          code: ctx["corner_#{pos}_code".to_sym] || "NONE",
          r:    ctx["corner_#{pos}_r".to_sym],
          dx:   ctx["corner_#{pos}_dx".to_sym],
          dy:   ctx["corner_#{pos}_dy".to_sym]
        }
      end
    end

    # ---- shapeCode 別の自動補完（JS buildCtx と同じロジック）----
    shape = ctx[:shape_code] || ctx[:shapeCode]

    case shape
    when "CIRC"
      ctx[:length_mm] = ctx[:width1_mm]                       # 直径＝巾1
      rc = ctx[:width1_mm].to_f / 2
      %i[tl tr bl br].each { |p| ctx["corner_#{p}_r".to_sym] ||= rc }

    when "SEMI"
      ctx[:length_mm] = ctx[:width1_mm] * 2                   # 直径
      r = ctx[:width1_mm].to_f
      %i[bl br].each { |p| ctx["corner_#{p}_r".to_sym] ||= r }

    when "TRI_EQ"
      ctx[:length_mm] = ctx[:width1_mm] * 2 / Math.sqrt(3)    # 正三角

    when "CORNER_TRI"
      ctx[:length_mm] = ctx[:width1_mm] * Math.sqrt(2)
      ctx[:corner_bl_r] ||= ctx[:width1_mm]                   # 左下角丸

    when "NICHE"
      ctx[:width2_mm] = record.width2_mm.to_f                 # 巾2 を補完
      # 角加工の自動設定が必要な場合はここに追記
    end

    # JS 側キーも入れておくとゴールデンテストで比較しやすい
    ctx[:shapeCode] = shape

    ctx
  end
  private :build_context

  # ======== fields セクション ===============================
  def check_fields(defs, record, ctx)
    defs.each do |attr, cfg|
      val = record.respond_to?(attr) ? record.public_send(attr) : ctx[attr]
      required  = cfg[:required] ||
                  (cfg[:required_if] && SafeEval.evaluate(cfg[:required_if], ctx))

      Rails.logger.debug("CHECK #{attr}: val=#{val.inspect} required=#{required}")  # ★追加
      
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
      record.errors.add(:base, "寸法関係エラー: #{rel[:message]}") unless ok
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
