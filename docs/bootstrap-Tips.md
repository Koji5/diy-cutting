# Bootstrap 5.3 Tips

## ブレークポイント

### ブレークポイント（breakpoint）とは？

レスポンシブ Web デザインで **レイアウトを切り替えるための“閾値（しきい値）”となる画面幅** のことです。

* **画面幅がその値を超える／下回る** タイミングで CSS の `@media` ルールが発火し、レイアウト・フォントサイズ・カラム数などを最適化します。
* Bootstrap では **「モバイル先行（mobile-first）」** なので *最小幅（min-width）* を基準に書き、狭い画面用のスタイル → ブレークポイントを超えたら上書き、という流れになります。

---

### 1. Bootstrap 5.3 のデフォルトブレークポイント

| 名称  | 変数 (`$grid-breakpoints`) | 幅(px)  | 使い方の目安                              |
| --- | ------------------------ | ------ | ----------------------------------- |
| xs  | 0                        | < 576  | ほぼすべてのスマホ（定義名はあるがユーティリティ接尾辞には出てこない） |
| sm  | 576                      | ≥ 576  | 大きめスマホ / 縦タブレット                     |
| md  | 768                      | ≥ 768  | 横タブレット / 小型ノート                      |
| lg  | 992                      | ≥ 992  | 一般的ノート (13–14")                     |
| xl  | 1200                     | ≥ 1200 | デスクトップ / 大型ノート                      |
| xxl | 1400                     | ≥ 1400 | ワイドデスクトップ                           |

> **ユーティリティクラス**は接尾辞で使います：
> `d-none d-lg-block` → 992 px 以上で表示、未満では非表示。

---

### 2. SCSS でのメディアクエリ・ミックスイン

Bootstrap の SCSS にはブレークポイント関連ミックスインが用意されています（`bootstrap/scss/mixins/_breakpoints.scss`）。

| ミックスイン                                              | 意味                | 例                                                 |
| --------------------------------------------------- | ----------------- | ------------------------------------------------- |
| `@include media-breakpoint-up($name)`               | **以上**（min-width） | `@include media-breakpoint-up(lg) { … }`          |
| `@include media-breakpoint-down($name)`             | **以下**（max-width） | `@include media-breakpoint-down(md) { … }`        |
| `@include media-breakpoint-between($lower, $upper)` | 範囲                | `@include media-breakpoint-between(sm, lg) { … }` |
| `@include media-breakpoint-only($name)`             | その幅帯だけ            | `@include media-breakpoint-only(xl) { … }`        |

```scss
// 例：lg 以上でカードサイズを大きく
.card {
  font-size: .9rem;

  @include media-breakpoint-up(lg) {
    font-size: 1.1rem;
  }
}
```

---

### 3. ブレークポイントをカスタマイズする方法

1. **変数マップ `$grid-breakpoints`** を上書き
2. **`$container-max-widths`** など関連マップも合わせて更新
3. そのあとに `@import "bootstrap/scss/bootstrap";`

```scss
// app/assets/stylesheets/application.bootstrap.scss
$grid-breakpoints: (
  xs: 0,
  sm: 480px,  // 狭いスマホ最適化
  md: 768px,
  lg: 1024px, // iPad 横 + 小型ノート
  xl: 1280px,
  xxl: 1536px
);

$container-max-widths: (
  sm: 440px,
  md: 720px,
  lg: 960px,
  xl: 1140px,
  xxl: 1320px
);

@import "bootstrap/scss/bootstrap";
```

カスタマイズは **変数定義→`@import` の順** が鉄則です。

---

### 4. Rails 8 + cssbundling-rails での運用ポイント

* ファイルは `application.bootstrap.scss` など **`.scss` 拡張子** にし、`bin/dev` で sass が自動再ビルド。
* 変更が反映されないときは **ブラウザキャッシュ**を疑う（`?v=…` が付くよう `asset_url` が自動で付番）。
* Bootstrap の JavaScript 側ブレークポイント検知（`window.bootstrap.Breakpoint` など）は **SCSS と連動**するので、カスタム時は JS でも同じ値が参照されます。

---

#### まとめ

* **ブレークポイント** = 画面幅の切替点。Bootstrap ではモバイル先行で `min-width` ベース。
* デフォルトは `sm 576px` ～ `xxl 1400px`。ユーティリティ接尾辞や SCSS ミックスインで直感的に利用可能。
* プロジェクト固有のデバイス比率に合わせたい場合は **`$grid-breakpoints` マップを上書き → 再コンパイル** するだけ。
* Rails + Hotwire 環境でも Importmap / cssbundling に従えば追加設定なしで扱えます。
  
<br>
<br>

## ユーティリティ（utility class）

### ユーティリティ（utility class）とは？

Bootstrap では **「1 プロパティ＝1 クラス」で要素に直接スタイルを付ける**ための極小クラス群を **ユーティリティクラス**と呼びます。

* 例：`mt-3`（margin-top: 1rem）、`d-flex`（display: flex）、`text-center`（text-align: center）など。
* **HTML に即貼り付けて完結**するので、追加の SCSS を書かずにレイアウトや細かな調整ができます。
* Bootstrap 5 以降は **Utility API** で Sass マップから自動生成されており、簡単に追加・拡張・削除が可能です。 ([getbootstrap.com][1])

---

### 1. ユーティリティ vs. コンポーネント

| 特徴   | ユーティリティ          | コンポーネント（カード、モーダル等） |
| ---- | ---------------- | ------------------ |
| 粒度   | 1 つの CSS プロパティ   | 複数プロパティを組合せた UI    |
| 使用方法 | HTML クラスを直接付与    | マークアップと JS がセット    |
| 目的   | 素早い余白・配置調整、色変更など | 完成された UI 部品を配置     |

---

### 2. 主なユーティリティカテゴリと書式例

| カテゴリ                                        | 例                                                          | 説明                                                                                                      |
| ------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| **Spacing**                                 | `mt-3`, `px-lg-2`                                          | margin/padding。`t`=top, `x`=左右、末尾数字がサイズ（0-5）。ブレークポイントを途中に記述 (`-lg-`) でレスポンシブ対応。 ([getbootstrap.com][2]) |
| **Display**                                 | `d-none`, `d-md-block`                                     | display 値を切替。min-width ベースで可変。 ([getbootstrap.com][3])                                                  |
| **Flexbox**                                 | `d-flex`, `justify-content-between`                        | フレックス系。 ([getbootstrap.com][4])                                                                         |
| **Colors**                                  | `text-primary`, `bg-success`                               | テキスト色・背景色。 ([getbootstrap.com][5])                                                                      |
| **Position / Sizing / Overflow / Shadow …** | `position-relative`, `w-100`, `overflow-auto`, `shadow-lg` | 単機能クラスを多数収録。                                                                                            |

> **命名パターン**
> `property[-side]-value[-breakpoint][-state]`
> 例：`ps-4`（padding-start:1.5rem）、`order-2 order-lg-0`、`text-decoration-underline-hover`

---

### 3. Responsive・擬似クラスバリアント

* **ブレークポイント**を `-{sm|md|lg|xl|xxl}` で差し込み：`d-none d-lg-block`（992 px 以上で表示）
* **擬似クラス**を `-hover`, `-focus` 等で追加：`text-decoration-underline-hover`

Utility API では `responsive: true`, `state: hover` のようにマップで制御できます。

---

### 4. Sass Utility API でのカスタマイズ

```scss
// application.bootstrap.scss

// (1) 既存ユーティリティを拡張：width に 10% を追加
$utilities: map-merge(
  $utilities,
  (
    "width": map-merge(
      map-get($utilities, "width"),
      (values: map-merge(map-get(map-get($utilities, "width"), "values"), (10: 10%)))
    )
  )
);

// (2) 新規ユーティリティを定義：text-indent
$utilities: map-merge(
  $utilities,
  (
    "text-indent": (
      property: text-indent,
      class: ti,
      values: (0: 0, 1: 1rem, 2: 2rem),
      responsive: true
    )
  )
);

@import "bootstrap/scss/bootstrap"; // 最後に！
```

* 上では `$utilities` マップを `map-merge()` で上書きしています。
* API の詳細は公式ドキュメント「Utility API」参照。 ([getbootstrap.com][6], [getbootstrap.com][7])

---

### 5. Rails 8 + cssbundling-rails での運用

1. **`.scss` ファイル**に上記のようにマップを上書き → `@import`。
2. `bin/dev` (dart-sass ウォッチ) を実行中なら保存と同時に再ビルド。
3. HTML 側では `<div class="d-flex align-items-center gap-2">` のように記述。
4. “何度も使う組合せ” は **パーシャル SCSS にミックスイン**を切り出す、もしくは Rails の **ViewComponent** としてカプセル化すると可読性が保てます。

---

### 6. 使い分けの指針

| シーン                | 推奨                         | 理由           |
| ------------------ | -------------------------- | ------------ |
| **小さな余白・配置調整**     | ユーティリティ                    | 速く、変更影響が限定的  |
| **複数要素に跨る UI/トーン** | 独自クラス or コンポーネント           | DRY・命名規約で統制  |
| **デザインガイドラインにない色** | `$theme-colors` 拡張＋ユーティリティ | 公式カラーシステムに統合 |
| **“○○だけ例外”**       | ユーティリティ＋`!important`       | 破壊的変更を避け局所対応 |

---

#### まとめ

* **ユーティリティクラス = “1 プロパティ完結” の直書きクラス**。余白、表示、色などを素早く調整できる。
* Bootstrap 5 では **Utility API** により SCSS 側で自由に拡張・削減可。
* Rails 8 + Hotwire プロジェクトでは `application.bootstrap.scss` で `$utilities` を上書きし、Importmap で JS を読み込むだけでフル機能を利用できる。
* 「一時的な調整にはユーティリティ」「再利用 UI には独自クラス or コンポーネント」と役割分担するのが実践的です。

[1]: https://getbootstrap.com/?utm_source=chatgpt.com "Bootstrap · The most popular HTML, CSS, and JS library in the world."
[2]: https://getbootstrap.com/docs/5.0/utilities/spacing/?utm_source=chatgpt.com "Spacing · Bootstrap v5.0"
[3]: https://getbootstrap.com/docs/5.0/utilities/display/?utm_source=chatgpt.com "Display property · Bootstrap v5.0"
[4]: https://getbootstrap.com/docs/5.0/utilities/flex/?utm_source=chatgpt.com "Flex · Bootstrap v5.0"
[5]: https://getbootstrap.com/docs/5.0/utilities/colors/?utm_source=chatgpt.com "Colors · Bootstrap v5.0"
[6]: https://getbootstrap.com/docs/5.0/utilities/api/?utm_source=chatgpt.com "Utility API · Bootstrap v5.0"
[7]: https://getbootstrap.com/docs/5.3/utilities/api/?utm_source=chatgpt.com "Utility API · Bootstrap v5.3"
  
<br>
<br>

## 変数

### 1. Sass における **変数（variable）** とは

* `Sass` では **`$primary: #0d6efd;`** のように **デザインの“値”を名前で管理**できます。
* Bootstrap の全変数には `!default` が付いているため、**自分のファイルで同じ名前を先に再定義すれば簡単に上書き**できます（元ファイルを改変する必要なし）｡([getbootstrap.com][1])

---

### 2. Bootstrap が標準で用意している主な変数グループ

> 完全版は `node_modules/bootstrap/scss/_variables.scss` に約 1,500 行分入っています。ここでは実務で触れることの多いカテゴリだけを抜粋します。

| 分類               | 代表的な変数例                                                                          | 何を制御するか                  |
| ---------------- | -------------------------------------------------------------------------------- | ------------------------ |
| **カラー**          | `$blue`, `$red`, `$primary`, `$theme-colors` (Sass Map)                          | ブランド色・アラート色など            |
| **ブレークポイント**     | `$grid-breakpoints`, `$container-max-widths`                                     | 画面幅 xs〜xxl の閾値           |
| **スペーサー**        | `$spacer`, `$spacers` (Map)                                                      | `mt-3` など余白ユーティリティのサイズ階層 |
| **タイポグラフィ**      | `$font-family-base`, `$font-size-base`, `$line-height-base`, `$font-sizes` (Map) | 基本フォントとスケール              |
| **角丸・影**         | `$border-radius`, `$box-shadow` ほか                                               | UI の丸み・シャドウ強度            |
| **Z-index スタック** | `$zindex-modal`, `$zindex-dropdown` など                                           | レイヤー順序                   |
| **各コンポーネント**     | `$btn-padding-y`, `$navbar-padding-x` …                                          | ボタンやナビバーの内部余白など          |

---

### 3. 変数の中身を覗いてみる

* **カラー系**
  `$theme-colors` マップには `primary / secondary / success …` の 8 色が定義されており、`bg-primary` などのユーティリティ生成にも使われます。([getbootstrap.com][2])

* **ブレークポイント**
  デフォルトは下記マップで、すべて **モバイル先行の `min-width`** です。([getbootstrap.com][3])

  ```scss
  $grid-breakpoints: (
    xs: 0,
    sm: 576px,
    md: 768px,
    lg: 992px,
    xl: 1200px,
    xxl: 1400px
  );
  ```

* **スペーサー**
  余白ユーティリティは `$spacer`（1 rem）と `$spacers` マップを倍率で展開して作られます。([getbootstrap.com][4])

* **タイポグラフィ**
  `$font-family-base`, `$font-size-base`, `$line-height-base` が全ページの「素」を決めています。([getbootstrap.com][5])

---

### 4. Rails 8 × cssbundling-rails で変数をカスタマイズする手順

```scss
// app/assets/stylesheets/application.bootstrap.scss

// (1) Bootstrap の関数を先に読み込み
@import "bootstrap/scss/functions";

// (2) 変数を好きな値で再定義
$primary: #0d947d;        // ブランドカラー
$font-size-base: 1.05rem; // 全体文字サイズ
$grid-breakpoints: (      // ブレークポイントを 480/768/1024…
  xs: 0,
  sm: 480px,
  md: 768px,
  lg: 1024px,
  xl: 1280px,
  xxl: 1536px
);

// (3) 変数・マップ・ミックスインを読み込み
@import "bootstrap/scss/variables";
@import "bootstrap/scss/variables-dark"; // v5.3 以降は自動で import されるが安全策
@import "bootstrap/scss/maps";
@import "bootstrap/scss/mixins";
@import "bootstrap/scss/root";

// (4) 必要なコンポーネント or 一括 import
@import "bootstrap/scss/bootstrap";
```

> 変更は保存→`bin/dev` の **dart-sass ウォッチ**で即ビルド、ページをリロードするだけです。

---

### 5. Sass 変数と **CSS カスタムプロパティ (`--bs-*`)** の違い

* Sass 変数は **ビルド時** に固定値へ展開される。
* CSS カスタムプロパティは **実行時** に参照でき、Dark Mode などで JS から値を差し替えられる。
* Bootstrap では多くの Sass 変数が同名の `--bs-*` でも出力されるため、\*\*「共通トークンを Sass で決め、ページごとに CSS 変数で動的に切替」\*\*というハイブリッドが可能。([getbootstrap.com][6])

---

### 6. まとめ & 実践ポイント

1. **全変数は `_variables.scss` に集約**されている。迷ったらまずここを検索。
2. 上書きは **`functions` 読み込み → 変数再定義 → `variables` 以降を import** の順序が鉄則。
3. 「色を増やしたい」「余白段階を増やしたい」なども **マップを `map-merge()`** すれば OK。
4. Rails では Docker コンテナ内で `bin/dev` を回しておけば、編集するたびに即反映。
5. 実行時にテーマを切り替えたい場合は、Sass 変数→CSS 変数に変換されているかを確認して `data-bs-theme` で操作する。

これで **「どの名前を触ればデザインが変わるのか」** が把握できるはずです。まずは `$primary` や `$font-size-base` を書き換えて、色と文字サイズを動かしてみると掴みやすいですよ。

[1]: https://getbootstrap.com/docs/5.3/customize/sass "Sass · Bootstrap v5.3"
[2]: https://getbootstrap.com/docs/5.3/customize/color/ "Color · Bootstrap v5.3"
[3]: https://getbootstrap.com/docs/5.3/layout/breakpoints "Breakpoints · Bootstrap v5.3"
[4]: https://getbootstrap.com/docs/5.3/utilities/spacing/ "Spacing · Bootstrap v5.3"
[5]: https://getbootstrap.com/docs/4.0/content/typography/ "Typography · Bootstrap"
[6]: https://getbootstrap.com/docs/5.3/customize/css-variables/ "CSS variables · Bootstrap v5.3"
  
<br>
<br>

## コンポーネント（Components）

### コンポーネント（Components）とは？

Bootstrap では **「UI 部品を“ひとかたまり”で再利用できるようにしたテンプレート」** をコンポーネントと呼びます。

* ボタンなら `.btn`, カードなら `.card` といった **ベースクラス**に、`.btn-primary` や `.card-header` など **モディファイアクラス**を重ねてバリエーションを切り替える “base-modifier” 方式で設計されています。([getbootstrap.com][1])
* 見た目だけで完結するもの（Badge など）は **CSS だけ**、動きが必要なもの（Modal, Toast など）は **JavaScript プラグイン**が同梱されており、`import { Modal } from "bootstrap"` のように ESM で呼び出します。([getbootstrap.com][2])

> **最新安定版は v5.3.7（2025-06-17 リリース）** です。([blog.getbootstrap.com][3], [getbootstrap.com][4])

---

### 主なコンポーネント一覧（頻出順・ざっくり分類）

| カテゴリ        | 代表コンポーネント                                  | 簡易説明                                                                                                      |
| ----------- | ------------------------------------------ | --------------------------------------------------------------------------------------------------------- |
| **表示・カード類** | Card, List Group, Badge, Alert             | 1枚の枠やリストなど。カードはヘッダ・フッタや画像も含む多目的コンテナ。([getbootstrap.com][5], [getbootstrap.com][6], [getbootstrap.com][7]) |
| **ナビゲーション** | Navbar, Breadcrumb, Pagination, Tabs       | 画面遷移を助けるヘッダ・パンくず・ページャ等。Navbar は collapsible でモバイル対応。([getbootstrap.com][8])                               |
| **フォーム関連**  | Form Controls, Input Group, Floating Label | 入力欄・ラベル・補助テキストを一括整形。                                                                                      |
| **レイアウト補助** | Accordion, Collapse, Carousel              | 折りたたみ・スライダーなど動きを伴う UI。([getbootstrap.com][9])                                                             |
| **オーバーレイ**  | Modal, Offcanvas, Tooltip, Popover, Toast  | 画面上に重ねて表示。Modal はダイアログ、Toast は通知。([getbootstrap.com][10], [getbootstrap.com][11])                         |

> 公式ドキュメントは `/components/◯◯/` 以下に個別のサンプルと API を掲載しています。

---

### Rails 8 + Hotwire での実装手順（Importmap 構成）

1. **JS をピン**

   ```ruby
   # config/importmap.rb
   pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@5.3.7/dist/js/bootstrap.esm.js"
   pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.8/dist/esm/index.js"
   ```

2. **SCSS で必要な部品だけを読み込む**

   ```scss
   // application.bootstrap.scss
   @import "bootstrap/scss/functions"; // 必須

   // ここで $primary など変数を上書き可

   @import "bootstrap/scss/variables";
   @import "bootstrap/scss/mixins";
   // ↓最小構成なら、カードとトーストだけ等 Lean import が推奨
   //   @import "bootstrap/scss/card";
   //   @import "bootstrap/scss/toast";
   // 一括なら
   @import "bootstrap/scss/bootstrap";
   ```

   *不要コンポーネントを外すとビルドサイズを大幅に削減できます* ([getbootstrap.com][12])

3. **Stimulus で JS プラグインを初期化**

   ```js
   // controllers/auto_toast_controller.js
   import { Controller } from "@hotwired/stimulus";
   import { Toast } from "bootstrap";

   export default class extends Controller {
     connect() {
       new Toast(this.element).show();
     }
   }
   ```

   ビュー側

   ```erb
   <div data-controller="auto-toast"
        class="toast position-fixed bottom-0 end-0 m-3"
        role="alert" data-bs-delay="2000">
     <div class="toast-body">保存しました</div>
   </div>
   ```

   これで **右下に 2 秒だけフェードアウトする Toast** が表示でき、プロジェクト既定の「保存しました」通知パターンを再利用できます。([getbootstrap.com][11])

---

### カスタマイズの基本

1. **色・余白・丸みなどを Sass 変数で上書き**

   * 例：`$card-border-radius`, `$toast-max-width`, `$modal-fade-transform`…
2. **不要なコンポーネントは `@import` から削除**（Lean import）。
3. **ユーティリティ API** と組み合わせれば、`gap-x-3` など細かなレイアウト調整はクラスだけで完結。

---

### まとめ

* **コンポーネント = 完成 UI 部品**。ボタンからモーダルまで、HTML とクラス名だけで即利用。
* “base + modifier” 設計で色やサイズを簡単に切り替え、Sass 変数を先に再定義すればテーマ一括変更も可能。
* Rails 8 + Hotwire なら **Importmap + cssbundling-rails** だけで最新 Bootstrap (v5.3.7) をフル活用でき、Toast などの JS 部品も Stimulus 経由でスマートに初期化できます。

これで **「どの場面でどのコンポーネントを使うか／カスタムするか」** の全体像がつかめるはずです。まずはカードやトーストから試し、必要に応じて Lean import で最適化してみてください。

[1]: https://getbootstrap.com/docs/5.3/customize/components/?utm_source=chatgpt.com "Components · Bootstrap v5.3"
[2]: https://getbootstrap.com/docs/5.3/getting-started/javascript/?utm_source=chatgpt.com "JavaScript · Bootstrap v5.3"
[3]: https://blog.getbootstrap.com/2025/06/17/bootstrap-5-3-7/?utm_source=chatgpt.com "Bootstrap 5.3.7"
[4]: https://getbootstrap.com/docs/versions/?utm_source=chatgpt.com "Versions · Bootstrap v5.3"
[5]: https://getbootstrap.com/docs/5.3/components/card/?utm_source=chatgpt.com "Cards · Bootstrap v5.3"
[6]: https://getbootstrap.com/docs/5.3/components/list-group/?utm_source=chatgpt.com "List group · Bootstrap v5.3"
[7]: https://getbootstrap.com/docs/5.3/components/alerts/?utm_source=chatgpt.com "Alerts · Bootstrap v5.3"
[8]: https://getbootstrap.com/docs/5.3/components/navbar/?utm_source=chatgpt.com "Navbar · Bootstrap v5.3"
[9]: https://getbootstrap.com/docs/5.3/components/carousel/?utm_source=chatgpt.com "Carousel · Bootstrap v5.3"
[10]: https://getbootstrap.com/docs/5.3/components/modal/?utm_source=chatgpt.com "Modal · Bootstrap v5.3"
[11]: https://getbootstrap.com/docs/5.3/components/toasts/?utm_source=chatgpt.com "Toasts · Bootstrap v5.3"
[12]: https://getbootstrap.com/docs/5.3/customize/optimize/?utm_source=chatgpt.com "Optimize · Bootstrap v5.3"
  
<br>
<br>

## 独自クラス（custom class）

### 独自クラス（custom class）とは？

Bootstrap が提供する **“既製クラス”では表現し切れないデザインや振る舞いをまとめるために、開発者が自分で命名して定義する CSS クラス** のことです。

* **目的**：繰り返し使う UI パターンを 1 か所に集約して DRY に保つ／ユーティリティを何個も並べる可読性・保守性の低下を防ぐ。
* **位置づけ**：

  * *ユーティリティ* ＝ 1 宣言だけを瞬間的に付け足す“点投入”
  * *コンポーネント* ＝ Bootstrap 既製の完成 UI 部品
  * *独自クラス* ＝ **チームやプロジェクト専用の UI ルールをコード化**（色・余白・レスポンシブ挙動などをまとめた“自家製コンポーネント”）

---

### 1. こんなときに独自クラスを作る

| シチュエーション                                      | 独自クラス採用を推奨する理由                              |
| --------------------------------------------- | ------------------------------------------- |
| **同じ 3〜5 行のユーティリティを複数ファイルで再利用**               | HTML にユーティリティがずらっと並ぶと読みにくく、変更コストも増大         |
| **サイト固有のブランドパーツ（ヒーローバナー、専用ボタン等）**             | *`btn-primary`* では表現できない独自アニメーション・カラーパターンなど |
| **UI コンポーネントを Stimulus / ViewComponent で部品化** | クラス名をコンポーネント名と一致させると読みやすく、JS と連携しやすい        |
| **ユーザー／ダークモードで色を切り替えつつ Sass でも制御したい**         | CSS カスタムプロパティと Sass 変数のハイブリッド設計がしやすい        |

---

### 2. 作成手順（Rails 8 + Hotwire + cssbundling-rails）

1. **SCSS パーシャル用ディレクトリを用意**

   ```
   app/assets/stylesheets/project/
     _variables.project.scss   // プロジェクト固有変数
     _components.project.scss  // 独自コンポーネント
     _utilities.project.scss   // 必要なら独自ユーティリティ
   ```
2. **`application.bootstrap.scss` で読み込み順を調整**

   ```scss
   @import "bootstrap/scss/functions";

   // プロジェクト変数（Bootstrap 上書きもここで）
   @import "project/variables.project";

   // Bootstrap の変数・マップ・ミックスイン
   @import "bootstrap/scss/variables";
   @import "bootstrap/scss/mixins";

   // Bootstrap の核となるコンポーネント
   @import "bootstrap/scss/bootstrap";

   // 独自クラスを最後に（Bootstrap を安全に上書き）
   @import "project/components.project";
   ```

   > **ポイント**：独自クラスは *必ず Bootstrap の後* に読み込み→衝突時は自分が勝つ。

---

### 3. 命名ガイドライン

* **BEM 風（block\_\_element--modifier）** か **“役割＋機能”** を日本語でも良いが、*Bootstrap のプレフィックスと被らない*。

  * 例：`.hero-banner`, `.hero-banner--dark`, `.c-card--news`
* “見た目”ではなく**意味 / 役割**を名前にする。 `.red-box` ではなく `.alert-box`。
* **接頭辞**を決めておくと衝突を防げる

  * `p-` (project) / `c-` (component) / `o-` (object) など

---

### 4. 具体例：ヒーローバナーを独自クラスで作る

#### SCSS（`_components.project.scss`）

```scss
// プロジェクト変数を活用
$hero-height-sm: 280px;
$hero-height-lg: 420px;

.hero-banner {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  color: #fff;
  background: linear-gradient(
              rgba(0,0,0,.4),
              rgba(0,0,0,.4)
            ),
            url("/assets/hero.jpg") center/cover no-repeat;
  height: $hero-height-sm;

  // ブレークポイントは Bootstrap ミックスイン
  @include media-breakpoint-up(lg) {
    height: $hero-height-lg;
  }

  &__title {
    font-size: clamp(1.5rem, 4vw, 3rem);
    font-weight: 700;
  }

  &__cta {
    margin-top: 1rem;
  }
}
```

#### ビュー（`app/views/home/index.html.erb`）

```erb
<section class="hero-banner">
  <div>
    <h1 class="hero-banner__title">ようこそ！</h1>

    <!-- Bootstrap ユーティリティで余白と配置だけ微調整 -->
    <%= link_to "今すぐ登録",
                signup_path,
                class: "btn btn-lg btn-primary hero-banner__cta shadow-lg" %>
  </div>
</section>
```

* **レイアウト骨格**は独自クラスに、**単発調整**はユーティリティに割り振るのがコツ。
* Stimulus で `.hero-banner` にパララックス効果を付けたければ、同名コントローラを用意すれば OK。

---

### 5. 既存 Bootstrap コンポーネントのオーバーライド例

```scss
// ボタン全体の丸みを変更
.btn {
  border-radius: $btn-border-radius-lg; // Bootstrap 変数を再利用
}

// 影付きプライマリボタンを独自クラスで拡張
.btn-primary--elevated {
  @extend .btn, .btn-primary; // 既存を基に
  box-shadow: var(--bs-box-shadow-lg);
  transition: box-shadow .2s;

  &:hover {
    box-shadow: var(--bs-box-shadow);
  }
}
```

> 変更がプロジェクト全体に及ぶ場合は **変数の再定義**、
> 特定画面だけなら **独自クラスで上書き** と切り分けると事故が少ない。

---

### 6. Rails 視点でのベストプラクティス

1. **ViewComponent/Partial でマークアップを再利用**

   * クラス名と Ruby クラス名を合わせると追跡しやすい。
2. **ERB にユーティリティが 6 個以上並んだら独自クラス化を検討**。
3. **Tailwind 導入予定がない場合**でも、Utility-first 発想は Bootstrap ユーティリティ + 独自クラスで十分代替できる。
4. **テスト**：system テストで `.hero-banner` の存在や配色を Capybara で確認すると、デザイン崩れ発見が早い。

---

### まとめ

* **独自クラス = プロジェクト専用の再利用 UI ルール**。Bootstrap のユーティリティで賄いづらい“塊のデザイン”を担う。
* **読み込みは Bootstrap 後**、命名衝突を避け BEM 風で意味中心に。
* Rails 8 + Hotwire + cssbundling-rails では、パーシャル SCSS と ViewComponent を組み合わせると **“SCSS ↔ HTML ↔ Stimulus”** が一貫して管理しやすい。
* 「*一度書いたらどこからでも呼べる*」状態を目指し、ユーティリティ乱用で HTML が読めなくなる前に独自クラス化—これが実践的なバランスです。
