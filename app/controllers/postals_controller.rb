class PostalsController < ApplicationController
  def cities
    list = MCity.where(prefecture_code: params[:code])
                .select(:code, :name_ja).order(:code, :name_ja)
    render json: list
  end

  def lookup
    list = MPostalCode.where(postal_code: params[:zip], deleted_flag: false)
                      .select(:id, :city_code, :city_town_name_kanji, :town_area_name_kanji)
                      .order(:city_code, :town_area_name_kanji)

    # 市区町村リストの取得
    city_codes = list.map(&:city_code).uniq
    prefecture_code = city_codes.first&.slice(0, 2)

    cities = MCity.where(prefecture_code: prefecture_code)
                  .select(:code, :name_ja)
                  .order(:code, :name_ja)

    render json: {
      addresses: list,
      cities: cities
    }
  end
end
