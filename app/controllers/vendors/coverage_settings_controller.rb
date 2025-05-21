module Vendors
  class CoverageSettingsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_vendor!

    def show
      @vendor       = current_user.vendor_detail
      @pref_codes   = @vendor.service_prefectures.pluck(:prefecture_code)
      @city_codes   = @vendor.service_areas.pluck(:city_code)

      # ★ office_city があれば緯度経度をビューへ
      if (city = @vendor.office_city)
        @office_lat = city.latitude
        @office_lng = city.longitude
      end

      # ラジオ切替時は mode パラメータを使って「表示だけ」切替
      @vendor.coverage_scope = params[:mode] if params[:mode].present?

      respond_to do |format|
        format.html          # 初回ページ表示
        format.turbo_stream  # ラジオ切替の fetch
      end
    end

    # ラジオ＋全国ボタン or 47 都道府県チェックリストの決定
    def update
      updater = VendorCoverageUpdater.new(current_vendor, coverage_params)
      updater.call
      redirect_to vendors_coverage_settings_path, notice: "保存しました"
    end

    # 市区町村モードで地図から送られてくる bulk 保存
    def cities_bulk
      VendorCoverageUpdater.new(current_vendor, coverage_scope: :cities, city_codes: params[:city_codes]).call
      respond_to do |f|
        f.turbo_stream { render_flash_stream }
        f.html { redirect_to vendors_coverage_settings_path, notice: "保存しました" }
      end
    end

    # 県モードでチェックリストから bulk 保存
    def prefs_bulk
      VendorCoverageUpdater.new(current_vendor, coverage_scope: :prefectures, prefecture_codes: params[:prefecture_codes]).call
      respond_to do |f|
        f.turbo_stream { render_flash_stream }
        f.html { redirect_to vendors_coverage_settings_path, notice: "保存しました" }
      end
    end

    def nationwide_bulk
      VendorCoverageUpdater.new(current_vendor,
                                coverage_scope: :all_japan).call
      respond_to do |f|
        f.turbo_stream { render_flash_stream }              # ★トーストを返す
        f.html { redirect_to vendors_coverage_settings_path,
                            notice: "保存しました" }
      end
    end

    # Ajax：県コード→市区町村一覧 (地図ロード用)
    def cities_json
      render json: MCity.where(prefecture_code: params[:pref_code]).select(:code, :name).order(:name)
    end

    def flash_toast
      render turbo_stream: turbo_stream.update(
        "toast-frame",
        partial: "shared/flash_toast",
        locals: { message: params[:msg], type: params[:type] }
      )
    end

    private

    def current_vendor = current_user.vendor_detail

    def coverage_params
      params.require(:vendor_detail).permit(:coverage_scope, prefecture_codes: [])
    end

    def require_vendor!
      redirect_to root_path, alert: "権限がありません" unless current_user.vendor?
    end

    def render_flash_stream(message: "保存しました", type: "success")
      render turbo_stream: turbo_stream.update(
        "toast-frame",
        partial: "shared/flash_toast",
        locals: { message: message, type: type }
      )
    end
  end
end
