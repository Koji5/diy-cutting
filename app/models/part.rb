class Part < ApplicationRecord
  include Discardable
  require "stringio"
  # ─────────────────────────────
  # 関連
  # ─────────────────────────────
  belongs_to :user

  belongs_to :material_category,
             class_name:  'MCategory',
             foreign_key: :material_category_code,
             primary_key: :code

  belongs_to :material,
             class_name:  'MMaterial',
             foreign_key: :material_code,
             primary_key: :code

  belongs_to :shape,
             class_name:  'MShape',
             foreign_key: :shape_code,
             primary_key: :code

  # ──────────── JSON 由来の関連 ────────────
  # ペイント種別
  belongs_to :paint_type,
             class_name:  'MPaintType',
             foreign_key: :paint_type_code,
             primary_key: :code,
             optional:    true

  # コーナー加工（四隅）
  belongs_to :corner_tl_process, class_name: 'MCornerProcess', foreign_key: :corner_tl_code, primary_key: :code, optional: true
  belongs_to :corner_tr_process, class_name: 'MCornerProcess', foreign_key: :corner_tr_code, primary_key: :code, optional: true
  belongs_to :corner_bl_process, class_name: 'MCornerProcess', foreign_key: :corner_bl_code, primary_key: :code, optional: true
  belongs_to :corner_br_process, class_name: 'MCornerProcess', foreign_key: :corner_br_code, primary_key: :code, optional: true

  # 丸穴径（四隅）
  belongs_to :hole_tl_diameter, class_name: 'MHoleDiameter', foreign_key: :hole_tl_dia_code, primary_key: :code, optional: true
  belongs_to :hole_tr_diameter, class_name: 'MHoleDiameter', foreign_key: :hole_tr_dia_code, primary_key: :code, optional: true
  belongs_to :hole_bl_diameter, class_name: 'MHoleDiameter', foreign_key: :hole_bl_dia_code, primary_key: :code, optional: true
  belongs_to :hole_br_diameter, class_name: 'MHoleDiameter', foreign_key: :hole_br_dia_code, primary_key: :code, optional: true

  # 断面エッジ加工（8 辺）
  belongs_to :edge_tl_process, class_name: 'MEdgeProcess', foreign_key: :edge_tl_code, primary_key: :code, optional: true
  belongs_to :edge_t_process,  class_name: 'MEdgeProcess', foreign_key: :edge_t_code,  primary_key: :code, optional: true
  belongs_to :edge_tr_process, class_name: 'MEdgeProcess', foreign_key: :edge_tr_code, primary_key: :code, optional: true
  belongs_to :edge_l_process,  class_name: 'MEdgeProcess', foreign_key: :edge_l_code,  primary_key: :code, optional: true
  belongs_to :edge_r_process,  class_name: 'MEdgeProcess', foreign_key: :edge_r_code,  primary_key: :code, optional: true
  belongs_to :edge_bl_process, class_name: 'MEdgeProcess', foreign_key: :edge_bl_code, primary_key: :code, optional: true
  belongs_to :edge_b_process,  class_name: 'MEdgeProcess', foreign_key: :edge_b_code,  primary_key: :code, optional: true
  belongs_to :edge_br_process, class_name: 'MEdgeProcess', foreign_key: :edge_br_code, primary_key: :code, optional: true

  # 塗装加工
  belongs_to :paint_surface,  class_name: 'MPaintSurface',  foreign_key: :paint_surface_code,  primary_key: :code, optional: true
  belongs_to :paint_color,    class_name: 'MPaintColor',    foreign_key: :paint_color_code,    primary_key: :code, optional: true
  belongs_to :grain_finish,   class_name: 'MGrainFinish',  foreign_key: :grain_finish_code,   primary_key: :code, optional: true
  belongs_to :gloss,          class_name: 'MGloss',        foreign_key: :gloss_code,          primary_key: :code, optional: true

  belongs_to :origin_owner,
             class_name:  'User',
             foreign_key: :origin_owner_id,
             optional:    true

  # ─────────────────────────────
  # サムネイル画像
  # ─────────────────────────────
  has_one_attached :thumbnail
  attr_accessor :_outer, :_holes
  attr_accessor :thumbnail_data   # 仮想属性（form から受け取るだけ）
  before_validation :attach_thumbnail_from_base64, if: -> { thumbnail_data.present? }
  after_commit :sync_thumbnail, on: %i[create update]
  after_commit :generate_thumbnail_variant, on: [:create, :update]
  after_discard :purge_thumbnail!

  # ─────────────────────────────
  # JSONB アクセサ
  # ─────────────────────────────
  # 1) 平面形状（shape_json）
  store_accessor :shape_json,
                 :shape_tl_r, :shape_tr_r, :shape_bl_r, :shape_br_r

  # 2) コーナー加工（corner_proc_json）
  store_accessor :corner_proc_json,
                 :corner_tl_code, :corner_tr_code, :corner_bl_code, :corner_br_code,
                 :corner_tl_r,    :corner_tr_r,    :corner_bl_r,    :corner_br_r,
                 :corner_tl_dx,   :corner_tr_dx,   :corner_bl_dx,   :corner_br_dx,
                 :corner_tl_dy,   :corner_tr_dy,   :corner_bl_dy,   :corner_br_dy

  # 3) 丸穴（hole_json）
  store_accessor :hole_json,
                 :hole_tl_flag, :hole_tr_flag, :hole_bl_flag, :hole_br_flag,
                 :hole_tl_dia_code, :hole_tr_dia_code, :hole_bl_dia_code, :hole_br_dia_code,
                 :hole_tl_dia_mm,   :hole_tr_dia_mm,   :hole_bl_dia_mm,   :hole_br_dia_mm,
                 :hole_tl_dx,       :hole_tr_dx,       :hole_bl_dx,       :hole_br_dx,
                 :hole_tl_dy,       :hole_tr_dy,       :hole_bl_dy,       :hole_br_dy

  # 4) 四角穴（sqhole_json）
  store_accessor :sqhole_json,
                 :sqhole_tl_flag, :sqhole_tr_flag, :sqhole_bl_flag, :sqhole_br_flag,
                 :sqhole_tl_dx,   :sqhole_tr_dx,   :sqhole_bl_dx,   :sqhole_br_dx,
                 :sqhole_tl_dy,   :sqhole_tr_dy,   :sqhole_bl_dy,   :sqhole_br_dy,
                 :sqhole_tl_h,    :sqhole_tr_h,    :sqhole_bl_h,    :sqhole_br_h,
                 :sqhole_tl_w,    :sqhole_tr_w,    :sqhole_bl_w,    :sqhole_br_w

  # 5) 断面加工（edge_json）
  store_accessor :edge_json,
                 :edge_tl_code, :edge_t_code, :edge_tr_code,
                 :edge_l_code,                :edge_r_code,
                 :edge_bl_code, :edge_b_code, :edge_br_code

  # 6) 塗装加工（paint_json）
  store_accessor :paint_json,
                 :paint_surface_code, :paint_color_code, :grain_finish_code, :gloss_code

  # ─────────────────────────────
  # 型正規化
  # ─────────────────────────────
  before_validation :normalize_types

  BOOLEAN_FLAGS = %i[
    hole_tl_flag hole_tr_flag hole_bl_flag hole_br_flag
    sqhole_tl_flag sqhole_tr_flag sqhole_bl_flag sqhole_br_flag
  ].freeze

  STRING_OPTIONALS = %i[
    name note
    corner_tl_code corner_tr_code corner_bl_code corner_br_code
    hole_tl_dia_code hole_tr_dia_code hole_bl_dia_code hole_br_dia_code
    paint_type_code paint_surface_code paint_color_code
    grain_finish_code gloss_code
  ].freeze

  NUMERIC_FIELDS = %i[
    thickness_mm width1_mm width2_mm length_mm
    shape_tl_r shape_tr_r shape_bl_r shape_br_r
    corner_tl_r corner_tr_r corner_bl_r corner_br_r
    corner_tl_dx corner_tr_dx corner_bl_dx corner_br_dx
    corner_tl_dy corner_tr_dy corner_bl_dy corner_br_dy
    hole_tl_dia_mm hole_tr_dia_mm hole_bl_dia_mm hole_br_dia_mm
    hole_tl_dx hole_tr_dx hole_bl_dx hole_br_dx
    hole_tl_dy hole_tr_dy hole_bl_dy hole_br_dy
    sqhole_tl_dx sqhole_tr_dx sqhole_bl_dx sqhole_br_dx
    sqhole_tl_dy sqhole_tr_dy sqhole_bl_dy sqhole_br_dy
    sqhole_tl_h  sqhole_tr_h  sqhole_bl_h  sqhole_br_h
    sqhole_tl_w  sqhole_tr_w  sqhole_bl_w  sqhole_br_w
  ].freeze

  NUMERIC_REGEX = /\A[+-]?(?:\d+|\d+\.\d*|\d*\.\d+)(?:[eE][+-]?\d+)?\z/

  def normalize_types
    # ① "0"/"1"→true/false
    BOOLEAN_FLAGS.each do |attr|
      value = case public_send(attr).to_s
      when "1", "true"  then true
      when "0", "false" then false
      else nil
      end
      public_send("#{attr}=", value)
    end

    # ② 空文字→nil
    STRING_OPTIONALS.each do |attr|
      val = public_send(attr)
      public_send("#{attr}=", nil) if val.is_a?(String) && val.strip.empty?
    end

    # ③ 文字列→数値→不正文字列は nil
    NUMERIC_FIELDS.each do |attr|
      v_str = public_send(attr).to_s.tr("０-９．＋－","0-9.+-")
      if v_str.blank?
        public_send("#{attr}=", nil)            # ← 空は nil に
      else
        num = NUMERIC_REGEX.match?(v_str) ? Float(v_str) : nil
        public_send("#{attr}=", num)
      end
    end
  end

  # ─────────────────────────────
  # カメラ位置
  # ─────────────────────────────
  before_validation :assign_camera_state
  def camera_state_json=(v)
    @camera_state_json = v
  end
  def assign_camera_state
    self.camera_state = JSON.parse(@camera_state_json) if @camera_state_json.present?
  end

  # ─────────────────────────────
  # キャッシュ付きユーティリティ
  # ─────────────────────────────
  def self.master_codes(klass)
    Rails.cache.fetch("#{klass.name.underscore}/codes") { klass.pluck(:code) }
  end


  # ─────────────────────────────
  # バリデーション
  # ─────────────────────────────
  validates_with PartDimensionValidator

  validates :name, presence: true, length: { maximum: 50 }

  validates :material_category_code,
            presence: true,
            inclusion: { in: ->(_) { master_codes(MCategory) } }

  validates :material_code,
            inclusion: { in: ->(_) { master_codes(MMaterial) } }

  validates :shape_code,
            presence: true,
            inclusion: { in: ->(_) { master_codes(MShape) } }

  validates :paint_type_code,
            inclusion: { in: ->(_) { master_codes(MPaintType) } },
            allow_nil: true

  validates :corner_tl_code, :corner_tr_code, :corner_bl_code, :corner_br_code,
            inclusion: { in: ->(_) { master_codes(MCornerProcess) } },
            allow_blank: true

  validates :hole_tl_dia_code, :hole_tr_dia_code, :hole_bl_dia_code, :hole_br_dia_code,
            inclusion: { in: ->(_) { master_codes(MHoleDiameter) } },
            allow_blank: true

  validates :edge_tl_code, :edge_t_code, :edge_tr_code,
            :edge_l_code, :edge_r_code,
            :edge_bl_code, :edge_b_code, :edge_br_code,
            inclusion: { in: ->(_) { master_codes(MEdgeProcess) } },
            allow_blank: true

  validates :paint_surface_code,
            inclusion: { in: ->(_) { master_codes(MPaintSurface) } },
            allow_blank: true

  validates :paint_color_code,
            inclusion: { in: ->(_) { master_codes(MPaintColor) } },
            allow_blank: true

  validates :grain_finish_code,
            inclusion: { in: ->(_) { master_codes(MGrainFinish) } },
            allow_blank: true

  validates :gloss_code,
            inclusion: { in: ->(_) { master_codes(MGloss) } },
            allow_blank: true

  validates :note, length: { maximum: 500 }, allow_blank: true

  # ─────────────────────────────
  # スコープ
  # ─────────────────────────────
  default_scope -> { kept }

  private

  def generate_thumbnail
    puts "=== THUMB GEN START ==="
    outer = _outer || OuterShapeBuilder.build_outer_path(attributes.symbolize_keys)
    holes = _holes || HoleParamExtractor.build_holes(attributes.symbolize_keys)
  
    svg_str = ::Parts::PreviewSvg.call(outer, holes)  # ← SVG 文字列
    # --- ▼▼ ここからデバッグ追記 ▼▼ -----------------------------
    tmp_path = Rails.root.join("tmp", "thumb_dbg_#{id}.svg")
    File.write(tmp_path, svg_str)
    Rails.logger.debug "★SVG debug saved → #{tmp_path}"
    # --- ▲▲ ここまで追記 ▲▲ -------------------------------
    #png = MiniMagick::Image.read(svg_str) { |i| i.format "png" }
    png_data = IO.popen(%w[rsvg-convert -d 96 -p 96], "r+") do |io|
      io.write(svg_str)
      io.close_write
      io.read
    end
    raise "rsvg-convert failed" if png_data.empty?
  
    # === 重要ポイント ========================================
    # 1. `png.to_blob` を attach する
    # 2. content_type は image/png
    # 3. filename も .png 拡張子にする
    # =========================================================
    thumbnail.attach(
      io: StringIO.new(png_data),
      filename: "thumb_#{id}.png",
      content_type: "image/png"
    )
  end

  # Three.js から送られてきた base64 PNG を attach
  def attach_thumbnail_from_base64
    return if thumbnail.attached? # 二重 attach 防止

    png = Base64.decode64(thumbnail_data)
    thumbnail.attach(
      io: StringIO.new(png),
      filename: "thumb_#{SecureRandom.hex(4)}.png",
      content_type: "image/png"
    )
  end

  # フロントが無効／失敗した場合のみ従来処理を実行
  def sync_thumbnail
    # ---------- 無限ループ防止 ----------
    return if saved_changes.except(:updated_at, "updated_at").blank?

    # ---------- Three.js からのデータ優先 ----------
    return if thumbnail_data.present?      # すでに base64 が届いている
    return if thumbnail.attached?          # attach 済（create 時など）

    # ---------- フォールバック ----------
    generate_thumbnail                     # SVG → PNG
  end

  def generate_thumbnail_variant
    # 添付なし・SVG など非可変はスキップ
    return unless thumbnail.attached? && thumbnail.variable?

    # ビューと同じ定義でバリアントを作成
    thumbnail
      .variant(resize_to_fill: [160, 160],
               saver:  { quality: 70 },
               format: :webp)
      .processed            # ← ここが “事前生成” の核心
  end

  # discard された直後に添付を物理削除
  def purge_thumbnail!
    thumbnail.purge_later if thumbnail.attached?
  end
end
