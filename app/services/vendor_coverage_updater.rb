class VendorCoverageUpdater
  # @param vendor_detail [VendorDetail]  対象業者
  # @param params [Hash]  :coverage_scope, :prefecture_codes, :city_codes を含む
  def initialize(vendor_detail, params)
    @vendor        = vendor_detail
    @scope         = params[:coverage_scope].to_sym                # :all_japan / :prefectures / :cities
    @pref_codes    = Array(params[:prefecture_codes]).map(&:to_s)  # ["01", "13", ...]
    @city_codes    = Array(params[:city_codes]).map(&:to_s)        # ["01101", ...]
  end

  # メインエントリ
  def call
    VendorDetail.transaction do
      case @scope
      when :all_japan
        set_scope(:all_japan)
        clear_prefectures
        clear_cities

      when :prefectures
        set_scope(:prefectures)
        sync_table(@vendor.service_prefectures, @pref_codes, :prefecture_code)
        clear_cities

      when :cities
        set_scope(:cities)
        sync_table(@vendor.service_areas, @city_codes, :city_code)
        clear_prefectures

      else
        raise ArgumentError, "Unknown coverage scope: #{@scope}"
      end
    end
  end

  private

  # coverage_scope を更新
  def set_scope(scope_sym)
    @vendor.update!(coverage_scope: scope_sym)
  end

  # prefecture / city テーブルを全削除
  def clear_prefectures = @vendor.service_prefectures.delete_all
  def clear_cities      = @vendor.service_areas.delete_all

  # 汎用同期メソッド
  #
  # @param assoc      ActiveRecord::AssociationRelation
  # @param new_codes  [Array<String>]
  # @param column     Symbol  (:prefecture_code あるいは :city_code)
  #
  # 既存との差分を取り、不要レコード削除 → 不足分 insert_all
  def sync_table(assoc, new_codes, column)
    existing = assoc.pluck(column)
    to_add   = new_codes - existing
    to_del   = existing - new_codes

    assoc.where(column => to_del).delete_all if to_del.any?

    if to_add.any?
      assoc.klass.insert_all(
        to_add.map { |code| { vendor_id: @vendor.id, column => code } }
      )
    end
  end
end
