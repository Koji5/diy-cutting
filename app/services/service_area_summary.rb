class ServiceAreaSummary
  def initialize(city_codes)
    @city_codes = city_codes.uniq.compact
    Rails.logger.debug "✅ @city_codes: #{@city_codes}"
    @cities = MCity.active.where(code: @city_codes)
    Rails.logger.debug "✅ @cities: #{@cities}"
    @pref_city_map = MCity.active.to_a.group_by(&:prefecture_code)
    @pref_map = MPrefecture.all.index_by(&:code)
  end

  def summary
    return "未選択" if @city_codes.empty?

    selected_by_pref = @city_codes.group_by { |code| code[0..1] }

    fully_selected = []
    partially_selected = []

    @pref_city_map.each do |pref_code, cities|
      total = cities.map(&:code)
      selected = selected_by_pref[pref_code] || []

      if selected.size == total.size
        fully_selected << pref_code
      elsif selected.any?
        partially_selected << [pref_code, selected.size]
      end
    end

    all_codes = @pref_city_map.keys

    if fully_selected.size == all_codes.size
      return "全国"
    end

    if fully_selected.size >= all_codes.size - 1 && partially_selected.empty?
      excluded = all_codes - fully_selected
      names = excluded.map { |code| @pref_map[code].name }
      return "全国（#{names.join("・")}を除く）"
    end

    parts = fully_selected.map { |c| @pref_map[c].name } +
            partially_selected.map { |c, n| "#{@pref_map[c].name}（#{n}市区町村）" }

    parts.join("・")
  end
end
