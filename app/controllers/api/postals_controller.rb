class Api::PostalsController < ApplicationController
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

  def copy_address
    addresses = Current.account.addresses.to_a

    # prefecture_code一覧を抽出（重複排除）
    prefecture_codes = addresses.map(&:prefecture_code).compact.uniq

    # 都道府県名をハッシュでキャッシュ
    prefecture_names = MPrefecture.where(code: prefecture_codes)
                                  .pluck(:code, :name_ja)
                                  .to_h

    # 各prefecture_codeに対応するcityリストをハッシュでキャッシュ
    city_groups = MCity.where(prefecture_code: prefecture_codes)
                      .select(:prefecture_code, :code, :name_ja)
                      .order(:code, :name_ja)
                      .group_by(&:prefecture_code)

    # 結果生成
    result = addresses.map do |address|
      pref_code = address.prefecture_code
      city_code = address.city_code
      cities = city_groups[pref_code] || []
      city_name_ja = cities.find { |c| c.code == city_code }&.name_ja

      {
        id: address.id,
        name: address.name.to_s,
        postal_code: address.postal_code.to_s,
        prefecture_code: pref_code,
        prefecture_name_ja: prefecture_names[pref_code].to_s,
        city_code: address.city_code,
        city_name_ja: city_name_ja.to_s,
        address_line: address.address_line.to_s,
        phone_number: address.phone_number.to_s,
        department: address.department.to_s,
        label: address.label.to_s,
        name_kana: address.name_kana.to_s,
        cities: cities.map { |c| { code: c.code, name_ja: c.name_ja } }
      }
    end

    render json: result
  end

end
