# SortableJS Tips

## SortableJS とは？

SortableJS は **「ドラッグ＆ドロップで並べ替え可能なリスト」を簡単に実装できる** 軽量 JavaScript ライブラリです。モダンブラウザとタッチデバイスに対応し、jQuery などの依存もありません。MIT ライセンスで公開されています。([github.com][1])

---

### 代表的な機能・できること

| 機能                  | 概要                                                                                                                         |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| 基本的なソート             | 同一リスト内で要素をドラッグして順序を変更できる                                                                                                   |
| **複数リスト間の移動**       | `group` オプションでリスト同士を関連付け、アイテムを別リストへドラッグ移動・コピー（クローン）                                                                        |
| **クローン（複製）**        | `pull: "clone"` で元リストを残したままコピーをドロップ                                                                                        |
| **グリッド・ネスト**        | フレックスや CSS グリッド上のカード／タイル、入れ子構造でも並べ替え可能                                                                                     |
| **ドラッグハンドル**        | `.handle` など任意セレクタを「つかみ所」として指定し、アイテム全体はクリック可能に保つ                                                                           |
| **フィルタ／無効化**        | 特定要素だけドラッグ対象外にしたり、動的にソートを enable/disable 切替                                                                                |
| **アニメーション**         | ドラッグ中・ドロップ後の要素の移動を CSS トランジションで滑らかに（`animation` オプション）                                                                     |
| **タッチ対応 & 自動スクロール** | スマホ／タブレットでの操作、リスト外へのドラッグ時に自動でスクロール                                                                                         |
| **イベントフック**         | `onStart`, `onEnd`, `onAdd`, `onUpdate`, `onSort` などでアプリ固有の処理を実装                                                           |
| **プラグイン**           | - **MultiDrag**（複数選択して一括ドラッグ）<br>- **Swap**（要素同士を入れ替え）<br>- **AutoScroll**（長いリストでスクロール補助） など                               |
| エコシステム              | Vue 用 **Vue.Draggable**、React／Angular／Svelte ラッパ、Laravel Livewire プラグインなどが公式・サードパーティで提供 ([github.com][2], [github.com][3]) |

---

### 最近のリリース状況

* **最新安定版**: **v1.15.6**（2024-11-28 リリース）([github.com][4])

  * iOS での Multi-Drag 選択バグ修正
  * フォールバック有効時のテキスト選択クリア挙動を改善　…など

2025 年 6 月時点でも活発にメンテナンスされており、バグフィックスやモバイル向け改善が継続しています。

---

### 使いどころの例

* **タスク管理アプリ**：Kanban ボードのカードの並べ替え・列間移動
* **CMS／管理画面**：記事やメニュー項目の順序変更
* **E-コマース**：商品画像やオプションのドラッグ編集
* **フォームビルダー**：フォーム要素をドラッグで配置・並べ替え

---

### まとめ

SortableJS は「**シンプルに始められて、必要に応じて高度な挙動を拡張できる**」のが強みです。次のステップとしては、実際に `npm i sortablejs` で導入し、リスト要素に `Sortable.create()` を適用してみると感覚がつかめますよ。

[1]: https://github.com/SortableJS/Sortable?utm_source=chatgpt.com "SortableJS/Sortable: Reorderable drag-and-drop lists for ... - GitHub"
[2]: https://github.com/SortableJS/Vue.Draggable?utm_source=chatgpt.com "SortableJS/Vue.Draggable: Vue drag-and-drop component ... - GitHub"
[3]: https://github.com/wotzebra/livewire-sortablejs?utm_source=chatgpt.com "A Laravel Livewire plugin that makes it easy to use Sortable.js - GitHub"
[4]: https://github.com/SortableJS/Sortable/releases "Releases · SortableJS/Sortable · GitHub"
  
  <br>
  <br>

## イベント

### SortableJS が発火する主なイベント一覧

#### 1. コア（本体）イベント

Sortable の `options` オブジェクトにコールバックを渡すと、ドラッグ操作のライフサイクルに応じて順番に発火します。([github.com][1])

| 発火タイミング                   | コールバック名        | 主な用途・備考               |
| ------------------------- | -------------- | --------------------- |
| 要素をクリックして「掴んだ」瞬間          | **onChoose**   | ドラッグ開始前にハイライトしたいときなど  |
| 掴みを解除した瞬間                 | **onUnchoose** | onChoose とセットで使う      |
| ドラッグが開始された瞬間              | **onStart**    | スクロール抑制・カウントダウン開始など   |
| ドラッグ終了時（移動先が確定）           | **onEnd**      | 並び順を保存・トースト表示など       |
| 他リストから要素が追加された            | **onAdd**      | Kanban で「列をまたいだ移動」を検知 |
| 同一リスト内で並び替えが起きた           | **onUpdate**   | position の再計算／DB 保存   |
| 追加・更新・削除いずれかが完了           | **onSort**     | 変化を一括ハンドリングしたい場合      |
| 要素が別リストへ “搬出” された         | **onRemove**   | 元リストから消えたことを検知        |
| `filter` で除外された要素がクリックされた | **onFilter**   | カスタム UI（削除ボタンなど）      |
| 挿入候補を毎フレーム判定する            | **onMove**     | ドロップ位置の動的バリデーション      |
| クローン要素を生成した直後             | **onClone**    | 複製元・先でスタイルを差し替えたいとき   |
| ドラッグ中にインデックスが変わった         | **onChange**   | “途中位置” をプレビュー保存したいとき  |

> **発火順（代表例）**
> `onChoose → onStart → (onMove | onChange) … → onAdd / onUpdate / onRemove → onEnd → onSort`

#### 2. プラグイン固有イベント

| プラグイン         | イベント                          | 目的                             |
| ------------- | ----------------------------- | ------------------------------ |
| **MultiDrag** | **onSelect** / **onDeselect** | 複数選択状態の変化を検知 ([github.com][2]) |

（Swap プラグインはコアイベント内で完結するため独自イベントはありません）

#### 3. Event オブジェクトで取れる代表的プロパティ

各コールバックに渡される `evt` には下記のような情報が入っています。([github.com][1])

```text
evt.item      // 対象 HTMLELement
evt.to        // 移動先リスト
evt.from      // 元リスト
evt.oldIndex  // 旧インデックス（親要素基準）
evt.newIndex  // 新インデックス
evt.clone     // クローン要素（pull:"clone" 時）
evt.pullMode  // "clone" / true / false
// onMove のみ
evt.draggedRect   // ドラッグ中要素の DOMRect
evt.related       // ホバー中の要素
evt.willInsertAfter // true=後ろに挿入予定
```

#### 4. 使い方サンプル（Stimulus + Importmap）

```javascript
import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

export default class extends Controller {
  connect () {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      onEnd:  (evt) => this.saveOrder(evt),
      onFilter: (evt) => evt.item.remove(),  // 例: ごみ箱ボタンを押したら削除
    });
  }

  async saveOrder(evt) {
    const ids = Array.from(this.element.children).map(el => el.dataset.id);
    await fetch("/tasks/sort", { /* ... */ });
  }
}
```

---

#### まとめ

* **コア 12 種**＋**プラグイン固有**（MultiDrag のみ onSelect/onDeselect）が基本セット。
* ほぼすべての操作は `onEnd` または `onSort` で後処理すれば OK。
* インデックスやリスト情報は `evt` から取得できるので、DB への永続化・アニメーション制御・アクセスログなど用途に合わせて活用してください。

[1]: https://github.com/SortableJS/Sortable "GitHub - SortableJS/Sortable: Reorderable drag-and-drop lists for modern browsers and touch devices. No jQuery or framework required."
[2]: https://github.com/SortableJS/Sortable/wiki/Dragging-Multiple-Items-in-Sortable "Dragging Multiple Items in Sortable · SortableJS/Sortable Wiki · GitHub"
  
  <br>
  <br>

## コンストラクタ

### `Sortable.create(要素, options)` の全体像

| 引数          | 型             | 必須 | 役割                         |
| ----------- | ------------- | -- | -------------------------- |
| **要素**      | `HTMLElement` | ✔︎ | 並べ替え対象リスト（コンテナ）を示す DOM ノード |
| **options** | `Object`      | ─  | 挙動・見た目・イベントを細かく制御する設定      |

> ※ `Sortable.create(el, …)` は内部的に `new Sortable(el, …)` を呼び出しており、戻り値は **`Sortable` インスタンス**。インスタンスメソッド `option() / toArray() / sort() / destroy()` などを後から呼べます。

---

### options でよく使う主なキー

| カテゴリ         | 主なオプション                                                  | デフォルト / 例                        | 説明                                                      |
| ------------ | -------------------------------------------------------- | -------------------------------- | ------------------------------------------------------- |
| **基本挙動**     | `group`                                                  | `"name"` / `{ name, pull, put }` | 他リストとの連携・コピー可否を定義 ([npmjs.com][1])                      |
|              | `sort`                                                   | `true`                           | 同一リスト内の並べ替えを許可 ([npmjs.com][1])                         |
|              | `disabled`                                               | `false`                          | `true` でドラッグ完全無効化 ([npmjs.com][1])                      |
|              | `animation`                                              | `150` (ms)                       | 移動時の CSS アニメーション時間 ([npmjs.com][1])                     |
| **ドラッグ対象**   | `draggable`                                              | `'li' / '.item'`                 | 子要素のうちドラッグできるセレクタ ([gist.github.com][2])                |
|              | `handle`                                                 | `'.handle'`                      | ここを掴んだ時だけドラッグ開始 ([npmjs.com][1])                        |
|              | `filter`                                                 | `'.ignore'` / 関数                 | ここに当たる要素はドラッグ不可 ([npmjs.com][1])                        |
|              | `dataIdAttr`                                             | `'data-id'`                      | `toArray()` が使う属性名 ([gist.github.com][2])               |
| **クラス名カスタム** | `ghostClass` / `chosenClass` / `dragClass` / `swapClass` | `'sortable-ghost'` など            | ドラッグ中・候補表示用クラスを上書き ([gist.github.com][2])               |
| **スクロール**    | `scroll`                                                 | `true` / `HTMLElement`           | 自動スクロール対象を指定 ([gist.github.com][2])                     |
|              | `scrollSensitivity` / `scrollSpeed`                      | `30` / `10`                      | マウス縁寄せ時の反応距離・速度 ([gist.github.com][2])                  |
| **ローカル永続化**  | `store`                                                  | `{ get, set }`                   | `get()` で初期化、`set()` は並べ替え毎に自動呼出 ([gist.github.com][2]) |
| **遅延・モバイル**  | `delay`, `delayOnTouchOnly`, `touchStartThreshold`       | ―                                | 長押し開始・端末依存しきい値                                          |
| **プラグイン**    | `multiDrag`, `selectedClass` ほか                          | ―                                | MultiDrag/SWAP など追加機能用                                  |

---

### 登録できるイベントコールバック

```
onChoose → onStart → (onMove/onChange) … → onAdd / onUpdate / onRemove → onEnd → onSort
```

`onAdd / onUpdate / onRemove / onEnd / onSort / onFilter / onClone / onChange …`
など **12 以上のライフサイクルイベント**があり、
`evt.item`, `evt.from`, `evt.to`, `evt.oldIndex`, `evt.newIndex` などを受け取れます。([gist.github.com][2]) ([npmjs.com][1])

---

### ミニマム実装例

```javascript
import Sortable from "sortablejs";

const list = document.querySelector("#tasks");

Sortable.create(list, {
  group: { name: "tasks", pull: true, put: true },
  animation: 150,
  handle: ".handle",
  ghostClass: "drag-ghost",

  store: {
    set: s => localStorage.setItem("order", s.toArray().join("|")),
    get: s => (localStorage.getItem("order") || "").split("|")
  },

  onEnd: ({ to }) => {
    console.log("新順序:", Sortable.get(to).toArray());
  }
});
```

---

### まとめ

1. **第1引数**で「どの要素を並べ替えるか」を指定。
2. \*\*第2引数（options）\*\*で **挙動・見た目・イベント**を細かく設定。
3. 返り値のインスタンスで `option()`, `toArray()`, `sort()`, `destroy()` などの API が利用可能。

まずは `animation`, `handle` など最低限を試し、必要に応じて `group` や `store`, 各イベントを追加していくと実装がスムーズです。

[1]: https://npmjs.com/package/sortablejs/v/1.2.0 "sortablejs - npm"
[2]: https://gist.github.com/superjodash/ea84934797ff1cc91a7a "Sortable with cancel · GitHub"
  
  <br>
  <br>

## インスタンス

## Sortable インスタンスが持つ主なメソッドとプロパティ

| メソッド / プロパティ                   | 役割                                                            | 典型的な使い所                                                 |
| ------------------------------ | ------------------------------------------------------------- | ------------------------------------------------------- |
| **`el`** *(HTMLElement)*       | 対象コンテナそのもの（read-only）                                         | 直接 DOM 操作したいときに使える                                      |
| **`options`** *(Object)*       | 生成時に渡したオプションを保持                                               | 現在設定を丸ごと参照したい場合                                         |
| **`toArray()`**                | `dataIdAttr` に格納した ID を**現在の並び順で配列**に変換                       | 並べ替え結果を DB へ保存するときによく使う ([gist.github.com][1])          |
| **`sort(array[, silent])`**    | 渡した ID 配列通りに **DOM を並べ替え**。`silent=true` ならイベントを発火しない         | ロード時にサーバ側で保持していた順序を復元する ([gist.github.com][1])          |
| **`save()`**                   | `options.store.set(this)` を呼び出し、**ローカル永続化**（例：`localStorage`） | `store` オプションを設定した場合は、自動保存を任せられる ([gist.github.com][1]) |
| **`option(name [, value])`**   | オプションの **getter / setter**。値を渡せば書き換え、未指定なら取得                  | 動的に `disabled` 切替・`group` 変更など ([gist.github.com][1])   |
| **`closest(el [, selector])`** | 指定要素から selector に最も近い祖先（含自分）を取得                               | 独自バリデーションやハンドル位置の判定 ([gist.github.com][1])              |
| **`destroy()`**                | 追加したイベントリスナ／`draggable` 属性を外し、インスタンスを **完全に破棄**               | Turbo で動的に箇所を差し替える前のクリーンアップ ([gist.github.com][1])      |

> 返り値はすべて **`Sortable` インスタンス**なのでチェーンは不可。必要なら適宜変数へ受け取ってください。

### インスタンス取得・プラグイン周り（静的 API との補足）

| 静的メンバー                                | 説明                                 |
| ------------------------------------- | ---------------------------------- |
| `Sortable.create(el, options)`        | `new Sortable(el, options)` のエイリアス |
| `Sortable.get(el)`                    | 指定コンテナに紐づく **既存インスタンス**を返す         |
| `Sortable.mount(pluginA, pluginB, …)` | マウントしたプラグインは **すべての新規インスタンス**で有効に  |

### 使い分けイメージ

```js
// 生成
const sortable = Sortable.create(list, { animation: 150 });

// 並び順を保存（onEnd 内など）
fetch('/tasks/sort', {
  method: 'PATCH',
  body: JSON.stringify({ ids: sortable.toArray() })
});

// 一時的にドラッグを禁止
sortable.option('disabled', true);

// 後で復元
sortable.sort(savedOrderArray, true);  // silent = true でイベント抑制

// ページ遷移前にクリーンアップ
sortable.destroy();
```

SortableJS は **UI の並べ替えとイベント通知までを担当**し、
「並び順データの保存」や「アプリ固有の副作用」は上記メソッドを組み合わせて実装する、という責務分担になります。これらの API を押さえておけば、Rails + Hotwire 環境でも柔軟に制御できます。

[1]: https://gist.github.com/grype/32a12b9c85013a0b316564636dba7b51 "Sortable.js · GitHub"
