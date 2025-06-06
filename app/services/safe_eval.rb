# frozen_string_literal: true
# app/services/safe_eval.rb

require "ripper"

module SafeEval
  # ─────────────────────────────
  # 1) 許可する演算子（文字列）
  # ─────────────────────────────
  ALLOWED_OPS = %w[
    + - * / % ** < <= > >= == != && || ! ? :
  ].freeze
  ALLOWED_FUNCS = %w[
    round sqrt floor ceil abs
  ].freeze

  # ─────────────────────────────
  # 2) 「無害」トークン型（空白・改行・コメント）
  # ─────────────────────────────
  ALWAYS_SAFE_TOKENS = %i[
    on_sp on_ignored_sp        # 半角スペース / タブ
    on_nl on_ignored_nl        # 改行
    on_comment                 # # コメント
  ].freeze

  def self.round(x, n = 0) = x.to_f.round(n.to_i)
  def self.sqrt(x)         = Math.sqrt(x.to_f)
  def self.floor(x)        = x.to_f.floor
  def self.ceil(x)         = x.to_f.ceil
  def self.abs(x)          = x.to_f.abs

  # ===============================================================
  # Public: 安全に式を評価する
  #   expr : 文字列の Ruby 式
  #   ctx  : { シンボル=>値 } で渡す評価コンテキスト
  # ===============================================================
  def self.evaluate(expr, ctx = {})
    # 1) Ruby 向けにトークンを置換
    ruby = expr.to_s
              .gsub(/\bnull\b/i,  "nil")   # null → nil
              .gsub(/\btrue\b/i,  "true")  # 真偽値は念のため小文字統一
              .gsub(/\bfalse\b/i, "false")
    # 2) 安全性チェック
    raise "Unsafe expression" unless safe?(ruby, ctx)

    # 3) ctx をローカル変数としてバインド
    b = binding
    ctx.each { |k, v| b.local_variable_set(k, v) }

    # 4) 評価して結果を返す
    b.eval("(#{ruby})")   # カッコで余計なコード注入を防止
  end

  class << self
    private

    # ────────────────────────────
    # Ripper でトークンを走査し、すべて安全なら true
    # ────────────────────────────
    def safe?(expr, ctx)
      Ripper.lex(expr).all? do |(_pos, type, token, _)|
        case type
        when :on_ident                      # 変数
          ctx.key?(token.to_sym) || token == "null" || ALLOWED_FUNCS.include?(token)
        when :on_int, :on_float             # 数値
          true
        when :on_op, :on_question, :on_colon # 演算子 & 3項
          ALLOWED_OPS.include?(token)
        when :on_kw                                    # ★ ここを追加
          %w[true false nil].include?(token) 
        when :on_tstring_beg,             # ★ ここから文字列3トークンを許可
            :on_tstring_content,
            :on_tstring_end
          true
        when :on_lparen, :on_rparen         # ( )
          true
        when *ALWAYS_SAFE_TOKENS            # 空白・改行・コメント
          true
        else                                # それ以外は危険
          false
        end
      end
    end
  end
end
