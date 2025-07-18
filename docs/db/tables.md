# DB テーブル一覧

生成日: 2025-07-18 09:27 JST

<!-- SECTION_BEGIN ユーザー系 -->
# ユーザー系
<!-- SECTION_END ユーザー系 -->

<!-- TABLE_BEGIN users -->
## users — ユーザー

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| email | character varying | × |  | ログイン用メール |
| encrypted_password | character varying | × |  | ハッシュ |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| reset_password_token | character varying | ○ |  | devise |
| reset_password_sent_at | timestamp(6) without time zone | ○ |  | devise |
| remember_created_at | timestamp(6) without time zone | ○ |  | devise |
| sign_in_count | integer | × | 0 | devise |
| current_sign_in_at | timestamp(6) without time zone | ○ |  | devise |
| last_sign_in_at | timestamp(6) without time zone | ○ |  | devise |
| current_sign_in_ip | character varying | ○ |  | devise |
| last_sign_in_ip | character varying | ○ |  | devise |
| failed_attempts | integer | × | 0 | devise |
| unlock_token | character varying | ○ |  | devise |
| locked_at | timestamp(6) without time zone | ○ |  | devise |

**インデックス**:
- users_pkey (id) [PK]
- index_users_on_email (email) [UNIQUE]
- index_users_on_reset_password_token (reset_password_token) [UNIQUE]
- index_users_on_unlock_token (unlock_token) [UNIQUE]
<!-- AUTO END -->

<!-- NOTE BEGIN -->
### メモ
* deviseでのみ使用
<!-- NOTE END -->

<!-- TABLE_END users -->

<!-- TABLE_BEGIN accounts -->
## accounts — アカウント

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| user_id | bigint | × |  | ログイン用ユーザーID |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| role_flags | integer | × | 0 | ロール |
| nickname | character varying(50) | ○ |  | ニックネーム |
| legal_type | integer | × |  | 課金状態 |
| name | character varying | × |  | 氏名または法人名 |
| name_kana | character varying | ○ |  | 氏名または法人名かな |
| birthday | date | ○ |  | 生年月日 |
| gender | character varying(1) | ○ |  | 性別 |

**インデックス**:
- accounts_pkey (id) [PK]
- index_accounts_on_user_id (user_id)

**外部キー**:
- fk_rails_b1e30bebc8 (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
### メモ

* **role_flags**は以下のようにBITS表示
  | 種別 | ROLE_BITS |
  | ---- | --------- |
  | member | 0001 → 1 |
  | vendor | 0010 → 2 |
  | admin | 0100 → 4 |
  | affiliate | 1000 → 8 |
<!-- NOTE END -->

<!-- TABLE_END accounts -->

<!-- TABLE_BEGIN member_profiles -->
## member_profiles — お客様プロフィール

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| account_id | bigint | × |  | 対象アカウント |
| billing_postal_code | character varying(20) | ○ |  | 請求先 郵便番号<br>*TODO:**7桁に*** |
| billing_prefecture_code | character varying(2) | ○ |  | 請求先 都道府県コード |
| billing_city_code | character varying(5) | × |  | 請求先 市区町村コード |
| billing_address_line | character varying(200) | × |  | 請求先 番地・建物名ほか |
| billing_department | character varying(100) | ○ |  | 請求先 部署 |
| billing_phone_number | character varying(30) | ○ |  | 請求先 電話番号 |
| stripe_customer_id | character varying | ○ |  | PaymentIntent で `customer` を渡すための顧客 ID。カードを保存する場合にも必須<br>初めて決済を行う際に作成される |
| registered_affiliate_id | bigint | ○ |  | アフィリエイトから登録した場合につく、登録元**アフィリエイト**のアカウントID  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| membership_plan | integer | × | 0 | 課金状態（当面無料のみ） |

**インデックス**:
- member_profiles_pkey (id) [PK]
- index_member_profiles_on_account_id (account_id)
- index_member_profiles_on_created_by_id (created_by_id)
- index_member_profiles_on_deleted_by_id (deleted_by_id)
- index_member_profiles_on_registered_affiliate_id (registered_affiliate_id)
- index_member_profiles_on_stripe_customer_id (stripe_customer_id)
- index_member_profiles_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_1b24741643 (registered_affiliate_id) → accounts.id
- fk_rails_6055409895 (account_id) → accounts.id
- fk_rails_68d9f25c71 (updated_by_id) → accounts.id
- fk_rails_7e212a956f (created_by_id) → accounts.id
- fk_rails_a782c690cb (billing_city_code) → m_cities.code
- fk_rails_e6d47b65a7 (billing_prefecture_code) → m_prefectures.code
- fk_rails_ea596ce8ec (deleted_by_id) → accounts.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
### メモ

* アフィリエイト連携判定は `registered_affiliate_id IS NOT NULL`  
   *この列は「発番時のアフィリエイト」を永続的に保持し、注文時は orders が参照します。*  
* **顧客 ID (`stripe_customer_id`) はすべて Stripe が自動生成**（`cus_` プレフィクス）。

<!-- NOTE END -->

<!-- TABLE_END member_profiles -->

<!-- TABLE_BEGIN user_authorities -->
## user_authorities — ユーザー権限

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| user_id | bigint | × |  | 対象ユーザー |
| authority_code | character varying(30) | × |  | 付与する権限 |
| grant_state | smallint | × | 1 | 例外無効化にも対応 |
| valid_from | timestamp(6) without time zone | ○ |  | 有効開始 |
| valid_to | timestamp(6) without time zone | ○ |  | 有効終了 |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- user_authorities_pkey (id) [PK]
- index_user_authorities_on_user_id (user_id)
- index_user_authorities_on_user_id_and_authority_code (user_id, authority_code) [UNIQUE]

**外部キー**:
- fk_rails_64f628bee7 (authority_code) → m_authorities.code
- fk_rails_6a8b2647b8 (user_id) → users.id

**チェック制約**:
- user_authorities_grant_state_chk: grant_state = ANY (ARRAY[0, 1])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
### メモ

* **UNIQUE** **(user_id, authority_code)** 重複付与防止  
* *grant_state = deny* で “ロールで自動付与されたが個別に外す” も表現可能。  
* **valid_to** をセットすれば「○日だけ管理権限」など一時付与も実装できます。
<!-- NOTE END -->

<!-- TABLE_END user_authorities -->

<!-- TABLE_BEGIN member_shipping_addresses -->
## member_shipping_addresses — 会員ユーザーの送付先アドレス

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| member_id | bigint | × |  | 会員ユーザー (member_details) |
| label | character varying(50) | ○ |  | 宛名ラベル（例 `自宅` `会社`） |
| recipient_name | character varying(100) | × |  | 受取人氏名／法人名 |
| postal_code | character varying(8) | × |  | 送付先 郵便番号<br>*TODO:**7桁に*** |
| prefecture_code | character varying(2) | × |  | 送付先 都道府県コード |
| city_code | character varying(5) | × |  | 送付先 市区町村コード |
| address_line | character varying(200) | × |  | 送付先 番地・建物名ほか |
| phone_number | character varying(20) | ○ |  | 送付先 電話番号 |
| is_default | boolean | × | false | デフォルトの送付先かどうか |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| department | character varying(100) | ○ |  | 送付先 部署 |

**インデックス**:
- member_shipping_addresses_pkey (id) [PK]
- index_member_shipping_addresses_on_created_by_id (created_by_id)
- index_member_shipping_addresses_on_deleted_by_id (deleted_by_id)
- index_member_shipping_addresses_on_member_id (member_id)
- index_member_shipping_addresses_on_updated_by_id (updated_by_id)
- uq_member_default_address (member_id) WHERE (is_default = true) [UNIQUE]

**外部キー**:
- fk_member_shipping_addresses_city_code (city_code) → m_cities.code
- fk_rails_2997f898f1 (member_id) → member_details.user_id ON DELETE CASCADE
- fk_rails_32761ffe09 (prefecture_code) → m_prefectures.code
- fk_rails_63f1c23650 (city_code) → m_cities.code
- fk_rails_66cc3b7a7e (updated_by_id) → users.id
- fk_rails_99ee2a7033 (deleted_by_id) → users.id
- fk_rails_aad71f9b0c (created_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
### メモ

* **追加インデックス・制約**
   ```sql
   -- 会員ごとに「デフォルト」は最大 1 件に制限（部分 UNIQUE）
   CREATE UNIQUE INDEX uq_member_default_address
     ON member_shipping_addresses (member_id)
     WHERE is_default = true;
   ```
* これにより **1 人の会員が複数の送付先を登録可能** かつ  
   **デフォルトの送付先住所は常に 0 または 1 行** に保てます。
<!-- NOTE END -->

<!-- TABLE_END member_shipping_addresses -->

<!-- TABLE_BEGIN vendor_details -->
## vendor_details — 加工業者ユーザー詳細

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| user_id | bigint | × |  |  |
| nickname | character varying(50) | ○ |  | ニックネーム |
| profile_icon_url | character varying(500) | ○ |  | プロフィールアイコン URL |
| vendor_name | character varying(100) | × |  | 事業者名 |
| vendor_name_kana | character varying(100) | ○ |  | 事業者名カナ |
| invoice_number | character varying(20) | ○ |  | 適格請求書発行事業者番号 |
| contact_person_name | character varying(80) | × |  | 窓口担当者名 |
| contact_person_kana | character varying(80) | ○ |  | 担当者名カナ |
| contact_phone_number | character varying(20) | ○ |  | 担当者直通電話番号 |
| office_postal_code | character varying(8) | ○ |  | 事業所郵便番号<br>*TODO:**7桁に*** |
| office_prefecture_code | character varying(2) | × |  | 事業所都道府県コード |
| office_city_code | character varying(5) | × |  | 事業所市区町村コード |
| office_address_line | character varying(200) | × |  | 事業所番地・建物名ほか |
| office_phone_number | character varying(20) | ○ |  | 代表電話番号 |
| bank_name | character varying(60) | ○ |  | 振込銀行名 |
| account_type | smallint | ○ |  | 口座種別 `0=普通 1=当座` |
| account_number | character varying(20) | ○ |  | 口座番号 |
| account_name | character varying(100) | ○ |  | 口座名義 |
| shipping_base_address_json | jsonb | ○ |  | 業者からの出荷元住所情報（郵便番号、住所、電話番号） |
| notes | text | ○ |  | メモ |
| charges_enabled | boolean | × | false | Webhook `account.updated` で同期。入金停止などの UI 表示に利用 |
| payouts_enabled | boolean | × | false | ebhook `account.updated` で同期。入金停止などの UI 表示に利用 |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| coverage_scope | integer | × | 0 | 対応地域単位 `0 : all_japan` `1 : prefectures` `2 : cities` |

**インデックス**:
- vendor_details_pkey (user_id) [PK]
- index_vendor_details_on_coverage_scope (coverage_scope)
- index_vendor_details_on_created_by_id (created_by_id)
- index_vendor_details_on_deleted_by_id (deleted_by_id)
- index_vendor_details_on_invoice_number (invoice_number) [UNIQUE]
- index_vendor_details_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_15b36fb913 (office_city_code) → m_cities.code
- fk_rails_6d15c353fd (deleted_by_id) → users.id
- fk_rails_74ee2893b8 (office_prefecture_code) → m_prefectures.code
- fk_rails_d0ad37f00a (created_by_id) → users.id
- fk_rails_e57cb87d98 (user_id) → users.id
- fk_rails_ecf03c70f6 (updated_by_id) → users.id
- fk_vendor_details_office_city_code (office_city_code) → m_cities.code
<!-- AUTO END -->

<!-- NOTE BEGIN -->
### メモ

* 能力・対応地域は`vendor_capabilities`、`vendor_service_areas`、`vendor_materials` テーブルへ正規化。  
<!-- NOTE END -->

<!-- TABLE_END vendor_details -->

<!-- TABLE_BEGIN vendor_capabilities -->
## vendor_capabilities ― 業者⇔加工機能

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| vendor_id | bigint | × |  | 業者 ID |
| capability_code | character varying(16) | × |  | 加工能力コード（例 `LASER`） |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- vendor_capabilities_pkey (vendor_id, capability_code) [PK]
- index_vendor_capabilities_on_capability_code (capability_code)
- index_vendor_capabilities_on_vendor_id (vendor_id)

**外部キー**:
- fk_rails_9f0bc3a1c3 (vendor_id) → vendor_details.user_id ON DELETE CASCADE
- fk_rails_a23e589077 (capability_code) → m_process_types.code
<!-- AUTO END -->

<!-- NOTE BEGIN -->
#### メモ

* *複合プライマリキー：同一業者 × 同一加工能力 の重複を禁止*  
   `PRIMARY KEY (vendor_id, capability_code)`  
* ***TODO:** idを追加し、`unique (vendor_id, capability_code)`を張るか、とどちらかに統一したい。*
<!-- NOTE END -->

<!-- TABLE_END vendor_capabilities -->

<!-- TABLE_BEGIN vendor_service_prefectures -->
## vendor_service_prefectures ― 業者⇔対応地域（都道府県）

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| vendor_id | bigint | × |  | 業者 ID |
| prefecture_code | character varying(2) | × |  | 対応都道府県コード (`13`=東京) |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- vendor_service_prefectures_pkey (id) [PK]
- idx_vsp_unique (vendor_id, prefecture_code) [UNIQUE]

**外部キー**:
- fk_rails_8a9ace2194 (vendor_id) → vendor_details.user_id ON DELETE CASCADE
- fk_rails_fe52c5e836 (prefecture_code) → m_prefectures.code
<!-- AUTO END -->

<!-- NOTE BEGIN -->
#### メモ

* `unique (vendor_id, prefecture_code)`  
* ***TODO:** `PRIMARY KEY (vendor_id, prefecture_code)` にするか、どちらかに統一したい。*  
<!-- NOTE END -->

<!-- TABLE_END vendor_service_prefectures -->

<!-- TABLE_BEGIN vendor_service_areas -->
## vendor_service_areas ― 業者⇔対応地域（市区町村）

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| vendor_id | bigint | × |  |  |
| city_code | character varying(5) | × |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- idx_vsa_unique (vendor_id, city_code) [UNIQUE]
- index_vendor_service_areas_on_city_code (city_code)
- index_vendor_service_areas_on_vendor_id (vendor_id)

**外部キー**:
- fk_rails_6af0406fe8 (vendor_id) → vendor_details.user_id ON DELETE CASCADE
- fk_rails_7fc7dfd7b8 (city_code) → m_cities.code
- fk_vendor_service_areas_city_code (city_code) → m_cities.code
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END vendor_service_areas -->

<!-- TABLE_BEGIN vendor_materials -->
## vendor_materials

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| vendor_id | bigint | × |  |  |
| material_code | character varying(16) | × |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- vendor_materials_pkey (vendor_id, material_code) [PK]
- index_vendor_materials_on_material_code (material_code)
- index_vendor_materials_on_vendor_id (vendor_id)

**外部キー**:
- fk_rails_24b9aa6af6 (material_code) → m_materials.code
- fk_rails_651d8515a7 (vendor_id) → vendor_details.user_id ON DELETE CASCADE
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END vendor_materials -->

<!-- TABLE_BEGIN affiliate_details -->
## affiliate_details

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| user_id | bigint | × |  |  |
| name | character varying(100) | × |  |  |
| name_kana | character varying(255) | ○ |  |  |
| postal_code | character varying(8) | × |  |  |
| prefecture_code | character varying(2) | × |  |  |
| city_code | character varying(5) | × |  |  |
| address_line | character varying(200) | × |  |  |
| phone_number | character varying(30) | ○ |  |  |
| invoice_number | character varying(20) | ○ |  |  |
| bank_name | character varying(100) | ○ |  |  |
| account_type | smallint | ○ |  |  |
| account_number | character varying(30) | ○ |  |  |
| account_holder | character varying(100) | ○ |  |  |
| commission_rate | numeric(5,2) | × | 3.0 |  |
| payout_threshold | numeric(18,4) | × | 5000.0 |  |
| unpaid_balance | numeric(18,4) | × | 0.0 |  |
| last_paid_at | timestamp(6) without time zone | ○ |  |  |
| charges_enabled | boolean | × | false |  |
| payouts_enabled | boolean | × | false |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- affiliate_details_pkey (user_id) [PK]
- index_affiliate_details_on_created_by_id (created_by_id)
- index_affiliate_details_on_deleted_by_id (deleted_by_id)
- index_affiliate_details_on_invoice_number (invoice_number) [UNIQUE]
- index_affiliate_details_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_affiliate_details_city_code (city_code) → m_cities.code
- fk_rails_1250f45d05 (prefecture_code) → m_prefectures.code
- fk_rails_70a6bce611 (created_by_id) → users.id
- fk_rails_7c046c89f6 (city_code) → m_cities.code
- fk_rails_8b1030bd18 (deleted_by_id) → users.id
- fk_rails_b810b35d18 (user_id) → users.id
- fk_rails_ce9ab7214f (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END affiliate_details -->

<!-- TABLE_BEGIN admin_details -->
## admin_details ー 管理者詳細テーブル

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| user_id | bigint | × |  |  |
| nickname | character varying(50) | ○ |  |  |
| icon_url | character varying(255) | ○ |  |  |
| department | character varying(100) | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- admin_details_pkey (user_id) [PK]
- index_admin_details_on_created_by_id (created_by_id)
- index_admin_details_on_deleted_by_id (deleted_by_id)
- index_admin_details_on_nickname (nickname) [UNIQUE]
- index_admin_details_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_0434f99b3a (created_by_id) → users.id
- fk_rails_45d29e92b6 (deleted_by_id) → users.id
- fk_rails_4fcb60b766 (user_id) → users.id
- fk_rails_560f5098d3 (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END admin_details -->

<!-- SECTION_BEGIN 部品系 -->
# 部品系
<!-- SECTION_END 部品系 -->

<!-- TABLE_BEGIN parts -->
## parts — 部品

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| account_id | bigint | × |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| material_category_code | character varying(10) | × |  | 材質カテゴリコード（WOOD / METAL など） |
| material_code | character varying(16) | × |  | 具体的な材質コード（樹種・金属種） |
| shape_code | character varying(10) | × |  | 平面形状コード（RECT、TRIANGLE など） |
| paint_type_code | character varying(4) | ○ |  | 塗装種別コード（ウレタン、自然塗装等） |
| thickness_mm | numeric(8,2) | × |  | 厚み [mm] |
| width1_mm | numeric(8,2) | × |  | 幅1 [mm]（矩形の場合は幅） |
| width2_mm | numeric(8,2) | ○ |  | 幅2 [mm]（台形・三角形などで使用） |
| length_mm | numeric(8,2) | × |  | 長さ [mm] |
| shape_json | jsonb | ○ | {} | 面取り・角丸等の形状加工パラメータ |
| corner_proc_json | jsonb | ○ | {} | 四隅の角加工設定 |
| hole_json | jsonb | ○ | {} | 丸穴加工設定 |
| sqhole_json | jsonb | ○ | {} | 角穴加工設定 |
| edge_json | jsonb | ○ | {} | 断面加工（面取り／R など） |
| paint_json | jsonb | ○ | {} | 塗装詳細（色・艶・導管処理等） |
| note | text | ○ |  | 備考メモ |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| origin_snapshot_id | bigint | ○ |  |  |
| origin_owner_id | bigint | ○ |  |  |
| camera_state | jsonb | ○ |  |  |
| name | character varying(50) | × |  | パーツ名称（ユーザー入力） |

**インデックス**:
- parts_pkey (id) [PK]
- index_parts_on_account_id (account_id)
- index_parts_on_corner_proc_json (corner_proc_json)
- index_parts_on_created_by_id (created_by_id)
- index_parts_on_deleted_by_id (deleted_by_id)
- index_parts_on_hole_json (hole_json)
- index_parts_on_origin_snapshot_id (origin_snapshot_id)
- index_parts_on_sqhole_json (sqhole_json)
- index_parts_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_001c6f3575 (origin_owner_id) → accounts.id
- fk_rails_30be2232d9 (deleted_by_id) → accounts.id
- fk_rails_86b8db80ec (account_id) → accounts.id
- fk_rails_9790700793 (material_category_code) → m_categories.code
- fk_rails_a63b0793fa (material_code) → m_materials.code
- fk_rails_b13d63e301 (shape_code) → m_shapes.code
- fk_rails_b8a090e626 (updated_by_id) → accounts.id
- fk_rails_d9a2b8fbeb (created_by_id) → accounts.id
- fk_rails_da03c13c19 (paint_type_code) → m_paint_types.code

**チェック制約**:
- chk_parts_dims_positive: thickness_mm > 0::numeric AND width1_mm > 0::numeric AND (width2_mm IS NULL OR width2_mm > 0::numeric) AND length_mm > 0::numeric
<!-- AUTO END -->

<!-- NOTE BEGIN -->
**メモ**:
- 'origin_*' 列は **第一世代の公開情報を不変で保持** し、コピー後の編集でも変更不可。  
* 材積・重量はアプリで自動計算とする。  
* 加工関連はjsonで集約  
  * **shape\_json**：加工設定  
     例：`{"tl":3,"tr":0,"bl":5,"br":0}`  
  * **corner\_proc\_json**：コーナー(角)加工  
     例：`{ "tl":{ "proc":"ROUND", "dx":10,"dy":10,"r":5 }, "tr":{"proc":"NONE"}, "bl":{"proc":"CHAMFER","dx":5,"dy":5,"r":0}, "br":{"proc":"NONE"} }`  
     **proc** = 加工区分 (`m_corner_processes.code`)  
     **dx/dy/r** = 縦/横/半径
  * **hole\_json**：丸穴加工  
     例：`{"tl":{"flag":true,"dy":10,"dx":15,"dia":6},…}`  
     **flag** = 丸穴加工 あり / なし (`true` / `false`)  
     **dy** = 丸穴中心までの縦距離  
     **dx** = 丸穴中心までの横距離  
     **dia** = 丸穴直径 (`m_hole_diameters.code`)
  * **sqhole\_json**：四角穴加工  
     例：`{"bl":{"flag":true,"dy":20,"dx":25,"h":10,"w":8},…}`  
  * **edge\_json**：断面加工  
     例：`{"t":"BEVEL","b":"NONE",…}`  
     `tl`/ `t`/ `tr` / `l` / `r` / `bl` / `b` / `br` = `m_edge_processes.code`  
  * **paint\_json**：塗装状態  
     例：`{"surface":"NOMAL", "color":"LT", "finish":"OPEN", "gloss":"ALL"}`  
     surface：`m_paint_surfaces` 塗装面 (標準 / 全面)  
     color：`m_paint_colors` 塗装色 (クリアー・ライト…)  
     finish：`m_grain_finishes` 木目・導管の見え方 (セミ OP / CL …)  
     gloss：`m_glosses` ツヤ (3 分・5 分・全ツヤ)  

* **JSON 内値とマスタ行（コード）の関連付け**  
   1. **一時的にラベルが欲しい場合（ビュー）**  
      ```sql
      CREATE VIEW vw_part_corner AS
      SELECT qi.id,
             cps_tl.name_ja AS corner_tl_label,
             (qi.corner_proc_json->'tl'->>'r')::numeric AS radius_tl
      FROM   parts qi
      LEFT JOIN m_corner_processes cps_tl
             ON cps_tl.code = qi.corner_proc_json->'tl'->>'proc';
      ```
   1. **頻繁に参照するなら 生成列＋外部キーも可**  
      ```sql
      ALTER TABLE parts
        ADD COLUMN corner_tl_proc char(4)
          GENERATED ALWAYS AS
            (corner_proc_json->'tl'->>'proc') STORED;

      ALTER TABLE parts
        ADD CONSTRAINT fk_corner_tl_proc
        FOREIGN KEY (corner_tl_proc)
        REFERENCES m_corner_processes(code);
      ```
* **camera_state**は JSON で
   ```json
   {
      "pos":  [300, 300, 300],   // camera.position
      "tgt":  [0, 0, 0],         // controls.target
      "zoom": 1.2                // camera.zoom (Orthographic の場合)
   }
   ```
<!-- NOTE END -->

<!-- TABLE_END parts -->

<!-- TABLE_BEGIN recipes -->
## recipes

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| account_id | bigint | × |  |  |
| name | character varying(60) | × |  |  |
| status | integer | × | 0 |  |
| latest_snapshot_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- recipes_pkey (id) [PK]
- index_recipes_on_account_id (account_id)
- index_recipes_on_latest_snapshot_id (latest_snapshot_id)

**外部キー**:
- fk_rails_e279359460 (account_id) → accounts.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END recipes -->

<!-- TABLE_BEGIN recipe_parts -->
## recipe_parts — レシピを構成する部品リスト （中間テーブル）

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| recipe_id | bigint | × |  | 親レシピ (recipes.id) |
| part_id | bigint | × |  | 構成部品 (parts.id) |
| quantity | integer | × | 1 | レシピ内で使用する数量 |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- recipe_parts_pkey (id) [PK]
- index_recipe_parts_on_part_id (part_id)
- index_recipe_parts_on_recipe_id (recipe_id)

**外部キー**:
- fk_rails_220f43ebf6 (recipe_id) → recipes.id
- fk_rails_7138980aad (part_id) → parts.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
**メモ**:
- **同一レシピ内で同じ部品を重複させたくない** 場合は`UNIQUE (recipe_id, part_id)` 制約を追加。
- `quantity` は正整数のみ許容。モデル側で `numericality: { greater_than: 0 }` を付ける。
- リレーションは `Recipe has_many :recipe_parts` / `Part has_many :recipe_parts` を想定。
<!-- NOTE END -->

<!-- TABLE_END recipe_parts -->

<!-- TABLE_BEGIN recipe_snapshots -->
## recipe_snapshots

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| recipe_id | bigint | × |  |  |
| version | integer | × |  |  |
| published_at | timestamp(6) without time zone | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- recipe_snapshots_pkey (id) [PK]
- index_recipe_snapshots_on_recipe_id (recipe_id)

**外部キー**:
- fk_rails_c19cfa2d34 (recipe_id) → recipes.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END recipe_snapshots -->

<!-- TABLE_BEGIN recipe_snapshot_parts -->
## recipe_snapshot_parts

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| recipe_snapshot_id | bigint | × |  |  |
| part_snapshot_id | bigint | × |  |  |
| quantity | integer | × | 1 |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- recipe_snapshot_parts_pkey (id) [PK]
- index_recipe_snapshot_parts_on_part_snapshot_id (part_snapshot_id)
- index_recipe_snapshot_parts_on_recipe_snapshot_id (recipe_snapshot_id)

**外部キー**:
- fk_rails_0989e6ad85 (recipe_snapshot_id) → recipe_snapshots.id
- fk_rails_eede368e91 (part_snapshot_id) → part_snapshots.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END recipe_snapshot_parts -->

<!-- TABLE_BEGIN part_snapshots -->
## part_snapshots

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| part_id | bigint | × |  |  |
| checksum | character varying | × |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| material_category_code | character varying(10) | × |  |  |
| material_code | character varying(16) | × |  |  |
| shape_code | character varying(8) | × |  |  |
| paint_type_code | character varying(4) | ○ |  |  |
| thickness_mm | numeric(8,2) | × |  |  |
| width1_mm | numeric(8,2) | × |  |  |
| width2_mm | numeric(8,2) | ○ |  |  |
| length_mm | numeric(8,2) | × |  |  |
| shape_json | jsonb | ○ | {} |  |
| corner_proc_json | jsonb | ○ | {} |  |
| hole_json | jsonb | ○ | {} |  |
| sqhole_json | jsonb | ○ | {} |  |
| edge_json | jsonb | ○ | {} |  |
| paint_json | jsonb | ○ | {} |  |
| note | text | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| origin_snapshot_id | bigint | ○ |  |  |
| origin_owner_id | bigint | ○ |  |  |

**インデックス**:
- part_snapshots_pkey (id) [PK]
- index_part_snapshots_on_checksum (checksum)
- index_part_snapshots_on_corner_proc_json (corner_proc_json)
- index_part_snapshots_on_created_by_id (created_by_id)
- index_part_snapshots_on_deleted_by_id (deleted_by_id)
- index_part_snapshots_on_hole_json (hole_json)
- index_part_snapshots_on_origin_snapshot_id (origin_snapshot_id)
- index_part_snapshots_on_part_id (part_id)
- index_part_snapshots_on_sqhole_json (sqhole_json)
- index_part_snapshots_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_0a3ba229b5 (paint_type_code) → m_paint_types.code
- fk_rails_140f6f0234 (material_code) → m_materials.code
- fk_rails_44200a9608 (material_category_code) → m_categories.code
- fk_rails_4a942da875 (created_by_id) → users.id
- fk_rails_c44e04702a (updated_by_id) → users.id
- fk_rails_c87b5a313e (part_id) → parts.id
- fk_rails_d38f648163 (shape_code) → m_shapes.code
- fk_rails_dc20f86c16 (deleted_by_id) → users.id

**チェック制約**:
- chk_ps_dims_positive: thickness_mm > 0::numeric AND width1_mm > 0::numeric AND (width2_mm IS NULL OR width2_mm > 0::numeric) AND length_mm > 0::numeric
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END part_snapshots -->

<!-- TABLE_BEGIN part_files -->
## part_files

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| part_id | bigint | × |  |  |
| file_key | character varying | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- part_files_pkey (id) [PK]
- index_part_files_on_part_id (part_id)

**外部キー**:
- fk_rails_0484e77ee6 (part_id) → parts.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END part_files -->

<!-- SECTION_BEGIN 注文系 -->
# 注文系
<!-- SECTION_END 注文系 -->

<!-- TABLE_BEGIN carts -->
## carts

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| user_id | bigint | × |  |  |
| name | character varying(50) | × |  |  |
| status | integer | × | 0 |  |
| shipping_address_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- carts_pkey (id) [PK]
- index_carts_on_shipping_address_id (shipping_address_id)
- index_carts_on_user_id (user_id)

**外部キー**:
- fk_rails_ea59a35211 (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END carts -->

<!-- TABLE_BEGIN cart_parts -->
## cart_parts

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| cart_id | bigint | × |  |  |
| part_id | bigint | × |  |  |
| quantity | integer | × | 1 |  |
| origin_snapshot_id | bigint | ○ |  |  |
| origin_owner_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- cart_parts_pkey (id) [PK]
- index_cart_parts_on_cart_id (cart_id)
- index_cart_parts_on_part_id (part_id)

**外部キー**:
- fk_rails_2c21490359 (part_id) → parts.id
- fk_rails_68d2a11300 (cart_id) → carts.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END cart_parts -->

<!-- TABLE_BEGIN cart_recipes -->
## cart_recipes

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| cart_id | bigint | × |  |  |
| recipe_id | bigint | × |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| quantity | integer | × | 1 |  |

**インデックス**:
- cart_recipes_pkey (id) [PK]
- index_cart_recipes_on_cart_id (cart_id)
- index_cart_recipes_on_recipe_id (recipe_id)

**外部キー**:
- fk_rails_420803c62f (recipe_id) → recipes.id
- fk_rails_dfe4fd2b4e (cart_id) → carts.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END cart_recipes -->

<!-- TABLE_BEGIN rfqs -->
## rfqs

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| user_id | bigint | × |  |  |
| shipping_address_id | bigint | ○ |  |  |
| status | integer | × | 0 |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- rfqs_pkey (id) [PK]
- index_rfqs_on_shipping_address_id (shipping_address_id)
- index_rfqs_on_user_id (user_id)

**外部キー**:
- fk_rails_d1a7ab1876 (user_id) → users.id
- fk_rails_d8f358d538 (shipping_address_id) → member_shipping_addresses.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END rfqs -->

<!-- TABLE_BEGIN rfq_parts -->
## rfq_parts — 見積依頼 (RFQ) を構成する部品スナップショット明細テーブル

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| rfq_id | bigint | × |  | 見積依頼ヘッダ (rfqs.id) |
| part_snapshot_id | bigint | × |  | 対象部品スナップショット (part_snapshots.id) |
| quantity | integer | × | 1 | 見積対象数量 |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| origin_snapshot_id | bigint | × |  | 部品が初出公開されたレシピ‐snapshot ID |
| origin_owner_id | bigint | × |  | 初出公開者ユーザー ID |

**インデックス**:
- rfq_parts_pkey (id) [PK]
- index_rfq_parts_on_origin_owner_id (origin_owner_id)
- index_rfq_parts_on_part_snapshot_id (part_snapshot_id)
- index_rfq_parts_on_rfq_id (rfq_id)

**外部キー**:
- fk_rails_923102ee88 (part_snapshot_id) → part_snapshots.id
- fk_rails_dea4f7c049 (rfq_id) → rfqs.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
**メモ**
- `origin_*` 列は **部品単価報酬先** を決定するキー。  
  *origin が NULL の部品は、`part_snapshot.owner_user_id` を報酬先とみなす。*
- `quantity` は正整数のみ許容。
- `rfq_parts` → `vendor_offer_items` → `orders` と進むことで、部品単価の見積・採用・売上が一貫してトレース可能。
<!-- NOTE END -->

<!-- TABLE_END rfq_parts -->

<!-- TABLE_BEGIN vendor_offers -->
## vendor_offers

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| rfq_id | bigint | × |  |  |
| vendor_id | bigint | × |  |  |
| status | integer | × | 0 |  |
| total_price | numeric(18,4) | ○ | 0.0 |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| sub_total | numeric(18,4) | × | 0.0 |  |
| shipping_fee | numeric(18,4) | × | 0.0 |  |
| tax_rate | numeric(4,2) | × | 10.0 |  |
| tax_amount | numeric(18,4) | × | 0.0 |  |
| received_at | timestamp(6) without time zone | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |

**インデックス**:
- vendor_offers_pkey (id) [PK]
- index_vendor_offers_on_created_by_id (created_by_id)
- index_vendor_offers_on_deleted_by_id (deleted_by_id)
- index_vendor_offers_on_rfq_id (rfq_id)
- index_vendor_offers_on_rfq_id_and_status (rfq_id, status)
- index_vendor_offers_on_status (status)
- index_vendor_offers_on_updated_by_id (updated_by_id)
- index_vendor_offers_on_vendor_id (vendor_id)
- index_vendor_offers_on_vendor_id_and_status (vendor_id, status)
- uniq_vendor_offer_per_rfq (rfq_id, vendor_id) WHERE (deleted_flag = false) [UNIQUE]

**外部キー**:
- fk_rails_37424dfe2f (updated_by_id) → users.id
- fk_rails_4fe5613415 (deleted_by_id) → users.id
- fk_rails_8ad36f27c5 (created_by_id) → users.id
- fk_rails_a3eca65d17 (rfq_id) → rfqs.id
- fk_rails_b8710e984c (vendor_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END vendor_offers -->

<!-- TABLE_BEGIN vendor_offer_items -->
## vendor_offer_items

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| vendor_offer_id | bigint | × |  |  |
| rfq_part_id | bigint | × |  |  |
| unit_price | numeric(18,4) | × |  |  |
| lead_time_days | integer | ○ |  |  |
| note | text | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |

**インデックス**:
- vendor_offer_items_pkey (id) [PK]
- index_vendor_offer_items_on_created_by_id (created_by_id)
- index_vendor_offer_items_on_deleted_by_id (deleted_by_id)
- index_vendor_offer_items_on_rfq_part_id (rfq_part_id)
- index_vendor_offer_items_on_updated_by_id (updated_by_id)
- index_vendor_offer_items_on_vendor_offer_id (vendor_offer_id)
- uniq_offer_item (vendor_offer_id, rfq_part_id) [UNIQUE]

**外部キー**:
- fk_rails_276f1f2b18 (rfq_part_id) → rfq_parts.id
- fk_rails_8605eefbf2 (vendor_offer_id) → vendor_offers.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END vendor_offer_items -->

<!-- TABLE_BEGIN affiliate_signups -->
## affiliate_signups

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| affiliate_user_id | bigint | × |  |  |
| affiliate_click_id | bigint | ○ |  |  |
| signup_user_id | bigint | × |  |  |
| signup_at | timestamp(6) without time zone | × |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- affiliate_signups_pkey (id) [PK]
- index_affiliate_signups_on_affiliate_click_id (affiliate_click_id)
- index_affiliate_signups_on_affiliate_user_id (affiliate_user_id)
- index_affiliate_signups_on_signup_user_id (signup_user_id) [UNIQUE]

**外部キー**:
- fk_rails_00b8de6797 (deleted_by_id) → users.id
- fk_rails_3ef6352d1f (signup_user_id) → users.id
- fk_rails_c7cac3c3b6 (created_by_id) → users.id
- fk_rails_da86bb4702 (affiliate_click_id) → h_affiliate_clicks.id
- fk_rails_df4fe43808 (updated_by_id) → users.id
- fk_rails_fd29361a59 (affiliate_user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END affiliate_signups -->

<!-- TABLE_BEGIN ar_internal_metadata -->
## ar_internal_metadata

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| key | character varying | × |  |  |
| value | character varying | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- ar_internal_metadata_pkey (key) [PK]
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END ar_internal_metadata -->

<!-- TABLE_BEGIN article_media -->
## article_media

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| article_id | bigint | × |  |  |
| media_type | smallint | × |  |  |
| file_url | character varying(500) | × |  |  |
| caption | character varying(150) | ○ |  |  |
| position | smallint | ○ |  |  |
| meta_json | jsonb | ○ | "{}" |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- article_media_pkey (id) [PK]
- index_article_media_on_article_id (article_id)
- index_article_media_on_created_by_id (created_by_id)
- index_article_media_on_deleted_by_id (deleted_by_id)
- index_article_media_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_5019b4f352 (article_id) → articles.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END article_media -->

<!-- TABLE_BEGIN h_affiliate_clicks -->
## h_affiliate_clicks

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| affiliate_user_id | bigint | × |  |  |
| click_token | uuid | × |  |  |
| referrer_url | character varying(500) | ○ |  |  |
| landing_url | character varying(500) | ○ |  |  |
| ip_address | inet | ○ |  |  |
| user_agent | character varying(255) | ○ |  |  |
| clicked_at | timestamp(6) without time zone | × |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- h_affiliate_clicks_pkey (id) [PK]
- index_h_affiliate_clicks_on_affiliate_user_id (affiliate_user_id)
- uq_h_aff_click_token (click_token) [UNIQUE]

**外部キー**:
- fk_rails_800550e991 (affiliate_user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_affiliate_clicks -->

<!-- TABLE_BEGIN article_comments -->
## article_comments

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| article_id | bigint | × |  |  |
| parent_id | bigint | ○ |  |  |
| author_type | character varying(20) | × |  |  |
| author_id | bigint | × |  |  |
| body | text | × |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- article_comments_pkey (id) [PK]
- idx_article_comments_author_polymorphic (author_type, author_id)
- index_article_comments_on_article_id (article_id)
- index_article_comments_on_author_id (author_id)
- index_article_comments_on_created_by_id (created_by_id)
- index_article_comments_on_deleted_by_id (deleted_by_id)
- index_article_comments_on_parent_id (parent_id)
- index_article_comments_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_439c61b372 (deleted_by_id) → users.id
- fk_rails_67982717fa (article_id) → articles.id
- fk_rails_86c76f9c76 (created_by_id) → users.id
- fk_rails_d931c2be38 (parent_id) → article_comments.id
- fk_rails_f0e007d0f8 (updated_by_id) → users.id

**チェック制約**:
- chk_article_comments_author_type: author_type::text = ANY (ARRAY['MemberDetail'::character varying::text, 'VendorDetail'::character varying::text, 'AdminDetail'::character varying::text, 'AffiliateDetail'::character varying::text])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END article_comments -->

<!-- TABLE_BEGIN h_article_views -->
## h_article_views

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| article_id | bigint | × |  |  |
| user_id | bigint | ○ |  |  |
| ip_address | inet | ○ |  |  |
| viewed_at | timestamp with time zone | × |  |  |
| ua_hash | character(32) | ○ |  |  |
| processed_flag | boolean | × | false |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- idx_article_views_unprocessed (article_id) WHERE (processed_flag = false)
- index_h_article_views_on_article_id (article_id)
- index_h_article_views_on_id (id)
- index_h_article_views_on_user_id (user_id)

**外部キー**:
- h_article_views_article_id_fkey (article_id) → articles.id
- h_article_views_user_id_fkey (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_article_views -->

<!-- TABLE_BEGIN affiliate_commissions -->
## affiliate_commissions

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| affiliate_user_id | bigint | × |  |  |
| referred_user_id | bigint | × |  |  |
| order_id | bigint | × |  |  |
| order_amount | numeric(18,4) | × | 0.0 |  |
| rate_pct | numeric(5,2) | × | 0.0 |  |
| commission_amount | numeric(18,4) | × | 0.0 |  |
| paid_flag | boolean | × | false |  |
| paid_at | timestamp(6) without time zone | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- affiliate_commissions_pkey (id) [PK]
- index_affiliate_commissions_on_affiliate_user_id (affiliate_user_id)
- index_affiliate_commissions_on_created_by_id (created_by_id)
- index_affiliate_commissions_on_deleted_by_id (deleted_by_id)
- index_affiliate_commissions_on_order_id (order_id)
- index_affiliate_commissions_on_referred_user_id (referred_user_id)
- index_affiliate_commissions_on_updated_by_id (updated_by_id)
- uq_aff_comm_order (order_id) [UNIQUE]

**外部キー**:
- fk_rails_03512ee4df (updated_by_id) → users.id
- fk_rails_71684630c8 (created_by_id) → users.id
- fk_rails_8fd375453d (referred_user_id) → users.id
- fk_rails_939dc7f310 (affiliate_user_id) → users.id
- fk_rails_996822f75d (deleted_by_id) → users.id
- fk_rails_ef4e150db0 (order_id) → orders.id

**チェック制約**:
- chk_aff_comm_amount_non_negative: commission_amount >= 0::numeric
- chk_aff_comm_paid_consistency: NOT paid_flag OR paid_at IS NOT NULL
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END affiliate_commissions -->

<!-- TABLE_BEGIN article_likes -->
## article_likes

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| article_id | bigint | × |  |  |
| user_id | bigint | × |  |  |
| created_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- article_likes_pkey (id) [PK]
- index_article_likes_on_article_id (article_id)
- index_article_likes_on_user_id (user_id)
- uq_article_likes_article_user (article_id, user_id) [UNIQUE]

**外部キー**:
- fk_rails_2280bc43bb (user_id) → users.id
- fk_rails_3f46dcc174 (article_id) → articles.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END article_likes -->

<!-- TABLE_BEGIN articles -->
## articles

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| author_type | character varying(20) | × |  |  |
| author_id | bigint | × |  |  |
| category | smallint | × |  |  |
| title | character varying(150) | × |  |  |
| content_blocks | jsonb | × | "{}" |  |
| order_id | bigint | ○ |  |  |
| likes_count | integer | × | 0 |  |
| replies_count | integer | × | 0 |  |
| views_count | integer | × | 0 |  |
| published_at | timestamp(6) without time zone | ○ |  |  |
| is_draft | boolean | × | false |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- articles_pkey (id) [PK]
- index_articles_on_author_type_and_author_id (author_type, author_id)
- index_articles_on_content_blocks (content_blocks)
- index_articles_on_likes_count (likes_count)
- index_articles_on_order_id (order_id)
- index_articles_on_replies_count (replies_count)
- index_articles_on_views_count (views_count)

**外部キー**:
- fk_rails_35e2f292e3 (created_by_id) → users.id
- fk_rails_4297cebbfe (order_id) → orders.id
- fk_rails_60cb0a2f23 (updated_by_id) → users.id
- fk_rails_d87756143c (deleted_by_id) → users.id

**チェック制約**:
- chk_articles_author_type: author_type::text = ANY (ARRAY['MemberDetail'::character varying::text, 'VendorDetail'::character varying::text, 'AdminDetail'::character varying::text, 'AffiliateDetail'::character varying::text])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END articles -->

<!-- TABLE_BEGIN h_audit_trails -->
## h_audit_trails

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| table_name | character varying(60) | × |  |  |
| pk_value | text | × |  |  |
| action | character(1) | × |  |  |
| changed_by | bigint | ○ |  |  |
| before_json | jsonb | ○ |  |  |
| after_json | jsonb | ○ |  |  |
| changed_at | timestamp with time zone | × |  |  |

**インデックス**:
- index_h_audit_trails_on_changed_by (changed_by)
- index_h_audit_trails_on_id (id)
- index_h_audit_trails_on_table_name (table_name)

**外部キー**:
- h_audit_trails_changed_by_fkey (changed_by) → users.id

**チェック制約**:
- h_audit_trails_action_check: action = ANY (ARRAY['I'::bpchar, 'U'::bpchar, 'D'::bpchar])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_audit_trails -->

<!-- TABLE_BEGIN h_error_logs -->
## h_error_logs

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| error_class | character varying(120) | × |  |  |
| message | text | × |  |  |
| stacktrace_compressed | bytea | × |  |  |
| stack_head | text | ○ |  |  |
| request_path | character varying(255) | ○ |  |  |
| http_method | character(6) | ○ |  |  |
| status_code | smallint | × | 500 |  |
| params_json | jsonb | ○ |  |  |
| user_id | bigint | ○ |  |  |
| request_id | character(36) | ○ |  |  |
| ip_address | inet | ○ |  |  |
| user_agent | character varying(255) | ○ |  |  |
| server_name | character varying(60) | ○ |  |  |
| environment | character(10) | × |  |  |
| occurred_at | timestamp with time zone | × |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- index_h_error_logs_on_error_class (error_class)
- index_h_error_logs_on_id (id)
- index_h_error_logs_on_request_id (request_id)
- index_h_error_logs_on_request_path (request_path)
- index_h_error_logs_on_user_id (user_id)

**外部キー**:
- h_error_logs_user_id_fkey (user_id) → users.id

**チェック制約**:
- h_error_logs_environment_check: environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_error_logs -->

<!-- TABLE_BEGIN h_login_attempts -->
## h_login_attempts

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| user_id | bigint | ○ |  |  |
| email_tried | character varying(255) | × |  |  |
| ip_address | inet | × |  |  |
| user_agent | text | × |  |  |
| result | smallint | × |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- index_h_login_attempts_on_id (id)
- index_h_login_attempts_on_ip_address (ip_address)
- index_h_login_attempts_on_user_id (user_id)

**外部キー**:
- h_login_attempts_user_id_fkey (user_id) → users.id

**チェック制約**:
- h_login_attempts_result_check: result = ANY (ARRAY[0, 1, 2])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_login_attempts -->

<!-- TABLE_BEGIN h_error_logs_202601 -->
## h_error_logs_202601

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| error_class | character varying(120) | × |  |  |
| message | text | × |  |  |
| stacktrace_compressed | bytea | × |  |  |
| stack_head | text | ○ |  |  |
| request_path | character varying(255) | ○ |  |  |
| http_method | character(6) | ○ |  |  |
| status_code | smallint | × | 500 |  |
| params_json | jsonb | ○ |  |  |
| user_id | bigint | ○ |  |  |
| request_id | character(36) | ○ |  |  |
| ip_address | inet | ○ |  |  |
| user_agent | character varying(255) | ○ |  |  |
| server_name | character varying(60) | ○ |  |  |
| environment | character(10) | × |  |  |
| occurred_at | timestamp with time zone | × |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_error_logs_202601_error_class_idx (error_class)
- h_error_logs_202601_id_idx (id)
- h_error_logs_202601_request_id_idx (request_id)
- h_error_logs_202601_request_path_idx (request_path)
- h_error_logs_202601_user_id_idx (user_id)

**外部キー**:
- h_error_logs_user_id_fkey (user_id) → users.id

**チェック制約**:
- h_error_logs_environment_check: environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_error_logs_202601 -->

<!-- TABLE_BEGIN h_payment_webhooks -->
## h_payment_webhooks

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| gateway | character varying(30) | × |  |  |
| event_id | character varying(255) | × |  |  |
| event_type | character varying(50) | × |  |  |
| http_status | smallint | × |  |  |
| signature | character varying(255) | ○ |  |  |
| payload_json | jsonb | × |  |  |
| order_id | bigint | ○ |  |  |
| payout_id | bigint | ○ |  |  |
| processed_at | timestamp with time zone | ○ |  |  |
| processing_result | smallint | ○ |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- idx_hpwebhook_gateway_event (gateway, event_id)

**外部キー**:
- h_payment_webhooks_order_id_fkey (order_id) → orders.id
- h_payment_webhooks_payout_id_fkey (payout_id) → payouts.id

**チェック制約**:
- h_payment_webhooks_processing_result_check: processing_result IS NULL OR (processing_result = ANY (ARRAY[0, 1, 2]))
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_payment_webhooks -->

<!-- TABLE_BEGIN h_payout_events -->
## h_payout_events

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| payout_id | bigint | × |  |  |
| event | character varying(30) | × |  |  |
| meta_json | jsonb | ○ |  |  |
| occurred_at | timestamp(6) without time zone | × |  |  |
| logged_by_type | character varying(20) | ○ |  |  |
| logged_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- h_payout_events_pkey (id) [PK]
- idx_hpe_logger (logged_by_type, logged_by_id)
- index_h_payout_events_on_event (event)
- index_h_payout_events_on_occurred_at (occurred_at)
- index_h_payout_events_on_payout_id (payout_id)

**外部キー**:
- fk_rails_bd2df7a8c8 (payout_id) → payouts.id

**チェック制約**:
- chk_hpe_logged_by_type: (logged_by_type::text = ANY (ARRAY['System'::character varying::text, 'User'::character varying::text, 'Admin'::character varying::text])) OR logged_by_type IS NULL
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_payout_events -->

<!-- TABLE_BEGIN notifications -->
## notifications

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| recipient_type | character varying | × |  |  |
| recipient_id | bigint | × |  |  |
| channel | smallint | × |  |  |
| notification_type | character varying(30) | × |  |  |
| subject | character varying(150) | ○ |  |  |
| body | text | ○ |  |  |
| payload_json | jsonb | ○ |  |  |
| related_model_type | character varying(30) | ○ |  |  |
| related_model_id | bigint | ○ |  |  |
| status | smallint | × | 0 |  |
| broadcast_id | uuid | ○ |  |  |
| sent_at | timestamp(6) without time zone | ○ |  |  |
| read_at | timestamp(6) without time zone | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- notifications_pkey (id) [PK]
- idx_notifications_recipient_status (recipient_type, recipient_id, status)
- idx_notifications_related (related_model_type, related_model_id)
- index_notifications_on_broadcast_id (broadcast_id)
- index_notifications_on_notification_type (notification_type)

**外部キー**:
- fk_rails_1b74717c67 (deleted_by_id) → users.id
- fk_rails_5449be7f30 (updated_by_id) → users.id
- fk_rails_ee2be4cca6 (created_by_id) → users.id

**チェック制約**:
- chk_notifications_recipient_type: recipient_type::text = ANY (ARRAY['MemberDetail'::character varying::text, 'VendorDetail'::character varying::text, 'AdminDetail'::character varying::text, 'AffiliateDetail'::character varying::text])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END notifications -->

<!-- TABLE_BEGIN orders -->
## orders

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| user_id | bigint | × |  |  |
| vendor_id | bigint | × |  |  |
| affiliate_id | bigint | ○ |  |  |
| status | smallint | × | 0 |  |
| total_amount | numeric(18,4) | × | 0.0 |  |
| shipping_address_id | bigint | × |  |  |
| shipping_method | smallint | × | 0 |  |
| shipping_size_class | smallint | ○ |  |  |
| paid_at | timestamp(6) without time zone | ○ |  |  |
| shipped_at | timestamp(6) without time zone | ○ |  |  |
| delivered_at | timestamp(6) without time zone | ○ |  |  |
| shipping_tracking_no | character varying(50) | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| vendor_offer_id | bigint | × |  |  |

**インデックス**:
- orders_pkey (id) [PK]
- index_orders_on_affiliate_id (affiliate_id)
- index_orders_on_created_by_id (created_by_id)
- index_orders_on_deleted_by_id (deleted_by_id)
- index_orders_on_shipping_address_id (shipping_address_id)
- index_orders_on_updated_by_id (updated_by_id)
- index_orders_on_user_id (user_id)
- index_orders_on_vendor_id (vendor_id)
- index_orders_on_vendor_offer_id (vendor_offer_id)

**外部キー**:
- fk_rails_267c198c1b (shipping_address_id) → transaction_shipping_addresses.id ON DELETE RESTRICT
- fk_rails_3785801b9a (vendor_offer_id) → vendor_offers.id
- fk_rails_38adeaa02b (updated_by_id) → users.id
- fk_rails_9a312b3a4c (affiliate_id) → users.id
- fk_rails_9ac523da23 (created_by_id) → users.id
- fk_rails_dc1006bb54 (deleted_by_id) → users.id
- fk_rails_f6acf748cd (vendor_id) → users.id
- fk_rails_f868b47f6a (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END orders -->

<!-- TABLE_BEGIN order_reviews -->
## order_reviews

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| order_id | bigint | × |  |  |
| reviewer_id | bigint | × |  |  |
| vendor_id | bigint | × |  |  |
| rating | jsonb | × |  |  |
| title | character varying(100) | ○ |  |  |
| comment | text | ○ |  |  |
| vendor_reply | text | ○ |  |  |
| replied_at | timestamp(6) without time zone | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- order_reviews_pkey (id) [PK]
- index_order_reviews_on_created_by_id (created_by_id)
- index_order_reviews_on_deleted_by_id (deleted_by_id)
- index_order_reviews_on_order_id (order_id) [UNIQUE]
- index_order_reviews_on_reviewer_id (reviewer_id)
- index_order_reviews_on_updated_by_id (updated_by_id)
- index_order_reviews_on_vendor_id (vendor_id)

**外部キー**:
- fk_rails_19289e95c6 (vendor_id) → users.id
- fk_rails_218234f6ac (order_id) → orders.id
- fk_rails_7266ab26e5 (deleted_by_id) → users.id
- fk_rails_91fa08e5f2 (updated_by_id) → users.id
- fk_rails_b27d5eba1f (reviewer_id) → users.id
- fk_rails_db794df21d (created_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END order_reviews -->

<!-- TABLE_BEGIN schema_migrations -->
## schema_migrations

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| version | character varying | × |  |  |

**インデックス**:
- schema_migrations_pkey (version) [PK]
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END schema_migrations -->

<!-- TABLE_BEGIN payouts -->
## payouts

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| payee_type | character varying(20) | × |  |  |
| payee_id | bigint | × |  |  |
| period_from | date | ○ |  |  |
| period_to | date | ○ |  |  |
| gross_amount | numeric(18,4) | × | 0.0 |  |
| commission_amount | numeric(18,4) | × | 0.0 |  |
| net_amount | numeric(18,4) | × | 0.0 |  |
| status | smallint | × | 0 |  |
| payout_at | timestamp(6) without time zone | ○ |  |  |
| transaction_ref | character varying(100) | ○ |  |  |
| bank_name | character varying(100) | ○ |  |  |
| account_type | smallint | ○ |  |  |
| account_number | character varying(30) | ○ |  |  |
| remarks | text | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- payouts_pkey (id) [PK]
- index_payouts_on_created_by_id (created_by_id)
- index_payouts_on_deleted_by_id (deleted_by_id)
- index_payouts_on_payee_type_and_payee_id (payee_type, payee_id)
- index_payouts_on_transaction_ref (transaction_ref) [UNIQUE]
- index_payouts_on_updated_by_id (updated_by_id)
- uq_payouts_period (payee_type, payee_id, period_from, period_to) [UNIQUE]

**外部キー**:
- fk_rails_1680a8e85c (transaction_ref) → stripe_payouts.payout_id
- fk_rails_7e89b17246 (deleted_by_id) → users.id
- fk_rails_8ae13af0e2 (updated_by_id) → users.id
- fk_rails_c50a09411a (created_by_id) → users.id

**チェック制約**:
- chk_payouts_payee_type: payee_type::text = ANY (ARRAY['MemberDetail'::character varying::text, 'VendorDetail'::character varying::text, 'AdminDetail'::character varying::text, 'AffiliateDetail'::character varying::text])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END payouts -->

<!-- TABLE_BEGIN stripe_accounts -->
## stripe_accounts

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| user_id | bigint | × |  |  |
| stripe_account_id | character varying(255) | × |  |  |
| charges_enabled | boolean | × | false |  |
| payouts_enabled | boolean | × | false |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- index_stripe_accounts_on_created_by_id (created_by_id)
- index_stripe_accounts_on_deleted_by_id (deleted_by_id)
- index_stripe_accounts_on_stripe_account_id (stripe_account_id) [UNIQUE]
- index_stripe_accounts_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_5022b25805 (deleted_by_id) → users.id
- fk_rails_5760439bf2 (updated_by_id) → users.id
- fk_rails_764fb7bcbe (user_id) → users.id
- fk_rails_7feb656bba (created_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END stripe_accounts -->

<!-- TABLE_BEGIN stripe_events -->
## stripe_events

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| event_id | character varying(255) | × |  |  |
| account_id | character varying(255) | × |  |  |
| type | character varying(64) | × |  |  |
| payload | jsonb | × |  |  |
| received_at | timestamp(6) without time zone | × |  |  |
| processed_at | timestamp(6) without time zone | ○ |  |  |
| status | character varying(16) | ○ |  |  |

**インデックス**:
- stripe_events_pkey (event_id) [PK]
- index_stripe_events_on_account_id (account_id)
- index_stripe_events_on_processed_at (processed_at)
- index_stripe_events_on_status (status)
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END stripe_events -->

<!-- TABLE_BEGIN stripe_payments -->
## stripe_payments

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| order_id | bigint | × |  |  |
| payment_intent_id | character varying(255) | × |  |  |
| charge_id | character varying(255) | × |  |  |
| transfer_id | character varying(255) | × |  |  |
| application_fee_id | character varying(255) | × |  |  |
| amount | numeric(18,4) | × | 0.0 |  |
| currency | character varying(3) | × | JPY |  |
| platform_fee | numeric(18,4) | × | 0.0 |  |
| net_amount | numeric(18,4) | × | 0.0 |  |
| status | character varying(32) | × |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- stripe_payments_pkey (id) [PK]
- index_stripe_payments_on_created_by_id (created_by_id)
- index_stripe_payments_on_deleted_by_id (deleted_by_id)
- index_stripe_payments_on_order_id (order_id) [UNIQUE]
- index_stripe_payments_on_payment_intent_id (payment_intent_id) [UNIQUE]
- index_stripe_payments_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_0c6d02e37c (created_by_id) → users.id
- fk_rails_47bb1f7459 (updated_by_id) → users.id
- fk_rails_4b62aa0798 (deleted_by_id) → users.id
- fk_rails_7d60b0916f (order_id) → orders.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END stripe_payments -->

<!-- TABLE_BEGIN stripe_payouts -->
## stripe_payouts

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| payout_id | character varying | × |  |  |
| stripe_account_id | character varying(255) | × |  |  |
| amount | numeric(18,4) | × | 0.0 |  |
| arrival_date | date | × |  |  |
| status | character varying(16) | × |  |  |
| failure_code | character varying(32) | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- stripe_payouts_pkey (payout_id) [PK]
- index_stripe_payouts_on_created_by_id (created_by_id)
- index_stripe_payouts_on_deleted_by_id (deleted_by_id)
- index_stripe_payouts_on_stripe_account_id (stripe_account_id)
- index_stripe_payouts_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_0164871fc3 (created_by_id) → users.id
- fk_rails_981e366b28 (stripe_account_id) → stripe_accounts.stripe_account_id
- fk_rails_dc468b0d39 (deleted_by_id) → users.id
- fk_rails_ec98cdcaa7 (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END stripe_payouts -->

<!-- TABLE_BEGIN stripe_refunds -->
## stripe_refunds

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| refund_id | character varying(255) | × |  |  |
| payment_intent_id | character varying(255) | × |  |  |
| amount | numeric(18,4) | × | 0.0 |  |
| status | character varying(16) | × |  |  |
| reason | character varying(32) | × |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- stripe_refunds_pkey (refund_id) [PK]
- index_stripe_refunds_on_created_by_id (created_by_id)
- index_stripe_refunds_on_deleted_by_id (deleted_by_id)
- index_stripe_refunds_on_payment_intent_id (payment_intent_id)
- index_stripe_refunds_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_27113da1c6 (created_by_id) → users.id
- fk_rails_7b3495b678 (deleted_by_id) → users.id
- fk_rails_9e3b8e9a53 (updated_by_id) → users.id
- fk_rails_b61ac62e9e (payment_intent_id) → stripe_payments.payment_intent_id ON DELETE CASCADE
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END stripe_refunds -->

<!-- TABLE_BEGIN h_article_views_202510 -->
## h_article_views_202510

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| article_id | bigint | × |  |  |
| user_id | bigint | ○ |  |  |
| ip_address | inet | ○ |  |  |
| viewed_at | timestamp with time zone | × |  |  |
| ua_hash | character(32) | ○ |  |  |
| processed_flag | boolean | × | false |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_article_views_202510_article_id_idx (article_id)
- h_article_views_202510_article_id_idx1 (article_id) WHERE (processed_flag = false)
- h_article_views_202510_id_idx (id)
- h_article_views_202510_unproc_idx (article_id) WHERE (processed_flag = false)
- h_article_views_202510_user_id_idx (user_id)

**外部キー**:
- h_article_views_article_id_fkey (article_id) → articles.id
- h_article_views_user_id_fkey (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_article_views_202510 -->

<!-- TABLE_BEGIN h_article_views_202512 -->
## h_article_views_202512

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| article_id | bigint | × |  |  |
| user_id | bigint | ○ |  |  |
| ip_address | inet | ○ |  |  |
| viewed_at | timestamp with time zone | × |  |  |
| ua_hash | character(32) | ○ |  |  |
| processed_flag | boolean | × | false |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_article_views_202512_article_id_idx (article_id)
- h_article_views_202512_article_id_idx1 (article_id) WHERE (processed_flag = false)
- h_article_views_202512_id_idx (id)
- h_article_views_202512_unproc_idx (article_id) WHERE (processed_flag = false)
- h_article_views_202512_user_id_idx (user_id)

**外部キー**:
- h_article_views_article_id_fkey (article_id) → articles.id
- h_article_views_user_id_fkey (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_article_views_202512 -->

<!-- TABLE_BEGIN h_article_views_202601 -->
## h_article_views_202601

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| article_id | bigint | × |  |  |
| user_id | bigint | ○ |  |  |
| ip_address | inet | ○ |  |  |
| viewed_at | timestamp with time zone | × |  |  |
| ua_hash | character(32) | ○ |  |  |
| processed_flag | boolean | × | false |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_article_views_202601_article_id_idx (article_id)
- h_article_views_202601_article_id_idx1 (article_id) WHERE (processed_flag = false)
- h_article_views_202601_id_idx (id)
- h_article_views_202601_unproc_idx (article_id) WHERE (processed_flag = false)
- h_article_views_202601_user_id_idx (user_id)

**外部キー**:
- h_article_views_article_id_fkey (article_id) → articles.id
- h_article_views_user_id_fkey (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_article_views_202601 -->

<!-- TABLE_BEGIN h_article_views_202602 -->
## h_article_views_202602

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| article_id | bigint | × |  |  |
| user_id | bigint | ○ |  |  |
| ip_address | inet | ○ |  |  |
| viewed_at | timestamp with time zone | × |  |  |
| ua_hash | character(32) | ○ |  |  |
| processed_flag | boolean | × | false |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_article_views_202602_article_id_idx (article_id)
- h_article_views_202602_article_id_idx1 (article_id) WHERE (processed_flag = false)
- h_article_views_202602_id_idx (id)
- h_article_views_202602_unproc_idx (article_id) WHERE (processed_flag = false)
- h_article_views_202602_user_id_idx (user_id)

**外部キー**:
- h_article_views_article_id_fkey (article_id) → articles.id
- h_article_views_user_id_fkey (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_article_views_202602 -->

<!-- TABLE_BEGIN h_audit_trails_202505 -->
## h_audit_trails_202505

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| table_name | character varying(60) | × |  |  |
| pk_value | text | × |  |  |
| action | character(1) | × |  |  |
| changed_by | bigint | ○ |  |  |
| before_json | jsonb | ○ |  |  |
| after_json | jsonb | ○ |  |  |
| changed_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_audit_trails_202505_changed_by_idx (changed_by)
- h_audit_trails_202505_changed_by_idx1 (changed_by)
- h_audit_trails_202505_id_idx (id)
- h_audit_trails_202505_id_idx1 (id)
- h_audit_trails_202505_table_name_idx (table_name)
- h_audit_trails_202505_table_name_idx1 (table_name)

**外部キー**:
- h_audit_trails_changed_by_fkey (changed_by) → users.id

**チェック制約**:
- h_audit_trails_action_check: action = ANY (ARRAY['I'::bpchar, 'U'::bpchar, 'D'::bpchar])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_audit_trails_202505 -->

<!-- TABLE_BEGIN h_login_attempts_202505 -->
## h_login_attempts_202505

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| user_id | bigint | ○ |  |  |
| email_tried | character varying(255) | × |  |  |
| ip_address | inet | × |  |  |
| user_agent | text | × |  |  |
| result | smallint | × |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_login_attempts_202505_id_idx (id)
- h_login_attempts_202505_id_idx1 (id)
- h_login_attempts_202505_ip_address_idx (ip_address)
- h_login_attempts_202505_ip_address_idx1 (ip_address)
- h_login_attempts_202505_user_id_idx (user_id)
- h_login_attempts_202505_user_id_idx1 (user_id)

**外部キー**:
- h_login_attempts_user_id_fkey (user_id) → users.id

**チェック制約**:
- h_login_attempts_result_check: result = ANY (ARRAY[0, 1, 2])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_login_attempts_202505 -->

<!-- TABLE_BEGIN h_payment_webhooks_202505 -->
## h_payment_webhooks_202505

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| gateway | character varying(30) | × |  |  |
| event_id | character varying(255) | × |  |  |
| event_type | character varying(50) | × |  |  |
| http_status | smallint | × |  |  |
| signature | character varying(255) | ○ |  |  |
| payload_json | jsonb | × |  |  |
| order_id | bigint | ○ |  |  |
| payout_id | bigint | ○ |  |  |
| processed_at | timestamp with time zone | ○ |  |  |
| processing_result | smallint | ○ |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_payment_webhooks_202505_gateway_event_id_idx (gateway, event_id)
- h_payment_webhooks_202505_uq (gateway, event_id) [UNIQUE]

**外部キー**:
- h_payment_webhooks_order_id_fkey (order_id) → orders.id
- h_payment_webhooks_payout_id_fkey (payout_id) → payouts.id

**チェック制約**:
- h_payment_webhooks_processing_result_check: processing_result IS NULL OR (processing_result = ANY (ARRAY[0, 1, 2]))
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_payment_webhooks_202505 -->

<!-- TABLE_BEGIN h_payment_webhooks_202506 -->
## h_payment_webhooks_202506

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| gateway | character varying(30) | × |  |  |
| event_id | character varying(255) | × |  |  |
| event_type | character varying(50) | × |  |  |
| http_status | smallint | × |  |  |
| signature | character varying(255) | ○ |  |  |
| payload_json | jsonb | × |  |  |
| order_id | bigint | ○ |  |  |
| payout_id | bigint | ○ |  |  |
| processed_at | timestamp with time zone | ○ |  |  |
| processing_result | smallint | ○ |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_payment_webhooks_202506_gateway_event_id_idx (gateway, event_id)
- h_payment_webhooks_202506_uq (gateway, event_id) [UNIQUE]

**外部キー**:
- h_payment_webhooks_order_id_fkey (order_id) → orders.id
- h_payment_webhooks_payout_id_fkey (payout_id) → payouts.id

**チェック制約**:
- h_payment_webhooks_processing_result_check: processing_result IS NULL OR (processing_result = ANY (ARRAY[0, 1, 2]))
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_payment_webhooks_202506 -->

<!-- TABLE_BEGIN h_payment_webhooks_202507 -->
## h_payment_webhooks_202507

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| gateway | character varying(30) | × |  |  |
| event_id | character varying(255) | × |  |  |
| event_type | character varying(50) | × |  |  |
| http_status | smallint | × |  |  |
| signature | character varying(255) | ○ |  |  |
| payload_json | jsonb | × |  |  |
| order_id | bigint | ○ |  |  |
| payout_id | bigint | ○ |  |  |
| processed_at | timestamp with time zone | ○ |  |  |
| processing_result | smallint | ○ |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_payment_webhooks_202507_gateway_event_id_idx (gateway, event_id)
- h_payment_webhooks_202507_uq (gateway, event_id) [UNIQUE]

**外部キー**:
- h_payment_webhooks_order_id_fkey (order_id) → orders.id
- h_payment_webhooks_payout_id_fkey (payout_id) → payouts.id

**チェック制約**:
- h_payment_webhooks_processing_result_check: processing_result IS NULL OR (processing_result = ANY (ARRAY[0, 1, 2]))
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_payment_webhooks_202507 -->

<!-- TABLE_BEGIN h_payment_webhooks_202508 -->
## h_payment_webhooks_202508

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| gateway | character varying(30) | × |  |  |
| event_id | character varying(255) | × |  |  |
| event_type | character varying(50) | × |  |  |
| http_status | smallint | × |  |  |
| signature | character varying(255) | ○ |  |  |
| payload_json | jsonb | × |  |  |
| order_id | bigint | ○ |  |  |
| payout_id | bigint | ○ |  |  |
| processed_at | timestamp with time zone | ○ |  |  |
| processing_result | smallint | ○ |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_payment_webhooks_202508_gateway_event_id_idx (gateway, event_id)
- h_payment_webhooks_202508_uq (gateway, event_id) [UNIQUE]

**外部キー**:
- h_payment_webhooks_order_id_fkey (order_id) → orders.id
- h_payment_webhooks_payout_id_fkey (payout_id) → payouts.id

**チェック制約**:
- h_payment_webhooks_processing_result_check: processing_result IS NULL OR (processing_result = ANY (ARRAY[0, 1, 2]))
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_payment_webhooks_202508 -->

<!-- TABLE_BEGIN h_payment_webhooks_202510 -->
## h_payment_webhooks_202510

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| gateway | character varying(30) | × |  |  |
| event_id | character varying(255) | × |  |  |
| event_type | character varying(50) | × |  |  |
| http_status | smallint | × |  |  |
| signature | character varying(255) | ○ |  |  |
| payload_json | jsonb | × |  |  |
| order_id | bigint | ○ |  |  |
| payout_id | bigint | ○ |  |  |
| processed_at | timestamp with time zone | ○ |  |  |
| processing_result | smallint | ○ |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_payment_webhooks_202510_gateway_event_id_idx (gateway, event_id)
- h_payment_webhooks_202510_uq (gateway, event_id) [UNIQUE]

**外部キー**:
- h_payment_webhooks_order_id_fkey (order_id) → orders.id
- h_payment_webhooks_payout_id_fkey (payout_id) → payouts.id

**チェック制約**:
- h_payment_webhooks_processing_result_check: processing_result IS NULL OR (processing_result = ANY (ARRAY[0, 1, 2]))
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_payment_webhooks_202510 -->

<!-- TABLE_BEGIN h_error_logs_202505 -->
## h_error_logs_202505

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| error_class | character varying(120) | × |  |  |
| message | text | × |  |  |
| stacktrace_compressed | bytea | × |  |  |
| stack_head | text | ○ |  |  |
| request_path | character varying(255) | ○ |  |  |
| http_method | character(6) | ○ |  |  |
| status_code | smallint | × | 500 |  |
| params_json | jsonb | ○ |  |  |
| user_id | bigint | ○ |  |  |
| request_id | character(36) | ○ |  |  |
| ip_address | inet | ○ |  |  |
| user_agent | character varying(255) | ○ |  |  |
| server_name | character varying(60) | ○ |  |  |
| environment | character(10) | × |  |  |
| occurred_at | timestamp with time zone | × |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_error_logs_202505_error_class_idx (error_class)
- h_error_logs_202505_id_idx (id)
- h_error_logs_202505_request_id_idx (request_id)
- h_error_logs_202505_request_path_idx (request_path)
- h_error_logs_202505_user_id_idx (user_id)

**外部キー**:
- h_error_logs_user_id_fkey (user_id) → users.id

**チェック制約**:
- h_error_logs_environment_check: environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_error_logs_202505 -->

<!-- TABLE_BEGIN h_error_logs_202506 -->
## h_error_logs_202506

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| error_class | character varying(120) | × |  |  |
| message | text | × |  |  |
| stacktrace_compressed | bytea | × |  |  |
| stack_head | text | ○ |  |  |
| request_path | character varying(255) | ○ |  |  |
| http_method | character(6) | ○ |  |  |
| status_code | smallint | × | 500 |  |
| params_json | jsonb | ○ |  |  |
| user_id | bigint | ○ |  |  |
| request_id | character(36) | ○ |  |  |
| ip_address | inet | ○ |  |  |
| user_agent | character varying(255) | ○ |  |  |
| server_name | character varying(60) | ○ |  |  |
| environment | character(10) | × |  |  |
| occurred_at | timestamp with time zone | × |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_error_logs_202506_error_class_idx (error_class)
- h_error_logs_202506_id_idx (id)
- h_error_logs_202506_request_id_idx (request_id)
- h_error_logs_202506_request_path_idx (request_path)
- h_error_logs_202506_user_id_idx (user_id)

**外部キー**:
- h_error_logs_user_id_fkey (user_id) → users.id

**チェック制約**:
- h_error_logs_environment_check: environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_error_logs_202506 -->

<!-- TABLE_BEGIN h_error_logs_202507 -->
## h_error_logs_202507

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| error_class | character varying(120) | × |  |  |
| message | text | × |  |  |
| stacktrace_compressed | bytea | × |  |  |
| stack_head | text | ○ |  |  |
| request_path | character varying(255) | ○ |  |  |
| http_method | character(6) | ○ |  |  |
| status_code | smallint | × | 500 |  |
| params_json | jsonb | ○ |  |  |
| user_id | bigint | ○ |  |  |
| request_id | character(36) | ○ |  |  |
| ip_address | inet | ○ |  |  |
| user_agent | character varying(255) | ○ |  |  |
| server_name | character varying(60) | ○ |  |  |
| environment | character(10) | × |  |  |
| occurred_at | timestamp with time zone | × |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_error_logs_202507_error_class_idx (error_class)
- h_error_logs_202507_id_idx (id)
- h_error_logs_202507_request_id_idx (request_id)
- h_error_logs_202507_request_path_idx (request_path)
- h_error_logs_202507_user_id_idx (user_id)

**外部キー**:
- h_error_logs_user_id_fkey (user_id) → users.id

**チェック制約**:
- h_error_logs_environment_check: environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_error_logs_202507 -->

<!-- TABLE_BEGIN h_error_logs_202508 -->
## h_error_logs_202508

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| error_class | character varying(120) | × |  |  |
| message | text | × |  |  |
| stacktrace_compressed | bytea | × |  |  |
| stack_head | text | ○ |  |  |
| request_path | character varying(255) | ○ |  |  |
| http_method | character(6) | ○ |  |  |
| status_code | smallint | × | 500 |  |
| params_json | jsonb | ○ |  |  |
| user_id | bigint | ○ |  |  |
| request_id | character(36) | ○ |  |  |
| ip_address | inet | ○ |  |  |
| user_agent | character varying(255) | ○ |  |  |
| server_name | character varying(60) | ○ |  |  |
| environment | character(10) | × |  |  |
| occurred_at | timestamp with time zone | × |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_error_logs_202508_error_class_idx (error_class)
- h_error_logs_202508_id_idx (id)
- h_error_logs_202508_request_id_idx (request_id)
- h_error_logs_202508_request_path_idx (request_path)
- h_error_logs_202508_user_id_idx (user_id)

**外部キー**:
- h_error_logs_user_id_fkey (user_id) → users.id

**チェック制約**:
- h_error_logs_environment_check: environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_error_logs_202508 -->

<!-- TABLE_BEGIN h_error_logs_202509 -->
## h_error_logs_202509

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| error_class | character varying(120) | × |  |  |
| message | text | × |  |  |
| stacktrace_compressed | bytea | × |  |  |
| stack_head | text | ○ |  |  |
| request_path | character varying(255) | ○ |  |  |
| http_method | character(6) | ○ |  |  |
| status_code | smallint | × | 500 |  |
| params_json | jsonb | ○ |  |  |
| user_id | bigint | ○ |  |  |
| request_id | character(36) | ○ |  |  |
| ip_address | inet | ○ |  |  |
| user_agent | character varying(255) | ○ |  |  |
| server_name | character varying(60) | ○ |  |  |
| environment | character(10) | × |  |  |
| occurred_at | timestamp with time zone | × |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_error_logs_202509_error_class_idx (error_class)
- h_error_logs_202509_id_idx (id)
- h_error_logs_202509_request_id_idx (request_id)
- h_error_logs_202509_request_path_idx (request_path)
- h_error_logs_202509_user_id_idx (user_id)

**外部キー**:
- h_error_logs_user_id_fkey (user_id) → users.id

**チェック制約**:
- h_error_logs_environment_check: environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_error_logs_202509 -->

<!-- TABLE_BEGIN h_error_logs_202510 -->
## h_error_logs_202510

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| error_class | character varying(120) | × |  |  |
| message | text | × |  |  |
| stacktrace_compressed | bytea | × |  |  |
| stack_head | text | ○ |  |  |
| request_path | character varying(255) | ○ |  |  |
| http_method | character(6) | ○ |  |  |
| status_code | smallint | × | 500 |  |
| params_json | jsonb | ○ |  |  |
| user_id | bigint | ○ |  |  |
| request_id | character(36) | ○ |  |  |
| ip_address | inet | ○ |  |  |
| user_agent | character varying(255) | ○ |  |  |
| server_name | character varying(60) | ○ |  |  |
| environment | character(10) | × |  |  |
| occurred_at | timestamp with time zone | × |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_error_logs_202510_error_class_idx (error_class)
- h_error_logs_202510_id_idx (id)
- h_error_logs_202510_request_id_idx (request_id)
- h_error_logs_202510_request_path_idx (request_path)
- h_error_logs_202510_user_id_idx (user_id)

**外部キー**:
- h_error_logs_user_id_fkey (user_id) → users.id

**チェック制約**:
- h_error_logs_environment_check: environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_error_logs_202510 -->

<!-- TABLE_BEGIN h_error_logs_202511 -->
## h_error_logs_202511

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| error_class | character varying(120) | × |  |  |
| message | text | × |  |  |
| stacktrace_compressed | bytea | × |  |  |
| stack_head | text | ○ |  |  |
| request_path | character varying(255) | ○ |  |  |
| http_method | character(6) | ○ |  |  |
| status_code | smallint | × | 500 |  |
| params_json | jsonb | ○ |  |  |
| user_id | bigint | ○ |  |  |
| request_id | character(36) | ○ |  |  |
| ip_address | inet | ○ |  |  |
| user_agent | character varying(255) | ○ |  |  |
| server_name | character varying(60) | ○ |  |  |
| environment | character(10) | × |  |  |
| occurred_at | timestamp with time zone | × |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_error_logs_202511_error_class_idx (error_class)
- h_error_logs_202511_id_idx (id)
- h_error_logs_202511_request_id_idx (request_id)
- h_error_logs_202511_request_path_idx (request_path)
- h_error_logs_202511_user_id_idx (user_id)

**外部キー**:
- h_error_logs_user_id_fkey (user_id) → users.id

**チェック制約**:
- h_error_logs_environment_check: environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_error_logs_202511 -->

<!-- TABLE_BEGIN h_error_logs_202512 -->
## h_error_logs_202512

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| error_class | character varying(120) | × |  |  |
| message | text | × |  |  |
| stacktrace_compressed | bytea | × |  |  |
| stack_head | text | ○ |  |  |
| request_path | character varying(255) | ○ |  |  |
| http_method | character(6) | ○ |  |  |
| status_code | smallint | × | 500 |  |
| params_json | jsonb | ○ |  |  |
| user_id | bigint | ○ |  |  |
| request_id | character(36) | ○ |  |  |
| ip_address | inet | ○ |  |  |
| user_agent | character varying(255) | ○ |  |  |
| server_name | character varying(60) | ○ |  |  |
| environment | character(10) | × |  |  |
| occurred_at | timestamp with time zone | × |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_error_logs_202512_error_class_idx (error_class)
- h_error_logs_202512_id_idx (id)
- h_error_logs_202512_request_id_idx (request_id)
- h_error_logs_202512_request_path_idx (request_path)
- h_error_logs_202512_user_id_idx (user_id)

**外部キー**:
- h_error_logs_user_id_fkey (user_id) → users.id

**チェック制約**:
- h_error_logs_environment_check: environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_error_logs_202512 -->

<!-- TABLE_BEGIN h_error_logs_202602 -->
## h_error_logs_202602

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| error_class | character varying(120) | × |  |  |
| message | text | × |  |  |
| stacktrace_compressed | bytea | × |  |  |
| stack_head | text | ○ |  |  |
| request_path | character varying(255) | ○ |  |  |
| http_method | character(6) | ○ |  |  |
| status_code | smallint | × | 500 |  |
| params_json | jsonb | ○ |  |  |
| user_id | bigint | ○ |  |  |
| request_id | character(36) | ○ |  |  |
| ip_address | inet | ○ |  |  |
| user_agent | character varying(255) | ○ |  |  |
| server_name | character varying(60) | ○ |  |  |
| environment | character(10) | × |  |  |
| occurred_at | timestamp with time zone | × |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_error_logs_202602_error_class_idx (error_class)
- h_error_logs_202602_id_idx (id)
- h_error_logs_202602_request_id_idx (request_id)
- h_error_logs_202602_request_path_idx (request_path)
- h_error_logs_202602_user_id_idx (user_id)

**外部キー**:
- h_error_logs_user_id_fkey (user_id) → users.id

**チェック制約**:
- h_error_logs_environment_check: environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_error_logs_202602 -->

<!-- TABLE_BEGIN h_error_logs_202603 -->
## h_error_logs_202603

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| error_class | character varying(120) | × |  |  |
| message | text | × |  |  |
| stacktrace_compressed | bytea | × |  |  |
| stack_head | text | ○ |  |  |
| request_path | character varying(255) | ○ |  |  |
| http_method | character(6) | ○ |  |  |
| status_code | smallint | × | 500 |  |
| params_json | jsonb | ○ |  |  |
| user_id | bigint | ○ |  |  |
| request_id | character(36) | ○ |  |  |
| ip_address | inet | ○ |  |  |
| user_agent | character varying(255) | ○ |  |  |
| server_name | character varying(60) | ○ |  |  |
| environment | character(10) | × |  |  |
| occurred_at | timestamp with time zone | × |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_error_logs_202603_error_class_idx (error_class)
- h_error_logs_202603_id_idx (id)
- h_error_logs_202603_request_id_idx (request_id)
- h_error_logs_202603_request_path_idx (request_path)
- h_error_logs_202603_user_id_idx (user_id)

**外部キー**:
- h_error_logs_user_id_fkey (user_id) → users.id

**チェック制約**:
- h_error_logs_environment_check: environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_error_logs_202603 -->

<!-- TABLE_BEGIN h_error_logs_202604 -->
## h_error_logs_202604

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| error_class | character varying(120) | × |  |  |
| message | text | × |  |  |
| stacktrace_compressed | bytea | × |  |  |
| stack_head | text | ○ |  |  |
| request_path | character varying(255) | ○ |  |  |
| http_method | character(6) | ○ |  |  |
| status_code | smallint | × | 500 |  |
| params_json | jsonb | ○ |  |  |
| user_id | bigint | ○ |  |  |
| request_id | character(36) | ○ |  |  |
| ip_address | inet | ○ |  |  |
| user_agent | character varying(255) | ○ |  |  |
| server_name | character varying(60) | ○ |  |  |
| environment | character(10) | × |  |  |
| occurred_at | timestamp with time zone | × |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_error_logs_202604_error_class_idx (error_class)
- h_error_logs_202604_id_idx (id)
- h_error_logs_202604_request_id_idx (request_id)
- h_error_logs_202604_request_path_idx (request_path)
- h_error_logs_202604_user_id_idx (user_id)

**外部キー**:
- h_error_logs_user_id_fkey (user_id) → users.id

**チェック制約**:
- h_error_logs_environment_check: environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_error_logs_202604 -->

<!-- TABLE_BEGIN h_article_views_202505 -->
## h_article_views_202505

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| article_id | bigint | × |  |  |
| user_id | bigint | ○ |  |  |
| ip_address | inet | ○ |  |  |
| viewed_at | timestamp with time zone | × |  |  |
| ua_hash | character(32) | ○ |  |  |
| processed_flag | boolean | × | false |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_article_views_202505_article_id_idx (article_id)
- h_article_views_202505_article_id_idx1 (article_id) WHERE (processed_flag = false)
- h_article_views_202505_id_idx (id)
- h_article_views_202505_unproc_idx (article_id) WHERE (processed_flag = false)
- h_article_views_202505_user_id_idx (user_id)

**外部キー**:
- h_article_views_article_id_fkey (article_id) → articles.id
- h_article_views_user_id_fkey (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_article_views_202505 -->

<!-- TABLE_BEGIN h_article_views_202506 -->
## h_article_views_202506

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| article_id | bigint | × |  |  |
| user_id | bigint | ○ |  |  |
| ip_address | inet | ○ |  |  |
| viewed_at | timestamp with time zone | × |  |  |
| ua_hash | character(32) | ○ |  |  |
| processed_flag | boolean | × | false |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_article_views_202506_article_id_idx (article_id)
- h_article_views_202506_article_id_idx1 (article_id) WHERE (processed_flag = false)
- h_article_views_202506_id_idx (id)
- h_article_views_202506_unproc_idx (article_id) WHERE (processed_flag = false)
- h_article_views_202506_user_id_idx (user_id)

**外部キー**:
- h_article_views_article_id_fkey (article_id) → articles.id
- h_article_views_user_id_fkey (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_article_views_202506 -->

<!-- TABLE_BEGIN h_article_views_202507 -->
## h_article_views_202507

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| article_id | bigint | × |  |  |
| user_id | bigint | ○ |  |  |
| ip_address | inet | ○ |  |  |
| viewed_at | timestamp with time zone | × |  |  |
| ua_hash | character(32) | ○ |  |  |
| processed_flag | boolean | × | false |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_article_views_202507_article_id_idx (article_id)
- h_article_views_202507_article_id_idx1 (article_id) WHERE (processed_flag = false)
- h_article_views_202507_id_idx (id)
- h_article_views_202507_unproc_idx (article_id) WHERE (processed_flag = false)
- h_article_views_202507_user_id_idx (user_id)

**外部キー**:
- h_article_views_article_id_fkey (article_id) → articles.id
- h_article_views_user_id_fkey (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_article_views_202507 -->

<!-- TABLE_BEGIN h_article_views_202508 -->
## h_article_views_202508

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| article_id | bigint | × |  |  |
| user_id | bigint | ○ |  |  |
| ip_address | inet | ○ |  |  |
| viewed_at | timestamp with time zone | × |  |  |
| ua_hash | character(32) | ○ |  |  |
| processed_flag | boolean | × | false |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_article_views_202508_article_id_idx (article_id)
- h_article_views_202508_article_id_idx1 (article_id) WHERE (processed_flag = false)
- h_article_views_202508_id_idx (id)
- h_article_views_202508_unproc_idx (article_id) WHERE (processed_flag = false)
- h_article_views_202508_user_id_idx (user_id)

**外部キー**:
- h_article_views_article_id_fkey (article_id) → articles.id
- h_article_views_user_id_fkey (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_article_views_202508 -->

<!-- TABLE_BEGIN h_article_views_202509 -->
## h_article_views_202509

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| article_id | bigint | × |  |  |
| user_id | bigint | ○ |  |  |
| ip_address | inet | ○ |  |  |
| viewed_at | timestamp with time zone | × |  |  |
| ua_hash | character(32) | ○ |  |  |
| processed_flag | boolean | × | false |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_article_views_202509_article_id_idx (article_id)
- h_article_views_202509_article_id_idx1 (article_id) WHERE (processed_flag = false)
- h_article_views_202509_id_idx (id)
- h_article_views_202509_unproc_idx (article_id) WHERE (processed_flag = false)
- h_article_views_202509_user_id_idx (user_id)

**外部キー**:
- h_article_views_article_id_fkey (article_id) → articles.id
- h_article_views_user_id_fkey (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_article_views_202509 -->

<!-- TABLE_BEGIN h_article_views_202511 -->
## h_article_views_202511

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| article_id | bigint | × |  |  |
| user_id | bigint | ○ |  |  |
| ip_address | inet | ○ |  |  |
| viewed_at | timestamp with time zone | × |  |  |
| ua_hash | character(32) | ○ |  |  |
| processed_flag | boolean | × | false |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_article_views_202511_article_id_idx (article_id)
- h_article_views_202511_article_id_idx1 (article_id) WHERE (processed_flag = false)
- h_article_views_202511_id_idx (id)
- h_article_views_202511_unproc_idx (article_id) WHERE (processed_flag = false)
- h_article_views_202511_user_id_idx (user_id)

**外部キー**:
- h_article_views_article_id_fkey (article_id) → articles.id
- h_article_views_user_id_fkey (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_article_views_202511 -->

<!-- TABLE_BEGIN h_article_views_202603 -->
## h_article_views_202603

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| article_id | bigint | × |  |  |
| user_id | bigint | ○ |  |  |
| ip_address | inet | ○ |  |  |
| viewed_at | timestamp with time zone | × |  |  |
| ua_hash | character(32) | ○ |  |  |
| processed_flag | boolean | × | false |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_article_views_202603_article_id_idx (article_id)
- h_article_views_202603_article_id_idx1 (article_id) WHERE (processed_flag = false)
- h_article_views_202603_id_idx (id)
- h_article_views_202603_unproc_idx (article_id) WHERE (processed_flag = false)
- h_article_views_202603_user_id_idx (user_id)

**外部キー**:
- h_article_views_article_id_fkey (article_id) → articles.id
- h_article_views_user_id_fkey (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_article_views_202603 -->

<!-- TABLE_BEGIN h_article_views_202604 -->
## h_article_views_202604

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| article_id | bigint | × |  |  |
| user_id | bigint | ○ |  |  |
| ip_address | inet | ○ |  |  |
| viewed_at | timestamp with time zone | × |  |  |
| ua_hash | character(32) | ○ |  |  |
| processed_flag | boolean | × | false |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_article_views_202604_article_id_idx (article_id)
- h_article_views_202604_article_id_idx1 (article_id) WHERE (processed_flag = false)
- h_article_views_202604_id_idx (id)
- h_article_views_202604_unproc_idx (article_id) WHERE (processed_flag = false)
- h_article_views_202604_user_id_idx (user_id)

**外部キー**:
- h_article_views_article_id_fkey (article_id) → articles.id
- h_article_views_user_id_fkey (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_article_views_202604 -->

<!-- TABLE_BEGIN h_payment_webhooks_202509 -->
## h_payment_webhooks_202509

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| gateway | character varying(30) | × |  |  |
| event_id | character varying(255) | × |  |  |
| event_type | character varying(50) | × |  |  |
| http_status | smallint | × |  |  |
| signature | character varying(255) | ○ |  |  |
| payload_json | jsonb | × |  |  |
| order_id | bigint | ○ |  |  |
| payout_id | bigint | ○ |  |  |
| processed_at | timestamp with time zone | ○ |  |  |
| processing_result | smallint | ○ |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_payment_webhooks_202509_gateway_event_id_idx (gateway, event_id)
- h_payment_webhooks_202509_uq (gateway, event_id) [UNIQUE]

**外部キー**:
- h_payment_webhooks_order_id_fkey (order_id) → orders.id
- h_payment_webhooks_payout_id_fkey (payout_id) → payouts.id

**チェック制約**:
- h_payment_webhooks_processing_result_check: processing_result IS NULL OR (processing_result = ANY (ARRAY[0, 1, 2]))
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_payment_webhooks_202509 -->

<!-- TABLE_BEGIN h_payment_webhooks_202511 -->
## h_payment_webhooks_202511

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| gateway | character varying(30) | × |  |  |
| event_id | character varying(255) | × |  |  |
| event_type | character varying(50) | × |  |  |
| http_status | smallint | × |  |  |
| signature | character varying(255) | ○ |  |  |
| payload_json | jsonb | × |  |  |
| order_id | bigint | ○ |  |  |
| payout_id | bigint | ○ |  |  |
| processed_at | timestamp with time zone | ○ |  |  |
| processing_result | smallint | ○ |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_payment_webhooks_202511_gateway_event_id_idx (gateway, event_id)
- h_payment_webhooks_202511_uq (gateway, event_id) [UNIQUE]

**外部キー**:
- h_payment_webhooks_order_id_fkey (order_id) → orders.id
- h_payment_webhooks_payout_id_fkey (payout_id) → payouts.id

**チェック制約**:
- h_payment_webhooks_processing_result_check: processing_result IS NULL OR (processing_result = ANY (ARRAY[0, 1, 2]))
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_payment_webhooks_202511 -->

<!-- TABLE_BEGIN h_payment_webhooks_202512 -->
## h_payment_webhooks_202512

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| gateway | character varying(30) | × |  |  |
| event_id | character varying(255) | × |  |  |
| event_type | character varying(50) | × |  |  |
| http_status | smallint | × |  |  |
| signature | character varying(255) | ○ |  |  |
| payload_json | jsonb | × |  |  |
| order_id | bigint | ○ |  |  |
| payout_id | bigint | ○ |  |  |
| processed_at | timestamp with time zone | ○ |  |  |
| processing_result | smallint | ○ |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_payment_webhooks_202512_gateway_event_id_idx (gateway, event_id)
- h_payment_webhooks_202512_uq (gateway, event_id) [UNIQUE]

**外部キー**:
- h_payment_webhooks_order_id_fkey (order_id) → orders.id
- h_payment_webhooks_payout_id_fkey (payout_id) → payouts.id

**チェック制約**:
- h_payment_webhooks_processing_result_check: processing_result IS NULL OR (processing_result = ANY (ARRAY[0, 1, 2]))
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_payment_webhooks_202512 -->

<!-- TABLE_BEGIN h_payment_webhooks_202601 -->
## h_payment_webhooks_202601

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| gateway | character varying(30) | × |  |  |
| event_id | character varying(255) | × |  |  |
| event_type | character varying(50) | × |  |  |
| http_status | smallint | × |  |  |
| signature | character varying(255) | ○ |  |  |
| payload_json | jsonb | × |  |  |
| order_id | bigint | ○ |  |  |
| payout_id | bigint | ○ |  |  |
| processed_at | timestamp with time zone | ○ |  |  |
| processing_result | smallint | ○ |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_payment_webhooks_202601_gateway_event_id_idx (gateway, event_id)
- h_payment_webhooks_202601_uq (gateway, event_id) [UNIQUE]

**外部キー**:
- h_payment_webhooks_order_id_fkey (order_id) → orders.id
- h_payment_webhooks_payout_id_fkey (payout_id) → payouts.id

**チェック制約**:
- h_payment_webhooks_processing_result_check: processing_result IS NULL OR (processing_result = ANY (ARRAY[0, 1, 2]))
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_payment_webhooks_202601 -->

<!-- TABLE_BEGIN h_payment_webhooks_202602 -->
## h_payment_webhooks_202602

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| gateway | character varying(30) | × |  |  |
| event_id | character varying(255) | × |  |  |
| event_type | character varying(50) | × |  |  |
| http_status | smallint | × |  |  |
| signature | character varying(255) | ○ |  |  |
| payload_json | jsonb | × |  |  |
| order_id | bigint | ○ |  |  |
| payout_id | bigint | ○ |  |  |
| processed_at | timestamp with time zone | ○ |  |  |
| processing_result | smallint | ○ |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_payment_webhooks_202602_gateway_event_id_idx (gateway, event_id)
- h_payment_webhooks_202602_uq (gateway, event_id) [UNIQUE]

**外部キー**:
- h_payment_webhooks_order_id_fkey (order_id) → orders.id
- h_payment_webhooks_payout_id_fkey (payout_id) → payouts.id

**チェック制約**:
- h_payment_webhooks_processing_result_check: processing_result IS NULL OR (processing_result = ANY (ARRAY[0, 1, 2]))
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_payment_webhooks_202602 -->

<!-- TABLE_BEGIN h_payment_webhooks_202603 -->
## h_payment_webhooks_202603

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| gateway | character varying(30) | × |  |  |
| event_id | character varying(255) | × |  |  |
| event_type | character varying(50) | × |  |  |
| http_status | smallint | × |  |  |
| signature | character varying(255) | ○ |  |  |
| payload_json | jsonb | × |  |  |
| order_id | bigint | ○ |  |  |
| payout_id | bigint | ○ |  |  |
| processed_at | timestamp with time zone | ○ |  |  |
| processing_result | smallint | ○ |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_payment_webhooks_202603_gateway_event_id_idx (gateway, event_id)
- h_payment_webhooks_202603_uq (gateway, event_id) [UNIQUE]

**外部キー**:
- h_payment_webhooks_order_id_fkey (order_id) → orders.id
- h_payment_webhooks_payout_id_fkey (payout_id) → payouts.id

**チェック制約**:
- h_payment_webhooks_processing_result_check: processing_result IS NULL OR (processing_result = ANY (ARRAY[0, 1, 2]))
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_payment_webhooks_202603 -->

<!-- TABLE_BEGIN h_payment_webhooks_202604 -->
## h_payment_webhooks_202604

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| gateway | character varying(30) | × |  |  |
| event_id | character varying(255) | × |  |  |
| event_type | character varying(50) | × |  |  |
| http_status | smallint | × |  |  |
| signature | character varying(255) | ○ |  |  |
| payload_json | jsonb | × |  |  |
| order_id | bigint | ○ |  |  |
| payout_id | bigint | ○ |  |  |
| processed_at | timestamp with time zone | ○ |  |  |
| processing_result | smallint | ○ |  |  |
| created_at | timestamp with time zone | × |  |  |

**インデックス**:
- h_payment_webhooks_202604_gateway_event_id_idx (gateway, event_id)
- h_payment_webhooks_202604_uq (gateway, event_id) [UNIQUE]

**外部キー**:
- h_payment_webhooks_order_id_fkey (order_id) → orders.id
- h_payment_webhooks_payout_id_fkey (payout_id) → payouts.id

**チェック制約**:
- h_payment_webhooks_processing_result_check: processing_result IS NULL OR (processing_result = ANY (ARRAY[0, 1, 2]))
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_payment_webhooks_202604 -->

<!-- TABLE_BEGIN transaction_shipping_addresses -->
## transaction_shipping_addresses

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| recipient_name | character varying | × |  |  |
| postal_code | character varying(8) | × |  |  |
| prefecture_code | character varying(2) | × |  |  |
| city_code | character varying(5) | × |  |  |
| address_line | character varying | × |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- transaction_shipping_addresses_pkey (id) [PK]
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END transaction_shipping_addresses -->

<!-- TABLE_BEGIN affiliate_recipe_commissions -->
## affiliate_recipe_commissions

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| original_user_id | bigint | × |  |  |
| fork_user_id | bigint | × |  |  |
| recipe_snapshot_id | bigint | × |  |  |
| order_id | bigint | × |  |  |
| commission_cents | bigint | × |  |  |
| settled_flag | boolean | × | false |  |
| settled_at | timestamp(6) without time zone | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |

**インデックス**:
- affiliate_recipe_commissions_pkey (id) [PK]
- idx_commission_settlement (original_user_id, settled_flag)
- index_affiliate_recipe_commissions_on_created_by_id (created_by_id)
- index_affiliate_recipe_commissions_on_deleted_by_id (deleted_by_id)
- index_affiliate_recipe_commissions_on_fork_user_id (fork_user_id)
- index_affiliate_recipe_commissions_on_order_id (order_id)
- index_affiliate_recipe_commissions_on_original_user_id (original_user_id)
- index_affiliate_recipe_commissions_on_recipe_snapshot_id (recipe_snapshot_id)
- index_affiliate_recipe_commissions_on_updated_by_id (updated_by_id)
- uniq_commission_per_order_and_snapshot (order_id, recipe_snapshot_id) [UNIQUE]

**外部キー**:
- fk_rails_0fade2c78f (fork_user_id) → users.id
- fk_rails_7280f3ef48 (recipe_snapshot_id) → recipe_snapshots.id
- fk_rails_8ac7a4e723 (order_id) → orders.id
- fk_rails_d31b25a08a (original_user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END affiliate_recipe_commissions -->

<!-- SECTION_BEGIN マスタ — 住所系 -->
# マスタ — 住所系
<!-- SECTION_END マスタ — 住所系 -->

<!-- TABLE_BEGIN m_postal_codes -->
## m_postal_codes

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| postal_code | character varying(7) | × |  |  |
| city_code | character varying(5) | × |  |  |
| city_town_name_kanji | text | × |  |  |
| town_area_name_kanji | text | ○ |  |  |
| multi_town_flag | boolean | × | false |  |
| koaza_banchi_flag | boolean | × | false |  |
| chome_flag | boolean | × | false |  |
| multi_aza_flag | boolean | × | false |  |
| deleted_flag | boolean | × | false |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| deleted_at | timestamp with time zone | ○ |  |  |

**インデックス**:
- m_postal_codes_pkey (id) [PK]
- idx_postal_code_area_unique (postal_code, town_area_name_kanji) [UNIQUE]
- index_m_postal_codes_on_city_code (city_code)
- index_m_postal_codes_on_created_by_id (created_by_id)
- index_m_postal_codes_on_deleted_by_id (deleted_by_id)
- index_m_postal_codes_on_postal_code (postal_code)
- index_m_postal_codes_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_4a069ba98b (city_code) → m_cities.code
- fk_rails_8cab43ec13 (deleted_by_id) → users.id
- fk_rails_9584d0ef32 (updated_by_id) → users.id
- fk_rails_d6f8c39731 (created_by_id) → users.id

**チェック制約**:
- postal_code_len_chk: char_length(postal_code::text) = 7
- postal_city_len_chk: char_length(city_code::text) = 5
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_postal_codes -->

<!-- TABLE_BEGIN m_prefectures -->
## m_prefectures

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| code | character varying(2) | × |  |  |
| name_ja | character varying(10) | × |  |  |
| name_en | character varying(20) | × |  |  |
| kana | character varying(20) | × |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- index_m_prefectures_on_code (code) [UNIQUE]
- index_m_prefectures_on_created_by_id (created_by_id)
- index_m_prefectures_on_deleted_by_id (deleted_by_id)
- index_m_prefectures_on_name_ja (name_ja) [UNIQUE]
- index_m_prefectures_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_4364687b87 (updated_by_id) → users.id
- fk_rails_79951cc512 (created_by_id) → users.id
- fk_rails_ce3acd64e5 (deleted_by_id) → users.id

**チェック制約**:
- m_prefectures_code_chk: code::text >= '01'::text AND code::text <= '47'::text
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_prefectures -->

<!-- TABLE_BEGIN m_cities -->
## m_cities

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| code | character varying(5) | × |  |  |
| prefecture_code | character varying(2) | × |  |  |
| name_ja | character varying(100) | × |  |  |
| name_kana | character varying(100) | ○ |  |  |
| name_en | character varying(100) | ○ |  |  |
| sort_no | smallint | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| latitude | numeric(9,6) | ○ |  |  |
| longitude | numeric(9,6) | ○ |  |  |

**インデックス**:
- index_m_cities_on_code (code) [UNIQUE]
- index_m_cities_on_created_by_id (created_by_id)
- index_m_cities_on_deleted_by_id (deleted_by_id)
- index_m_cities_on_prefecture_code (prefecture_code)
- index_m_cities_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_42109644b2 (prefecture_code) → m_prefectures.code
- fk_rails_9bbab727a4 (updated_by_id) → users.id
- fk_rails_b2a090b409 (created_by_id) → users.id
- fk_rails_c47d959888 (deleted_by_id) → users.id

**チェック制約**:
- m_cities_code_len_chk: char_length(code::text) = 5
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_cities -->

<!-- SECTION_BEGIN マスタ — 部品系 -->
# マスタ — 部品系
<!-- SECTION_END マスタ — 部品系 -->

<!-- TABLE_BEGIN m_categories -->
## m_categories

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| code | character varying(10) | × |  |  |
| name_ja | character varying(20) | × |  |  |
| name_en | character varying(20) | × |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- m_categories_pkey (code) [PK]
- index_m_categories_on_code (code) [UNIQUE]
- index_m_categories_on_created_by_id (created_by_id)
- index_m_categories_on_deleted_by_id (deleted_by_id)
- index_m_categories_on_name_en (name_en) [UNIQUE]
- index_m_categories_on_name_ja (name_ja) [UNIQUE]
- index_m_categories_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_451e72c106 (created_by_id) → users.id
- fk_rails_63fc147c9a (deleted_by_id) → users.id
- fk_rails_f95fffab61 (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_categories -->

<!-- TABLE_BEGIN m_materials -->
## m_materials

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| code | character varying(16) | × |  |  |
| category_code | character varying(10) | × |  |  |
| name_ja | character varying(40) | × |  |  |
| name_en | character varying(40) | × |  |  |
| description_ja | character varying(80) | ○ |  |  |
| description_en | character varying(80) | ○ |  |  |
| jis_iso | character varying(12) | ○ |  |  |
| density_kg_per_m3 | numeric(8,2) | × |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- m_materials_pkey (code) [PK]
- index_m_materials_on_category_code (category_code)
- index_m_materials_on_created_by_id (created_by_id)
- index_m_materials_on_deleted_by_id (deleted_by_id)
- index_m_materials_on_name_en (name_en) [UNIQUE]
- index_m_materials_on_name_ja (name_ja) [UNIQUE]
- index_m_materials_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_2486576561 (deleted_by_id) → users.id
- fk_rails_48223032c7 (created_by_id) → users.id
- fk_rails_5e5fc68929 (category_code) → m_categories.code
- fk_rails_9fd91eeecc (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_materials -->

<!-- TABLE_BEGIN m_shapes -->
## m_shapes

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| code | character varying(10) | × |  |  |
| name_ja | character varying(30) | × |  |  |
| name_en | character varying(30) | × |  |  |
| description_ja | character varying(80) | ○ |  |  |
| description_en | character varying(80) | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| allow_shape_json | jsonb | × | {} |  |
| allow_corner_json | jsonb | × | {} |  |
| allow_edge_json | jsonb | × | {} |  |
| dims_rule_json | jsonb | × | {} |  |

**インデックス**:
- m_shapes_pkey (code) [PK]
- index_m_shapes_on_created_by_id (created_by_id)
- index_m_shapes_on_deleted_by_id (deleted_by_id)
- index_m_shapes_on_name_en (name_en) [UNIQUE]
- index_m_shapes_on_name_ja (name_ja) [UNIQUE]
- index_m_shapes_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_37e866bfd4 (updated_by_id) → users.id
- fk_rails_4b6bbd888d (deleted_by_id) → users.id
- fk_rails_4cab80b183 (created_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_shapes -->

<!-- TABLE_BEGIN m_paint_types -->
## m_paint_types

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| code | character varying(10) | × |  |  |
| name_ja | character varying(30) | × |  |  |
| name_en | character varying(30) | × |  |  |
| description_ja | character varying(80) | ○ |  |  |
| description_en | character varying(80) | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| allow_paint_json | jsonb | × | {} |  |

**インデックス**:
- m_paint_types_pkey (code) [PK]
- index_m_paint_types_on_created_by_id (created_by_id)
- index_m_paint_types_on_deleted_by_id (deleted_by_id)
- index_m_paint_types_on_name_en (name_en) [UNIQUE]
- index_m_paint_types_on_name_ja (name_ja) [UNIQUE]
- index_m_paint_types_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_12bace13d4 (deleted_by_id) → users.id
- fk_rails_6d6d56ac9b (created_by_id) → users.id
- fk_rails_e8d8c7b2a3 (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_paint_types -->

<!-- SECTION_BEGIN マスタ — 部品集約JSON系 -->
# マスタ — 部品集約JSON系
<!-- SECTION_END マスタ — 部品集約JSON系 -->

<!-- TABLE_BEGIN m_corner_processes -->
## m_corner_processes

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| code | character varying(10) | × |  |  |
| name_ja | character varying(30) | × |  |  |
| name_en | character varying(30) | × |  |  |
| description_ja | character varying(80) | ○ |  |  |
| description_en | character varying(80) | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| allow_corner_proc_json | jsonb | × | {} |  |

**インデックス**:
- m_corner_processes_pkey (code) [PK]
- index_m_corner_processes_on_created_by_id (created_by_id)
- index_m_corner_processes_on_deleted_by_id (deleted_by_id)
- index_m_corner_processes_on_name_en (name_en) [UNIQUE]
- index_m_corner_processes_on_name_ja (name_ja) [UNIQUE]
- index_m_corner_processes_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_0c41746295 (updated_by_id) → users.id
- fk_rails_cbf0dca52b (deleted_by_id) → users.id
- fk_rails_f029d371ff (created_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_corner_processes -->

<!-- TABLE_BEGIN m_hole_diameters -->
## m_hole_diameters

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| code | character varying(10) | × |  |  |
| hole_mm | numeric(8,2) | × |  |  |
| name_ja | character varying(20) | × |  |  |
| name_en | character varying(6) | × |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- m_hole_diameters_pkey (code) [PK]
- index_m_hole_diameters_on_created_by_id (created_by_id)
- index_m_hole_diameters_on_deleted_by_id (deleted_by_id)
- index_m_hole_diameters_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_42c61c1cc6 (updated_by_id) → users.id
- fk_rails_68c00434d4 (created_by_id) → users.id
- fk_rails_98dcfdc04c (deleted_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_hole_diameters -->

<!-- TABLE_BEGIN m_edge_processes -->
## m_edge_processes

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| code | character varying(10) | × |  |  |
| name_ja | character varying(20) | × |  |  |
| name_en | character varying(10) | × |  |  |
| description_ja | character varying(80) | ○ |  |  |
| description_en | character varying(80) | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- m_edge_processes_pkey (code) [PK]
- index_m_edge_processes_on_created_by_id (created_by_id)
- index_m_edge_processes_on_deleted_by_id (deleted_by_id)
- index_m_edge_processes_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_0e64fecc00 (deleted_by_id) → users.id
- fk_rails_608bdc2fe1 (created_by_id) → users.id
- fk_rails_632e7fe66e (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_edge_processes -->

<!-- TABLE_BEGIN m_paint_surfaces -->
## m_paint_surfaces

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| code | character varying(6) | × |  |  |
| name_ja | character varying(30) | × |  |  |
| name_en | character varying(30) | × |  |  |
| description_ja | character varying(80) | ○ |  |  |
| description_en | character varying(80) | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- m_paint_surfaces_pkey (code) [PK]
- index_m_paint_surfaces_on_created_by_id (created_by_id)
- index_m_paint_surfaces_on_deleted_by_id (deleted_by_id)
- index_m_paint_surfaces_on_name_en (name_en) [UNIQUE]
- index_m_paint_surfaces_on_name_ja (name_ja) [UNIQUE]
- index_m_paint_surfaces_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_04940c0fa3 (deleted_by_id) → users.id
- fk_rails_2c0d76fe0e (updated_by_id) → users.id
- fk_rails_6273a3930b (created_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_paint_surfaces -->

<!-- TABLE_BEGIN m_paint_colors -->
## m_paint_colors

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| code | character varying(6) | × |  |  |
| name_ja | character varying(30) | × |  |  |
| name_en | character varying(30) | × |  |  |
| description_ja | character varying(80) | ○ |  |  |
| description_en | character varying(80) | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- m_paint_colors_pkey (code) [PK]
- index_m_paint_colors_on_created_by_id (created_by_id)
- index_m_paint_colors_on_deleted_by_id (deleted_by_id)
- index_m_paint_colors_on_name_en (name_en) [UNIQUE]
- index_m_paint_colors_on_name_ja (name_ja) [UNIQUE]
- index_m_paint_colors_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_0e6e729dcb (created_by_id) → users.id
- fk_rails_98b42979dc (deleted_by_id) → users.id
- fk_rails_9f7ace30eb (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_paint_colors -->

<!-- TABLE_BEGIN m_grain_finishes -->
## m_grain_finishes

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| code | character varying(6) | × |  |  |
| name_ja | character varying(30) | × |  |  |
| name_en | character varying(30) | × |  |  |
| description_ja | character varying(80) | ○ |  |  |
| description_en | character varying(80) | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- m_grain_finishes_pkey (code) [PK]
- index_m_grain_finishes_on_created_by_id (created_by_id)
- index_m_grain_finishes_on_deleted_by_id (deleted_by_id)
- index_m_grain_finishes_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_70079f0d12 (updated_by_id) → users.id
- fk_rails_8bfc7696b8 (created_by_id) → users.id
- fk_rails_bf35672699 (deleted_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_grain_finishes -->

<!-- TABLE_BEGIN m_glosses -->
## m_glosses

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| code | character varying(6) | × |  |  |
| name_ja | character varying(30) | × |  |  |
| name_en | character varying(30) | × |  |  |
| gloss_pct | smallint | × |  |  |
| description_ja | character varying(80) | ○ |  |  |
| description_en | character varying(80) | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- m_glosses_pkey (code) [PK]
- index_m_glosses_on_created_by_id (created_by_id)
- index_m_glosses_on_deleted_by_id (deleted_by_id)
- index_m_glosses_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_051c4b4700 (created_by_id) → users.id
- fk_rails_3dcf832460 (updated_by_id) → users.id
- fk_rails_b2e63cb87f (deleted_by_id) → users.id

**チェック制約**:
- chk_gloss_pct: gloss_pct >= 0 AND gloss_pct <= 100
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_glosses -->

<!-- TABLE_BEGIN m_process_types -->
## m_process_types

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| code | character varying(10) | × |  |  |
| category_code | character varying(10) | × |  |  |
| name_ja | character varying(40) | × |  |  |
| name_en | character varying(40) | × |  |  |
| description_ja | character varying(80) | ○ |  |  |
| description_en | character varying(80) | ○ |  |  |
| jis_iso | character varying(12) | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- m_process_types_pkey (code) [PK]
- index_m_process_types_on_category_code (category_code)
- index_m_process_types_on_created_by_id (created_by_id)
- index_m_process_types_on_deleted_by_id (deleted_by_id)
- index_m_process_types_on_name_en (name_en) [UNIQUE]
- index_m_process_types_on_name_ja (name_ja) [UNIQUE]
- index_m_process_types_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_50d97028ce (created_by_id) → users.id
- fk_rails_9a94eea366 (category_code) → m_categories.code
- fk_rails_9ae1a206fd (updated_by_id) → users.id
- fk_rails_9c515c2693 (deleted_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_process_types -->

<!-- TABLE_BEGIN m_authorities -->
## m_authorities

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| code | character varying(30) | × |  |  |
| name_ja | character varying(60) | × |  |  |
| default_roles | jsonb | ○ |  |  |
| active_flag | boolean | × | true |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- index_m_authorities_on_active_flag (active_flag)
- index_m_authorities_on_code (code) [UNIQUE]
- index_m_authorities_on_created_by_id (created_by_id)
- index_m_authorities_on_deleted_by_id (deleted_by_id)
- index_m_authorities_on_updated_by_id (updated_by_id)

**外部キー**:
- fk_rails_44f5207aff (deleted_by_id) → users.id
- fk_rails_5230eda4ef (created_by_id) → users.id
- fk_rails_e964d916b9 (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_authorities -->

<!-- TABLE_BEGIN active_storage_blobs -->
## active_storage_blobs

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| key | character varying | × |  |  |
| filename | character varying | × |  |  |
| content_type | character varying | ○ |  |  |
| metadata | text | ○ |  |  |
| service_name | character varying | × |  |  |
| byte_size | bigint | × |  |  |
| checksum | character varying | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- active_storage_blobs_pkey (id) [PK]
- index_active_storage_blobs_on_key (key) [UNIQUE]
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END active_storage_blobs -->

<!-- TABLE_BEGIN active_storage_attachments -->
## active_storage_attachments

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| name | character varying | × |  |  |
| record_type | character varying | × |  |  |
| record_id | bigint | × |  |  |
| blob_id | bigint | × |  |  |
| created_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- active_storage_attachments_pkey (id) [PK]
- index_active_storage_attachments_on_blob_id (blob_id)
- index_active_storage_attachments_uniqueness (record_type, record_id, name, blob_id) [UNIQUE]

**外部キー**:
- fk_rails_c3b3935057 (blob_id) → active_storage_blobs.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END active_storage_attachments -->

<!-- TABLE_BEGIN active_storage_variant_records -->
## active_storage_variant_records

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| blob_id | bigint | × |  |  |
| variation_digest | character varying | × |  |  |

**インデックス**:
- active_storage_variant_records_pkey (id) [PK]
- index_active_storage_variant_records_uniqueness (blob_id, variation_digest) [UNIQUE]

**外部キー**:
- fk_rails_993965df05 (blob_id) → active_storage_blobs.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END active_storage_variant_records -->

