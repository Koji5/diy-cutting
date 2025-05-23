# DIYカッティングサービス

> *“Cut it your way, deliver it your day.”* ― オンライン木材カット・加工プラットフォーム

&#x20;&#x20;

---

## 目次

1. [はじめに](#はじめに)
2. [アーキテクチャ概要](#アーキテクチャ概要)
3. [機能一覧](#機能一覧)
4. [技術スタック](#技術スタック)
5. [開発環境構築](#開発環境構築)
6. [デプロイ](#デプロイ)
7. [ドキュメント](#ドキュメント)
8. [ロードマップ](#ロードマップ)
9. [ライセンス](#ライセンス)
10. [コントリビュート](#コントリビュート)

---

## はじめに

DIY 市場では、板材を希望のサイズ・形状にカットして届けてもらいたいというニーズが拡大しています。一方で中小の木材加工業者はオンライン集客や見積対応の手段が限られています。本プロジェクトは **ユーザー・加工業者・アフィリエイター** をマッチングし、見積依頼〜決済〜発送までをワンストップで提供するプラットフォームを開発します。

### 目的

* ユーザーが最適な加工業者を簡単に見つけ、安心して依頼できること
* 業者が手間なくオンラインで受注し、売上を拡大できること
* アフィリエイターが体験記事を通じて集客し、成果報酬を得られること

---

## アーキテクチャ概要

```mermaid
graph TD
  A[Next.js (LP)]
  B[Rails API / Hotwire]
  C[Front‑end]
  D[Sidekiq]
  E[(PostgreSQL)]
  F[S3 Storage]
  G[SES / FCM]

  A -->|REST| B
  B -- "Turbo Stream / WebSocket" --> C
  C -. "returns" .-> B
  B --> D
  D --> E
  E --> F
  D --> G
```

* **Rails 8 + Hotwire** によるフルスタック構成
* **Importmap** を採用し、JS バンドラを排除 (esbuild 非使用)
* **cssbundling‑rails (Bootstrap 5.3)** で CSS をビルド
* IaC: **Terraform** + **GitHub Actions** で CI/CD

---

## 機能一覧

| カテゴリ    | 主な機能例                                   | 備考                  |
| ------- | --------------------------------------- | ------------------- |
| 共通      | アカウント登録 / OAuth, プロフィール管理, 検索, 通知       | 日本語 UI / i18n 準備済み  |
| ユーザー    | 材料選択, カート, 見積依頼, チャット (図面添付), 決済, 受取・評価 | 板取り自動計算, 領収書 PDF    |
| 業者      | 見積回答, 製造・発送管理, 請求書発行, 売上レポート            | QR ラベル出力, CSV 取込・出力 |
| アフィリエイト | 紹介リンク, 成果報酬レポート, 振込申請                   | UTM 自動付与            |
| 管理者     | ダッシュボード, 取引監視, 手数料設定, CMS               | 重大アラート Slack 通知     |

> 詳細な要件は [`docs/spec`](docs/spec) を参照してください。

---

## 技術スタック

| レイヤ           | 技術 / SaaS                                           | 備考                         |
| ------------- | --------------------------------------------------- | -------------------------- |
| **Framework** | Ruby 3.3, **Rails 8.0**, Hotwire (Turbo / Stimulus) | Form は `form_with` のみ採用    |
| **Frontend**  | Importmap, Bootstrap 5.3, Font Awesome              | esbuild 不使用                |
| **DB**        | PostgreSQL 16                                       | パーティションテーブル (月次) 採用        |
| **Queue**     | Sidekiq + Redis                                     | 非同期ジョブ (メール, 通知)           |
| **Container** | Docker Compose                                      | Windows + WSL2 サポート        |
| **Cloud**     | AWS (ECS Fargate, RDS, S3, SES)                     | IaC (Terraform)            |
| **Payments**  | Stripe                                              | Connect でマーケットプレイス課金       |
| **Shipping**  | 佐川 e飛伝 / ヤマト B2                                     | API 連携                     |
| **CI / CD**   | GitHub Actions                                      | RSpec + RuboCop + Brakeman |

---

## 開発環境構築

### 前提条件

* **Windows 10/11** + **WSL2** (Ubuntu 22.04) ※ macOS / Linux も可
* **Docker Desktop** 4.30 以上
* **Git** 2.44 以上
* (任意) **mkcert** で自己署名証明書

### 手順 (PowerShell 例)

```powershell
# 1. リポジトリを取得
> git clone https://github.com/your-org/diy-cutting.git
> cd diy-cutting

# 2. 環境変数を設定
> copy .env.example .env
#   STRIPE_SECRET_KEY などを編集

# 3. ビルド & DB 起動
> docker compose build
> docker compose up -d db

# 4. 初期セットアップ (DB 作成 & Seed)
> docker compose run --rm app bin/setup

# 5. 全サービス起動
> docker compose up -d
```

### よく使うコマンド

```powershell
# Rails サーバ (Turbo 含む)
> docker compose run --rm --service-ports app bin/rails server

# DB マイグレーション
> docker compose run --rm app bin/rails db:migrate

# RSpec 実行
> docker compose run --rm app bin/rspec

# RuboCop + Brakeman
> docker compose run --rm app bundle exec rubocop
> docker compose run --rm app bundle exec brakeman -q

# production-like build (ECS 用)
> docker compose -f docker-compose.prod.yml build
```

> **Windows Tips**: PowerShell では `grep` が使えないため、検索は `findstr` を利用してください。例: `docker compose logs | findstr ERROR`。

---

## デプロイ

| 環境         | URL                           | 備考                                       |
| ---------- | ----------------------------- | ---------------------------------------- |
| Preview    | `https://preview.example.com` | GitHub `main` ブランチ push 時自動デプロイ          |
| Production | `https://cutting.example.com` | GitHub Releases 作成時に ECS Blue/Green デプロイ |

デプロイフローは **GitHub Actions** → **ECR** → **ECS/Fargate**。Terraform によるインフラコードは [`infra/`](infra) ディレクトリにあります。

---

## ドキュメント

| 種別          | 場所                                     | 内容                           |
| ----------- | -------------------------------------- | ---------------------------- |
| ER 図 / CRUD | [docs/db/](docs/db)                    | `*.puml` (PlantUML) & `*.md` |
| DB テーブル一覧   | [docs/db/tables.md](docs/db/tables.md) | Markdown 一覧                  |
| API 仕様      | [docs/api/](docs/api)                  | OpenAPI (YAML) & Redoc       |
| 画面遷移図       | [docs/ux/](docs/ux)                    | UIFlow / Adobe XD            |
| 要件定義        | [docs/spec/](docs/spec)                | Markdown                     |

---

## ロードマップ

| Phase | 期間         | マイルストーン            |
| ----- | ---------- | ------------------ |
| 0     | 〜2025‑01   | 要件確定, ワイヤーフレーム     |
| 1     | 2025‑02〜04 | MVP (ユーザー・業者コア機能)  |
| 2     | 2025‑05〜06 | 決済・配送 API, アフィリエイト |
| 3     | 2025‑07    | 公開 β, 負荷試験         |
| 4     | 2025‑08    | 正式リリース             |

---

## ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。詳細は [`LICENSE`](LICENSE) を参照してください。

---

## コントリビュート

1. `main` ブランチへ直接 push しないでください。必ず **feature ブランチ** を切り、PR を作成してください。
2. PR 作成時に以下が自動実行されます。

   * RSpec
   * RuboCop / Brakeman
   * ER 図生成 (PlantUML)
3. CI が通過後、レビューを 1 件以上獲得してください。
4. マージ後 GitHub Actions がデプロイを実行します。

フィードバックや Issue 登録は日本語で歓迎します。
