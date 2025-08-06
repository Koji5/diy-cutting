class ServiceAreaSummary
  def initialize(city_codes)
    @city_codes = city_codes.uniq.compact
    @pref_city_map = MCity.active.order(:prefecture_code).to_a.group_by(&:prefecture_code)
    @pref_map = MPrefecture.order(:code).index_by(&:code)
  end

  def summary
    return "未選択" if @city_codes.empty?

    selected_by_pref = @city_codes.group_by { |code| code[0..1] }

    fully_selected = []
    partially_selected = []

    @pref_city_map.each do |pref_code, cities|
      total_count = cities.size
      selected_codes = selected_by_pref[pref_code] || []
      selected_count = selected_codes.size
      percentage = (selected_count.to_f / total_count * 100).round

      if selected_count == total_count
        fully_selected << pref_code
      elsif selected_count > 0
        partially_selected << [pref_code, selected_count, total_count, percentage]
      end
    end

    total_pref_count     = @pref_city_map.size
    selected_pref_count  = fully_selected.size + partially_selected.size
    coverage_ratio       = selected_pref_count.to_f / total_pref_count

    if selected_pref_count == total_pref_count && partially_selected.empty?
      return "全国"
    end

    if coverage_ratio >= 0.9 && (total_pref_count - selected_pref_count) <= 5
      exclude_parts = []
      minor_parts = []

      partially_selected.each do |pref_code, selected_count, total_count, percentage|
        unselected = total_count - selected_count
        pref_name = @pref_map[pref_code].name

        if percentage >= 90
          exclude_parts << "#{pref_name}の#{unselected}市区町村"
        elsif selected_count <= 4 || percentage < 10
          minor_parts << "#{pref_name}は#{selected_count}市区町村のみ対応"
        else
          minor_parts << "#{pref_name}は#{selected_count}市区町村"
        end
      end

      fully_unselected_codes = @pref_city_map.keys - fully_selected - partially_selected.map(&:first)
      exclude_parts += fully_unselected_codes.map { |code| "#{@pref_map[code].name}全域" }

      summary = "全国"
      if exclude_parts.any? || minor_parts.any?
        summary += "（"
        summary += "#{exclude_parts.join("・")}を除く" if exclude_parts.any?
        summary += "。" if exclude_parts.any? && minor_parts.any?
        summary += "#{minor_parts.join("。")}。" if minor_parts.any?
        summary.chomp!("。") # 文末の句点を1つだけ
        summary += "）"
      end
      return summary
    end

    # 通常表示（県単位）
    result_labels = fully_selected.map { |code| "#{@pref_map[code].name}（全域）" }

    result_labels += partially_selected.map do |pref_code, selected_count, total_count, percentage|
      unselected = total_count - selected_count
      pref_name = @pref_map[pref_code].name

      if percentage >= 90
        "#{pref_name}（#{unselected}市区町村を除く）"
      else
        "#{pref_name}（#{selected_count}市区町村）"
      end
    end

    result_labels.compact.join("・")
  end
end
