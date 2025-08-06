class Api::ServiceAreaSummariesController < ApplicationController
  def create
    city_codes = params[:city_codes] || []
    city_codes = Array.wrap(city_codes)

    summary = ServiceAreaSummary.new(city_codes).summary

    render json: { summary: summary }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
