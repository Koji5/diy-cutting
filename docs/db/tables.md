# DB テーブル一覧

生成日: 2025-05-23 13:59 JST

<!-- TABLE_BEGIN admin_details -->
## admin_details ー 管理者詳細テーブル

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| user_id | bigint | × |  |  |
| nickname | character varying(50) | ○ |  | あああ |
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
- index_admin_details_on_created_by_id
- index_admin_details_on_deleted_by_id
- index_admin_details_on_nickname
- index_admin_details_on_updated_by_id

**外部キー**:
- (created_by_id) → users.id
- (deleted_by_id) → users.id
- (user_id) → users.id
- (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->ああああああ
<!-- NOTE END -->

<!-- TABLE_END admin_details -->

<!-- SECTION_BEGIN 新グループ -->
# 新グループ
<!-- SECTION_END 新グループ -->

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
- index_affiliate_signups_on_affiliate_click_id
- index_affiliate_signups_on_affiliate_user_id
- index_affiliate_signups_on_signup_user_id

**外部キー**:
- (deleted_by_id) → users.id
- (signup_user_id) → users.id
- (created_by_id) → users.id
- (affiliate_click_id) → h_affiliate_clicks.id
- (updated_by_id) → users.id
- (affiliate_user_id) → users.id
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
- index_article_media_on_article_id
- index_article_media_on_created_by_id
- index_article_media_on_deleted_by_id
- index_article_media_on_updated_by_id

**外部キー**:
- (article_id) → articles.id
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
- index_h_affiliate_clicks_on_affiliate_user_id
- uq_h_aff_click_token

**外部キー**:
- (affiliate_user_id) → users.id
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
- idx_article_comments_author_polymorphic
- index_article_comments_on_article_id
- index_article_comments_on_author_id
- index_article_comments_on_created_by_id
- index_article_comments_on_deleted_by_id
- index_article_comments_on_parent_id
- index_article_comments_on_updated_by_id

**外部キー**:
- (deleted_by_id) → users.id
- (article_id) → articles.id
- (created_by_id) → users.id
- (parent_id) → article_comments.id
- (updated_by_id) → users.id
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
- idx_article_views_unprocessed
- index_h_article_views_on_article_id
- index_h_article_views_on_id
- index_h_article_views_on_user_id

**外部キー**:
- (article_id) → articles.id
- (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_article_views -->

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
- index_affiliate_details_on_created_by_id
- index_affiliate_details_on_deleted_by_id
- index_affiliate_details_on_invoice_number
- index_affiliate_details_on_updated_by_id

**外部キー**:
- (city_code) → m_cities.code
- (prefecture_code) → m_prefectures.code
- (created_by_id) → users.id
- (city_code) → m_cities.code
- (deleted_by_id) → users.id
- (user_id) → users.id
- (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END affiliate_details -->

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
- index_affiliate_commissions_on_affiliate_user_id
- index_affiliate_commissions_on_created_by_id
- index_affiliate_commissions_on_deleted_by_id
- index_affiliate_commissions_on_order_id
- index_affiliate_commissions_on_referred_user_id
- index_affiliate_commissions_on_updated_by_id
- uq_aff_comm_order

**外部キー**:
- (updated_by_id) → users.id
- (created_by_id) → users.id
- (referred_user_id) → users.id
- (affiliate_user_id) → users.id
- (deleted_by_id) → users.id
- (order_id) → orders.id
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
- index_article_likes_on_article_id
- index_article_likes_on_user_id
- uq_article_likes_article_user

**外部キー**:
- (user_id) → users.id
- (article_id) → articles.id
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
- index_articles_on_author_type_and_author_id
- index_articles_on_content_blocks
- index_articles_on_likes_count
- index_articles_on_order_id
- index_articles_on_replies_count
- index_articles_on_views_count

**外部キー**:
- (created_by_id) → users.id
- (order_id) → orders.id
- (updated_by_id) → users.id
- (deleted_by_id) → users.id
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
- index_h_audit_trails_on_changed_by
- index_h_audit_trails_on_id
- index_h_audit_trails_on_table_name

**外部キー**:
- (changed_by) → users.id
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
- index_h_error_logs_on_error_class
- index_h_error_logs_on_id
- index_h_error_logs_on_request_id
- index_h_error_logs_on_request_path
- index_h_error_logs_on_user_id

**外部キー**:
- (user_id) → users.id
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
- index_h_login_attempts_on_id
- index_h_login_attempts_on_ip_address
- index_h_login_attempts_on_user_id

**外部キー**:
- (user_id) → users.id
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
- h_error_logs_202601_error_class_idx
- h_error_logs_202601_id_idx
- h_error_logs_202601_request_id_idx
- h_error_logs_202601_request_path_idx
- h_error_logs_202601_user_id_idx

**外部キー**:
- (user_id) → users.id
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
- idx_hpwebhook_gateway_event

**外部キー**:
- (order_id) → orders.id
- (payout_id) → payouts.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_payment_webhooks -->

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
| allow_corner_proc_json | text | × | {} |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- index_m_corner_processes_on_created_by_id
- index_m_corner_processes_on_deleted_by_id
- index_m_corner_processes_on_name_en
- index_m_corner_processes_on_name_ja
- index_m_corner_processes_on_updated_by_id

**外部キー**:
- (updated_by_id) → users.id
- (deleted_by_id) → users.id
- (created_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_corner_processes -->

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
- index_m_paint_surfaces_on_created_by_id
- index_m_paint_surfaces_on_deleted_by_id
- index_m_paint_surfaces_on_name_en
- index_m_paint_surfaces_on_name_ja
- index_m_paint_surfaces_on_updated_by_id

**外部キー**:
- (deleted_by_id) → users.id
- (updated_by_id) → users.id
- (created_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_paint_surfaces -->

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
- index_m_glosses_on_created_by_id
- index_m_glosses_on_deleted_by_id
- index_m_glosses_on_updated_by_id

**外部キー**:
- (created_by_id) → users.id
- (updated_by_id) → users.id
- (deleted_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_glosses -->

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
- index_m_cities_on_code
- index_m_cities_on_created_by_id
- index_m_cities_on_deleted_by_id
- index_m_cities_on_prefecture_code
- index_m_cities_on_updated_by_id

**外部キー**:
- (prefecture_code) → m_prefectures.code
- (updated_by_id) → users.id
- (created_by_id) → users.id
- (deleted_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_cities -->

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
- index_m_categories_on_code
- index_m_categories_on_created_by_id
- index_m_categories_on_deleted_by_id
- index_m_categories_on_name_en
- index_m_categories_on_name_ja
- index_m_categories_on_updated_by_id

**外部キー**:
- (created_by_id) → users.id
- (deleted_by_id) → users.id
- (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_categories -->

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
- index_m_edge_processes_on_created_by_id
- index_m_edge_processes_on_deleted_by_id
- index_m_edge_processes_on_updated_by_id

**外部キー**:
- (deleted_by_id) → users.id
- (created_by_id) → users.id
- (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_edge_processes -->

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
- index_m_paint_colors_on_created_by_id
- index_m_paint_colors_on_deleted_by_id
- index_m_paint_colors_on_name_en
- index_m_paint_colors_on_name_ja
- index_m_paint_colors_on_updated_by_id

**外部キー**:
- (created_by_id) → users.id
- (deleted_by_id) → users.id
- (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_paint_colors -->

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
- index_m_materials_on_category_code
- index_m_materials_on_created_by_id
- index_m_materials_on_deleted_by_id
- index_m_materials_on_name_en
- index_m_materials_on_name_ja
- index_m_materials_on_updated_by_id

**外部キー**:
- (deleted_by_id) → users.id
- (created_by_id) → users.id
- (category_code) → m_categories.code
- (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_materials -->

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
- index_m_process_types_on_category_code
- index_m_process_types_on_created_by_id
- index_m_process_types_on_deleted_by_id
- index_m_process_types_on_name_en
- index_m_process_types_on_name_ja
- index_m_process_types_on_updated_by_id

**外部キー**:
- (created_by_id) → users.id
- (category_code) → m_categories.code
- (updated_by_id) → users.id
- (deleted_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_process_types -->

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
| allow_paint_json | text | × | {} |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- index_m_paint_types_on_created_by_id
- index_m_paint_types_on_deleted_by_id
- index_m_paint_types_on_name_en
- index_m_paint_types_on_name_ja
- index_m_paint_types_on_updated_by_id

**外部キー**:
- (deleted_by_id) → users.id
- (created_by_id) → users.id
- (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_paint_types -->

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
- index_m_prefectures_on_code
- index_m_prefectures_on_created_by_id
- index_m_prefectures_on_deleted_by_id
- index_m_prefectures_on_name_ja
- index_m_prefectures_on_updated_by_id

**外部キー**:
- (updated_by_id) → users.id
- (created_by_id) → users.id
- (deleted_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_prefectures -->

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
- index_m_hole_diameters_on_created_by_id
- index_m_hole_diameters_on_deleted_by_id
- index_m_hole_diameters_on_updated_by_id

**外部キー**:
- (updated_by_id) → users.id
- (created_by_id) → users.id
- (deleted_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_hole_diameters -->

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
- index_m_authorities_on_active_flag
- index_m_authorities_on_code
- index_m_authorities_on_created_by_id
- index_m_authorities_on_deleted_by_id
- index_m_authorities_on_updated_by_id

**外部キー**:
- (deleted_by_id) → users.id
- (created_by_id) → users.id
- (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_authorities -->

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
- idx_postal_code_area_unique
- index_m_postal_codes_on_city_code
- index_m_postal_codes_on_created_by_id
- index_m_postal_codes_on_deleted_by_id
- index_m_postal_codes_on_postal_code
- index_m_postal_codes_on_updated_by_id

**外部キー**:
- (city_code) → m_cities.code
- (deleted_by_id) → users.id
- (updated_by_id) → users.id
- (created_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_postal_codes -->

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
- index_m_grain_finishes_on_created_by_id
- index_m_grain_finishes_on_deleted_by_id
- index_m_grain_finishes_on_updated_by_id

**外部キー**:
- (updated_by_id) → users.id
- (created_by_id) → users.id
- (deleted_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_grain_finishes -->

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
- idx_hpe_logger
- index_h_payout_events_on_event
- index_h_payout_events_on_occurred_at
- index_h_payout_events_on_payout_id

**外部キー**:
- (payout_id) → payouts.id
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
- idx_notifications_recipient_status
- idx_notifications_related
- index_notifications_on_broadcast_id
- index_notifications_on_notification_type

**外部キー**:
- (deleted_by_id) → users.id
- (updated_by_id) → users.id
- (created_by_id) → users.id
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
- index_orders_on_affiliate_id
- index_orders_on_created_by_id
- index_orders_on_deleted_by_id
- index_orders_on_shipping_address_id
- index_orders_on_updated_by_id
- index_orders_on_user_id
- index_orders_on_vendor_id
- index_orders_on_vendor_offer_id

**外部キー**:
- (shipping_address_id) → transaction_shipping_addresses.id
- (vendor_offer_id) → vendor_offers.id
- (updated_by_id) → users.id
- (affiliate_id) → users.id
- (created_by_id) → users.id
- (deleted_by_id) → users.id
- (vendor_id) → users.id
- (user_id) → users.id
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
- index_order_reviews_on_created_by_id
- index_order_reviews_on_deleted_by_id
- index_order_reviews_on_order_id
- index_order_reviews_on_reviewer_id
- index_order_reviews_on_updated_by_id
- index_order_reviews_on_vendor_id

**外部キー**:
- (vendor_id) → users.id
- (order_id) → orders.id
- (deleted_by_id) → users.id
- (updated_by_id) → users.id
- (reviewer_id) → users.id
- (created_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END order_reviews -->

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
| allow_shape_json | text | × | {} |  |
| allow_corner_json | text | × | {} |  |
| allow_edge_json | text | × | {} |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- index_m_shapes_on_created_by_id
- index_m_shapes_on_deleted_by_id
- index_m_shapes_on_name_en
- index_m_shapes_on_name_ja
- index_m_shapes_on_updated_by_id

**外部キー**:
- (updated_by_id) → users.id
- (deleted_by_id) → users.id
- (created_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END m_shapes -->

<!-- TABLE_BEGIN schema_migrations -->
## schema_migrations

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| version | character varying | × |  |  |
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END schema_migrations -->

<!-- TABLE_BEGIN member_details -->
## member_details

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| user_id | bigint | × |  |  |
| nickname | character varying(50) | ○ |  |  |
| icon_url | character varying | ○ |  |  |
| legal_type | smallint | × |  |  |
| legal_name | character varying | × |  |  |
| legal_name_kana | character varying | ○ |  |  |
| birthday | date | ○ |  |  |
| gender | character varying(1) | ○ |  |  |
| billing_postal_code | character varying(20) | ○ |  |  |
| billing_prefecture_code | character varying(2) | ○ |  |  |
| billing_city_code | character varying(5) | × |  |  |
| billing_address_line | character varying(200) | × |  |  |
| billing_department | character varying(100) | ○ |  |  |
| billing_phone_number | character varying(30) | ○ |  |  |
| primary_shipping_id | bigint | ○ |  |  |
| stripe_customer_id | character varying | ○ |  |  |
| registered_affiliate_id | bigint | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| membership_plan | integer | × | 0 |  |

**インデックス**:
- index_member_details_on_created_by_id
- index_member_details_on_deleted_by_id
- index_member_details_on_registered_affiliate_id
- index_member_details_on_stripe_customer_id
- index_member_details_on_updated_by_id

**外部キー**:
- (billing_city_code) → m_cities.code
- (primary_shipping_id) → member_shipping_addresses.id
- (user_id) → users.id
- (registered_affiliate_id) → users.id
- (updated_by_id) → users.id
- (deleted_by_id) → users.id
- (billing_city_code) → m_cities.code
- (billing_prefecture_code) → m_prefectures.code
- (created_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END member_details -->

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
- index_payouts_on_created_by_id
- index_payouts_on_deleted_by_id
- index_payouts_on_payee_type_and_payee_id
- index_payouts_on_transaction_ref
- index_payouts_on_updated_by_id
- uq_payouts_period

**外部キー**:
- (transaction_ref) → stripe_payouts.payout_id
- (deleted_by_id) → users.id
- (updated_by_id) → users.id
- (created_by_id) → users.id
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
- index_stripe_accounts_on_created_by_id
- index_stripe_accounts_on_deleted_by_id
- index_stripe_accounts_on_stripe_account_id
- index_stripe_accounts_on_updated_by_id

**外部キー**:
- (deleted_by_id) → users.id
- (updated_by_id) → users.id
- (user_id) → users.id
- (created_by_id) → users.id
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
- index_stripe_events_on_account_id
- index_stripe_events_on_processed_at
- index_stripe_events_on_status
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
- index_stripe_payments_on_created_by_id
- index_stripe_payments_on_deleted_by_id
- index_stripe_payments_on_order_id
- index_stripe_payments_on_payment_intent_id
- index_stripe_payments_on_updated_by_id

**外部キー**:
- (created_by_id) → users.id
- (updated_by_id) → users.id
- (deleted_by_id) → users.id
- (order_id) → orders.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END stripe_payments -->

<!-- TABLE_BEGIN user_authorities -->
## user_authorities

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| user_id | bigint | × |  |  |
| authority_code | character varying(30) | × |  |  |
| grant_state | smallint | × | 1 |  |
| valid_from | timestamp(6) without time zone | ○ |  |  |
| valid_to | timestamp(6) without time zone | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- index_user_authorities_on_user_id
- index_user_authorities_on_user_id_and_authority_code

**外部キー**:
- (authority_code) → m_authorities.code
- (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END user_authorities -->

<!-- TABLE_BEGIN vendor_capabilities -->
## vendor_capabilities

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| vendor_id | bigint | × |  |  |
| capability_code | character varying(16) | × |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- index_vendor_capabilities_on_capability_code
- index_vendor_capabilities_on_vendor_id

**外部キー**:
- (vendor_id) → vendor_details.user_id
- (capability_code) → m_process_types.code
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END vendor_capabilities -->

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
- index_stripe_payouts_on_created_by_id
- index_stripe_payouts_on_deleted_by_id
- index_stripe_payouts_on_stripe_account_id
- index_stripe_payouts_on_updated_by_id

**外部キー**:
- (created_by_id) → users.id
- (stripe_account_id) → stripe_accounts.stripe_account_id
- (deleted_by_id) → users.id
- (updated_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END stripe_payouts -->

<!-- TABLE_BEGIN vendor_service_areas -->
## vendor_service_areas

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| vendor_id | bigint | × |  |  |
| city_code | character varying(5) | × |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- idx_vsa_unique
- index_vendor_service_areas_on_city_code
- index_vendor_service_areas_on_vendor_id

**外部キー**:
- (vendor_id) → vendor_details.user_id
- (city_code) → m_cities.code
- (city_code) → m_cities.code
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
- index_vendor_materials_on_material_code
- index_vendor_materials_on_vendor_id

**外部キー**:
- (material_code) → m_materials.code
- (vendor_id) → vendor_details.user_id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END vendor_materials -->

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
- index_stripe_refunds_on_created_by_id
- index_stripe_refunds_on_deleted_by_id
- index_stripe_refunds_on_payment_intent_id
- index_stripe_refunds_on_updated_by_id

**外部キー**:
- (created_by_id) → users.id
- (deleted_by_id) → users.id
- (updated_by_id) → users.id
- (payment_intent_id) → stripe_payments.payment_intent_id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END stripe_refunds -->

<!-- TABLE_BEGIN vendor_details -->
## vendor_details

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| user_id | bigint | × |  |  |
| nickname | character varying(50) | ○ |  |  |
| profile_icon_url | character varying(500) | ○ |  |  |
| vendor_name | character varying(100) | × |  |  |
| vendor_name_kana | character varying(100) | ○ |  |  |
| invoice_number | character varying(20) | ○ |  |  |
| contact_person_name | character varying(80) | × |  |  |
| contact_person_kana | character varying(80) | ○ |  |  |
| contact_phone_number | character varying(20) | ○ |  |  |
| office_postal_code | character varying(8) | ○ |  |  |
| office_prefecture_code | character varying(2) | × |  |  |
| office_city_code | character varying(5) | × |  |  |
| office_address_line | character varying(200) | × |  |  |
| office_phone_number | character varying(20) | ○ |  |  |
| bank_name | character varying(60) | ○ |  |  |
| account_type | smallint | ○ |  |  |
| account_number | character varying(20) | ○ |  |  |
| account_name | character varying(100) | ○ |  |  |
| shipping_base_address_json | jsonb | ○ |  |  |
| notes | text | ○ |  |  |
| charges_enabled | boolean | × | false |  |
| payouts_enabled | boolean | × | false |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| coverage_scope | integer | × | 0 |  |

**インデックス**:
- index_vendor_details_on_coverage_scope
- index_vendor_details_on_created_by_id
- index_vendor_details_on_deleted_by_id
- index_vendor_details_on_invoice_number
- index_vendor_details_on_updated_by_id

**外部キー**:
- (office_city_code) → m_cities.code
- (deleted_by_id) → users.id
- (office_prefecture_code) → m_prefectures.code
- (created_by_id) → users.id
- (user_id) → users.id
- (updated_by_id) → users.id
- (office_city_code) → m_cities.code
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END vendor_details -->

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
- h_article_views_202510_article_id_idx
- h_article_views_202510_article_id_idx1
- h_article_views_202510_id_idx
- h_article_views_202510_unproc_idx
- h_article_views_202510_user_id_idx

**外部キー**:
- (article_id) → articles.id
- (user_id) → users.id
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
- h_article_views_202512_article_id_idx
- h_article_views_202512_article_id_idx1
- h_article_views_202512_id_idx
- h_article_views_202512_unproc_idx
- h_article_views_202512_user_id_idx

**外部キー**:
- (article_id) → articles.id
- (user_id) → users.id
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
- h_article_views_202601_article_id_idx
- h_article_views_202601_article_id_idx1
- h_article_views_202601_id_idx
- h_article_views_202601_unproc_idx
- h_article_views_202601_user_id_idx

**外部キー**:
- (article_id) → articles.id
- (user_id) → users.id
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
- h_article_views_202602_article_id_idx
- h_article_views_202602_article_id_idx1
- h_article_views_202602_id_idx
- h_article_views_202602_unproc_idx
- h_article_views_202602_user_id_idx

**外部キー**:
- (article_id) → articles.id
- (user_id) → users.id
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
- h_audit_trails_202505_changed_by_idx
- h_audit_trails_202505_changed_by_idx1
- h_audit_trails_202505_id_idx
- h_audit_trails_202505_id_idx1
- h_audit_trails_202505_table_name_idx
- h_audit_trails_202505_table_name_idx1

**外部キー**:
- (changed_by) → users.id
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
- h_login_attempts_202505_id_idx
- h_login_attempts_202505_id_idx1
- h_login_attempts_202505_ip_address_idx
- h_login_attempts_202505_ip_address_idx1
- h_login_attempts_202505_user_id_idx
- h_login_attempts_202505_user_id_idx1

**外部キー**:
- (user_id) → users.id
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
- h_payment_webhooks_202505_gateway_event_id_idx
- h_payment_webhooks_202505_uq

**外部キー**:
- (order_id) → orders.id
- (payout_id) → payouts.id
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
- h_payment_webhooks_202506_gateway_event_id_idx
- h_payment_webhooks_202506_uq

**外部キー**:
- (order_id) → orders.id
- (payout_id) → payouts.id
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
- h_payment_webhooks_202507_gateway_event_id_idx
- h_payment_webhooks_202507_uq

**外部キー**:
- (order_id) → orders.id
- (payout_id) → payouts.id
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
- h_payment_webhooks_202508_gateway_event_id_idx
- h_payment_webhooks_202508_uq

**外部キー**:
- (order_id) → orders.id
- (payout_id) → payouts.id
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
- h_payment_webhooks_202510_gateway_event_id_idx
- h_payment_webhooks_202510_uq

**外部キー**:
- (order_id) → orders.id
- (payout_id) → payouts.id
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
- h_error_logs_202505_error_class_idx
- h_error_logs_202505_id_idx
- h_error_logs_202505_request_id_idx
- h_error_logs_202505_request_path_idx
- h_error_logs_202505_user_id_idx

**外部キー**:
- (user_id) → users.id
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
- h_error_logs_202506_error_class_idx
- h_error_logs_202506_id_idx
- h_error_logs_202506_request_id_idx
- h_error_logs_202506_request_path_idx
- h_error_logs_202506_user_id_idx

**外部キー**:
- (user_id) → users.id
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
- h_error_logs_202507_error_class_idx
- h_error_logs_202507_id_idx
- h_error_logs_202507_request_id_idx
- h_error_logs_202507_request_path_idx
- h_error_logs_202507_user_id_idx

**外部キー**:
- (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_error_logs_202507 -->

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
- index_recipe_snapshots_on_recipe_id

**外部キー**:
- (recipe_id) → recipes.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END recipe_snapshots -->

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
- h_error_logs_202508_error_class_idx
- h_error_logs_202508_id_idx
- h_error_logs_202508_request_id_idx
- h_error_logs_202508_request_path_idx
- h_error_logs_202508_user_id_idx

**外部キー**:
- (user_id) → users.id
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
- h_error_logs_202509_error_class_idx
- h_error_logs_202509_id_idx
- h_error_logs_202509_request_id_idx
- h_error_logs_202509_request_path_idx
- h_error_logs_202509_user_id_idx

**外部キー**:
- (user_id) → users.id
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
- h_error_logs_202510_error_class_idx
- h_error_logs_202510_id_idx
- h_error_logs_202510_request_id_idx
- h_error_logs_202510_request_path_idx
- h_error_logs_202510_user_id_idx

**外部キー**:
- (user_id) → users.id
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
- h_error_logs_202511_error_class_idx
- h_error_logs_202511_id_idx
- h_error_logs_202511_request_id_idx
- h_error_logs_202511_request_path_idx
- h_error_logs_202511_user_id_idx

**外部キー**:
- (user_id) → users.id
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
- h_error_logs_202512_error_class_idx
- h_error_logs_202512_id_idx
- h_error_logs_202512_request_id_idx
- h_error_logs_202512_request_path_idx
- h_error_logs_202512_user_id_idx

**外部キー**:
- (user_id) → users.id
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
- h_error_logs_202602_error_class_idx
- h_error_logs_202602_id_idx
- h_error_logs_202602_request_id_idx
- h_error_logs_202602_request_path_idx
- h_error_logs_202602_user_id_idx

**外部キー**:
- (user_id) → users.id
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
- h_error_logs_202603_error_class_idx
- h_error_logs_202603_id_idx
- h_error_logs_202603_request_id_idx
- h_error_logs_202603_request_path_idx
- h_error_logs_202603_user_id_idx

**外部キー**:
- (user_id) → users.id
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
- h_error_logs_202604_error_class_idx
- h_error_logs_202604_id_idx
- h_error_logs_202604_request_id_idx
- h_error_logs_202604_request_path_idx
- h_error_logs_202604_user_id_idx

**外部キー**:
- (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_error_logs_202604 -->

<!-- TABLE_BEGIN users -->
## users

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| public_uid | character varying(32) | × |  |  |
| email | character varying | × |  |  |
| encrypted_password | character varying | × |  |  |
| role | smallint | × |  |  |
| password_changed_at | timestamp(6) without time zone | × |  |  |
| password_expires_at | timestamp(6) without time zone | ○ |  |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| reset_password_token | character varying | ○ |  |  |
| reset_password_sent_at | timestamp(6) without time zone | ○ |  |  |
| remember_created_at | timestamp(6) without time zone | ○ |  |  |
| sign_in_count | integer | × | 0 |  |
| current_sign_in_at | timestamp(6) without time zone | ○ |  |  |
| last_sign_in_at | timestamp(6) without time zone | ○ |  |  |
| current_sign_in_ip | character varying | ○ |  |  |
| last_sign_in_ip | character varying | ○ |  |  |
| failed_attempts | integer | × | 0 |  |
| unlock_token | character varying | ○ |  |  |
| locked_at | timestamp(6) without time zone | ○ |  |  |

**インデックス**:
- index_users_on_created_by_id
- index_users_on_deleted_by_id
- index_users_on_email
- index_users_on_public_uid
- index_users_on_reset_password_token
- index_users_on_unlock_token
- index_users_on_updated_by_id

**外部キー**:
- (deleted_by_id) → users.id
- (updated_by_id) → users.id
- (created_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END users -->

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
- h_article_views_202505_article_id_idx
- h_article_views_202505_article_id_idx1
- h_article_views_202505_id_idx
- h_article_views_202505_unproc_idx
- h_article_views_202505_user_id_idx

**外部キー**:
- (article_id) → articles.id
- (user_id) → users.id
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
- h_article_views_202506_article_id_idx
- h_article_views_202506_article_id_idx1
- h_article_views_202506_id_idx
- h_article_views_202506_unproc_idx
- h_article_views_202506_user_id_idx

**外部キー**:
- (article_id) → articles.id
- (user_id) → users.id
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
- h_article_views_202507_article_id_idx
- h_article_views_202507_article_id_idx1
- h_article_views_202507_id_idx
- h_article_views_202507_unproc_idx
- h_article_views_202507_user_id_idx

**外部キー**:
- (article_id) → articles.id
- (user_id) → users.id
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
- h_article_views_202508_article_id_idx
- h_article_views_202508_article_id_idx1
- h_article_views_202508_id_idx
- h_article_views_202508_unproc_idx
- h_article_views_202508_user_id_idx

**外部キー**:
- (article_id) → articles.id
- (user_id) → users.id
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
- h_article_views_202509_article_id_idx
- h_article_views_202509_article_id_idx1
- h_article_views_202509_id_idx
- h_article_views_202509_unproc_idx
- h_article_views_202509_user_id_idx

**外部キー**:
- (article_id) → articles.id
- (user_id) → users.id
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
- h_article_views_202511_article_id_idx
- h_article_views_202511_article_id_idx1
- h_article_views_202511_id_idx
- h_article_views_202511_unproc_idx
- h_article_views_202511_user_id_idx

**外部キー**:
- (article_id) → articles.id
- (user_id) → users.id
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
- h_article_views_202603_article_id_idx
- h_article_views_202603_article_id_idx1
- h_article_views_202603_id_idx
- h_article_views_202603_unproc_idx
- h_article_views_202603_user_id_idx

**外部キー**:
- (article_id) → articles.id
- (user_id) → users.id
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
- h_article_views_202604_article_id_idx
- h_article_views_202604_article_id_idx1
- h_article_views_202604_id_idx
- h_article_views_202604_unproc_idx
- h_article_views_202604_user_id_idx

**外部キー**:
- (article_id) → articles.id
- (user_id) → users.id
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
- h_payment_webhooks_202509_gateway_event_id_idx
- h_payment_webhooks_202509_uq

**外部キー**:
- (order_id) → orders.id
- (payout_id) → payouts.id
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
- h_payment_webhooks_202511_gateway_event_id_idx
- h_payment_webhooks_202511_uq

**外部キー**:
- (order_id) → orders.id
- (payout_id) → payouts.id
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
- h_payment_webhooks_202512_gateway_event_id_idx
- h_payment_webhooks_202512_uq

**外部キー**:
- (order_id) → orders.id
- (payout_id) → payouts.id
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
- h_payment_webhooks_202601_gateway_event_id_idx
- h_payment_webhooks_202601_uq

**外部キー**:
- (order_id) → orders.id
- (payout_id) → payouts.id
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
- h_payment_webhooks_202602_gateway_event_id_idx
- h_payment_webhooks_202602_uq

**外部キー**:
- (order_id) → orders.id
- (payout_id) → payouts.id
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
- h_payment_webhooks_202603_gateway_event_id_idx
- h_payment_webhooks_202603_uq

**外部キー**:
- (order_id) → orders.id
- (payout_id) → payouts.id
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
- h_payment_webhooks_202604_gateway_event_id_idx
- h_payment_webhooks_202604_uq

**外部キー**:
- (order_id) → orders.id
- (payout_id) → payouts.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END h_payment_webhooks_202604 -->

<!-- TABLE_BEGIN vendor_service_prefectures -->
## vendor_service_prefectures

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| vendor_id | bigint | × |  |  |
| prefecture_code | character varying(2) | × |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- idx_vsp_unique

**外部キー**:
- (vendor_id) → vendor_details.user_id
- (prefecture_code) → m_prefectures.code
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END vendor_service_prefectures -->

<!-- TABLE_BEGIN member_shipping_addresses -->
## member_shipping_addresses

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| member_id | bigint | × |  |  |
| label | character varying(50) | ○ |  |  |
| recipient_name | character varying(100) | × |  |  |
| postal_code | character varying(8) | × |  |  |
| prefecture_code | character varying(2) | × |  |  |
| city_code | character varying(5) | × |  |  |
| address_line | character varying(200) | × |  |  |
| phone_number | character varying(20) | ○ |  |  |
| is_default | boolean | × | false |  |
| created_by_id | bigint | ○ |  |  |
| updated_by_id | bigint | ○ |  |  |
| deleted_flag | boolean | × | false |  |
| deleted_at | timestamp(6) without time zone | ○ |  |  |
| deleted_by_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| department | character varying(100) | ○ |  |  |

**インデックス**:
- index_member_shipping_addresses_on_created_by_id
- index_member_shipping_addresses_on_deleted_by_id
- index_member_shipping_addresses_on_member_id
- index_member_shipping_addresses_on_updated_by_id
- uq_member_default_address

**外部キー**:
- (city_code) → m_cities.code
- (member_id) → member_details.user_id
- (prefecture_code) → m_prefectures.code
- (city_code) → m_cities.code
- (updated_by_id) → users.id
- (deleted_by_id) → users.id
- (created_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END member_shipping_addresses -->

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
- index_part_files_on_part_id

**外部キー**:
- (part_id) → parts.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END part_files -->

<!-- TABLE_BEGIN recipes -->
## recipes

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| user_id | bigint | × |  |  |
| name | character varying(60) | × |  |  |
| status | integer | × | 0 |  |
| latest_snapshot_id | bigint | ○ |  |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- index_recipes_on_latest_snapshot_id
- index_recipes_on_user_id

**外部キー**:
- (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END recipes -->

<!-- TABLE_BEGIN recipe_parts -->
## recipe_parts

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| recipe_id | bigint | × |  |  |
| part_id | bigint | × |  |  |
| quantity | integer | × | 1 |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |

**インデックス**:
- index_recipe_parts_on_part_id
- index_recipe_parts_on_recipe_id

**外部キー**:
- (recipe_id) → recipes.id
- (part_id) → parts.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END recipe_parts -->

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
- index_recipe_snapshot_parts_on_part_snapshot_id
- index_recipe_snapshot_parts_on_recipe_snapshot_id

**外部キー**:
- (recipe_snapshot_id) → recipe_snapshots.id
- (part_snapshot_id) → part_snapshots.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END recipe_snapshot_parts -->

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
- index_carts_on_shipping_address_id
- index_carts_on_user_id

**外部キー**:
- (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END carts -->

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
- index_rfqs_on_shipping_address_id
- index_rfqs_on_user_id

**外部キー**:
- (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END rfqs -->

<!-- TABLE_BEGIN cart_items -->
## cart_items

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| cart_id | bigint | × |  |  |
| part_id | bigint | × |  |  |
| quantity | integer | × | 1 |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| origin_snapshot_id | bigint | ○ |  |  |
| origin_owner_id | bigint | ○ |  |  |

**インデックス**:
- index_cart_items_on_cart_id
- index_cart_items_on_part_id

**外部キー**:
- (part_id) → parts.id
- (cart_id) → carts.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END cart_items -->

<!-- TABLE_BEGIN rfq_parts -->
## rfq_parts

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| rfq_id | bigint | × |  |  |
| part_snapshot_id | bigint | × |  |  |
| quantity | integer | × | 1 |  |
| created_at | timestamp(6) without time zone | × |  |  |
| updated_at | timestamp(6) without time zone | × |  |  |
| origin_snapshot_id | bigint | × |  |  |
| origin_owner_id | bigint | × |  |  |

**インデックス**:
- index_rfq_parts_on_origin_owner_id
- index_rfq_parts_on_part_snapshot_id
- index_rfq_parts_on_rfq_id

**外部キー**:
- (part_snapshot_id) → part_snapshots.id
- (rfq_id) → rfqs.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
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
- index_vendor_offers_on_created_by_id
- index_vendor_offers_on_deleted_by_id
- index_vendor_offers_on_rfq_id
- index_vendor_offers_on_rfq_id_and_status
- index_vendor_offers_on_status
- index_vendor_offers_on_updated_by_id
- index_vendor_offers_on_vendor_id
- index_vendor_offers_on_vendor_id_and_status
- uniq_vendor_offer_per_rfq

**外部キー**:
- (updated_by_id) → users.id
- (deleted_by_id) → users.id
- (created_by_id) → users.id
- (rfq_id) → rfqs.id
- (vendor_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END vendor_offers -->

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
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END transaction_shipping_addresses -->

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
- index_vendor_offer_items_on_created_by_id
- index_vendor_offer_items_on_deleted_by_id
- index_vendor_offer_items_on_rfq_part_id
- index_vendor_offer_items_on_updated_by_id
- index_vendor_offer_items_on_vendor_offer_id
- uniq_offer_item

**外部キー**:
- (rfq_part_id) → rfq_parts.id
- (vendor_offer_id) → vendor_offers.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END vendor_offer_items -->

<!-- TABLE_BEGIN parts -->
## parts

<!-- AUTO BEGIN -->
| 列名 | 型 | NULL | デフォルト | 説明 |
|------|----|------|-----------|------|
| id | bigint | × |  |  |
| user_id | bigint | × |  |  |
| name | character varying(50) | × |  |  |
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
- index_parts_on_corner_proc_json
- index_parts_on_created_by_id
- index_parts_on_deleted_by_id
- index_parts_on_hole_json
- index_parts_on_origin_snapshot_id
- index_parts_on_sqhole_json
- index_parts_on_updated_by_id
- index_parts_on_user_id

**外部キー**:
- (deleted_by_id) → users.id
- (material_category_code) → m_categories.code
- (material_code) → m_materials.code
- (shape_code) → m_shapes.code
- (updated_by_id) → users.id
- (created_by_id) → users.id
- (paint_type_code) → m_paint_types.code
- (user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END parts -->

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
- index_part_snapshots_on_checksum
- index_part_snapshots_on_corner_proc_json
- index_part_snapshots_on_created_by_id
- index_part_snapshots_on_deleted_by_id
- index_part_snapshots_on_hole_json
- index_part_snapshots_on_origin_snapshot_id
- index_part_snapshots_on_part_id
- index_part_snapshots_on_sqhole_json
- index_part_snapshots_on_updated_by_id

**外部キー**:
- (paint_type_code) → m_paint_types.code
- (material_code) → m_materials.code
- (material_category_code) → m_categories.code
- (created_by_id) → users.id
- (updated_by_id) → users.id
- (part_id) → parts.id
- (shape_code) → m_shapes.code
- (deleted_by_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END part_snapshots -->

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
- idx_commission_settlement
- index_affiliate_recipe_commissions_on_created_by_id
- index_affiliate_recipe_commissions_on_deleted_by_id
- index_affiliate_recipe_commissions_on_fork_user_id
- index_affiliate_recipe_commissions_on_order_id
- index_affiliate_recipe_commissions_on_original_user_id
- index_affiliate_recipe_commissions_on_recipe_snapshot_id
- index_affiliate_recipe_commissions_on_updated_by_id
- uniq_commission_per_order_and_snapshot

**外部キー**:
- (fork_user_id) → users.id
- (recipe_snapshot_id) → recipe_snapshots.id
- (order_id) → orders.id
- (original_user_id) → users.id
<!-- AUTO END -->

<!-- NOTE BEGIN -->
<!-- 任意のメモを書いてください -->
<!-- NOTE END -->

<!-- TABLE_END affiliate_recipe_commissions -->

