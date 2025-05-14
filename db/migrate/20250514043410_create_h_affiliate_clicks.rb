class CreateHAffiliateClicks < ActiveRecord::Migration[8.0]
  def change
    create_table :h_affiliate_clicks do |t|
      # ---------- relations ----------
      t.references :affiliate_user, null: false,
                                    foreign_key: { to_table: :users },
                                    index: true

      # ---------- click info ----------
      t.uuid       :click_token,   null: false
      t.string     :referrer_url,  limit: 500
      t.string     :landing_url,   limit: 500
      t.inet       :ip_address
      t.string     :user_agent,    limit: 255
      t.datetime   :clicked_at,    null: false,
                                   default: -> { 'CURRENT_TIMESTAMP' }

      # ---------- timestamps ----------
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # クリック追跡 ID は一意
    add_index :h_affiliate_clicks, :click_token,
              unique: true, name: :uq_h_aff_click_token
  end
end
