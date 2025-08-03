class ServiceAreasController < ApplicationController
  include AccountDashboardRenderable
  before_action :set_account

  def edit
    @selected_codes = @account.account_coverage_areas.pluck(:city_code)
    @city_summary = ServiceAreaSummary.new(@selected_codes).summary
    render_flash_and_replace_main(
      template: "service_areas/edit",
      assigns: {
        account: @account,
        selected_codes: @selected_codes,
        city_summary: @city_summary
     }
    )
  end

  def update
    data = JSON.parse(params[:payload])
    city_codes = data["city_codes"]

    begin
      ActiveRecord::Base.transaction do
        @account.account_coverage_areas.destroy_all
        @account.account_coverage_areas.insert_all!(
          city_codes.uniq.map { |code| { account_id: @account.id, city_code: code, created_at: Time.current, updated_at: Time.current } }
        )
      end
      flash[:notice] = "対応エリアを更新しました"
      render_account_dashboard
    rescue => e
      render_flash_and_replace(
        message: "対応エリアの保存に失敗しました: #{e.message}",
        type: :alert
      )
    end

  end

  def confirm
    @payload = params[:payload]
    city_codes = JSON.parse(@payload)["city_codes"]
    @summary = ServiceAreaSummary.new(city_codes).summary

    old_codes = @account.account_coverage_areas.pluck(:city_code)
    @previous_summary = ServiceAreaSummary.new(old_codes).summary
    render layout: (turbo_frame_request? ? false : "application")
  end

  private

  def set_account
    @account = Current.account
  end
end
