class PostalsController < ApplicationController
  def cities
    list = MCity.where(prefecture_code: params[:code])
                .select(:code, :name_ja).order(:sort_no, :name_ja)
    render json: list
  end

  def lookup
    list = MPostalCode.where(postal_code: params[:zip], deleted_flag: false)
                      .select(:id, :city_code,
                              :city_town_name_kanji,
                              :town_area_name_kanji)
                      .order(:city_code, :town_area_name_kanji)
    render json: list
  end
end
