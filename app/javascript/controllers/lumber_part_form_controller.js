import { Controller } from "@hotwired/stimulus"
import { formToJSON } from "lib/serialize_form";

export default class extends Controller {

  static targets = ["list", "template", "row", "empty", "scroller", "type", "color", "gloss", "finish"];
  static values = {
    basePath: String,      // "part[lumber_part_attributes][hole_json]"
    nextIndex: Number,      // サーバ側で初期化した次の番号
    scrollDuration: Number,
    colors: Array,   // [{code, name, sort, allow:{ ... }}]
    glosses: Array,
    finishes: Array
  };

  get _scrollEl() { return this.hasScrollerTarget ? this.scrollerTarget : this.listTarget; }

  connect() {
    this._updateEmptyState();
    this.onTypeChange();
    this.lumberEl = document.querySelector('[data-controller~="lumber-part3d"]')
    this.lumberPart3dCtrl = this.lumberEl
      ? this.application.getControllerForElementAndIdentifier(this.lumberEl, "lumber-part3d")
      : null
    this.form = this.element.closest("form") || document.forms[0]
    // 解除用にハンドラを束ねておく
    this._onChange = (e) => this._updateForm(e);
    this.form.addEventListener("change", this._onChange);
    this._onResize = () => {
      cancelAnimationFrame(this._rafId)
      this._rafId = requestAnimationFrame(() => this._resizeWork())
    }
    this._onSubmit = (e) => this._handleSubmit(e);           // 参照を保持
    this.form.addEventListener("submit", this._onSubmit, { once: true }); // 一度だけ

    window.addEventListener("resize", this._onResize)
    this._resizeWork();
    this._initForm();
  }

  disconnect() {
    this.form?.removeEventListener("change", this._onChange)
    this.form?.removeEventListener("submit", this._onSubmit);
    window.removeEventListener("resize", this._onResize)
    cancelAnimationFrame(this._rafId)
  }

  _handleSubmit = async (e) => {
    e.preventDefault();

    // 3Dからサムネを Blob で取得（なければそのまま送る）
    const blob = await this.lumberPart3dCtrl?.captureBlob?.({ maxWidth: 640, quality: 0.85, mime: "image/jpeg" });

    if (blob) {
      // Blob → File にして hidden の file input に入れる
      const ext = (blob.type.split("/")[1] || "jpg");
      const file = new File([blob], `thumbnail.${ext}`, { type: blob.type });

      const input = this.form.querySelector("#thumbnail_file");
      if (input) {
        try {
          const dt = new DataTransfer();    // FileList を作る
          dt.items.add(file);
          input.files = dt.files;           // ← ここでファイルを「選択」状態にできる
        } catch (err) {
          console.warn("DataTransfer 代入に失敗。fallbackを検討:", err);
        }
      }
    }

    // 再送信（once:true なのでループしない）
    setTimeout(() => {
      this.form.requestSubmit();
    }, 0);
  };

  // ネジ・ダボ穴追加
  add() {
    const n = this._nextNumber();
    const hid = `h${n}`;
    const frag = this.templateTarget.content.cloneNode(true);
    const root = frag.firstElementChild;
    root.innerHTML = root.innerHTML
      .replaceAll("__HID__", hid)
      .replaceAll("__HNUM__", String(n));
    // ← root 自身の data-hid は明示的に更新
    root.dataset.hid = hid;
    this.listTarget.appendChild(root);
    this.nextIndexValue = n + 1;

    // 1件増えたので空表示を消す
    this._updateEmptyState();

    // ★ 一番下へスムーススクロール（次フレームで高さが確定してから）
    requestAnimationFrame(() => this._scrollToBottom());
    // 初期フォーカス
    //root.querySelector(`input[name="${this.basePathValue}[${hid}][dx]"]`)?.focus();
  }

  // ネジ・ダボ穴削除
  remove(event) {
    const row = event.currentTarget.closest("[data-lumber-part-form-target='row']");
    if (!row) return;

    // 1) いまの高さをpxで固定（auto→数値へ）
    const h = row.offsetHeight; // padding/border込み
    row.style.height = `${h}px`;
    row.style.boxSizing = 'border-box'; // 念のため

    // 2) リフローを挟んでトランジション開始
    //    （reflow: heightを確定させる）
    void row.offsetHeight;

    // 3) 収縮クラスを付与（CSS側で height:0 等へ遷移）
    row.classList.add('row-collapsing');

    // 4) 終了イベントでDOMから削除
    const onEnd = (e) => {
      if (e.propertyName !== 'height') return; // heightの遷移だけ拾う
      row.removeEventListener('transitionend', onEnd);
      row.remove();
      this._updateEmptyState?.();
    };
    row.addEventListener('transitionend', onEnd);

    // 5) 念のためのフォールバック（環境依存でtransitionendが来ない時）
    setTimeout(() => {
      if (row.isConnected) {
        row.removeEventListener('transitionend', onEnd);
        row.remove();
        this._updateEmptyState?.();
      }
    }, 600); // transition合計より少し長め
  }

  // 塗装タイプセレクトボックス変更イベント
  onTypeChange() {
    const typeCode = this.typeTarget.value || null;
    this._rebuildSelect(this.colorTarget, this.colorsValue, typeCode);
    this._rebuildSelect(this.glossTarget, this.glossesValue, typeCode);
    this._rebuildSelect(this.finishTarget, this.finishesValue, typeCode);
  }

  _initForm() {
    const surfaceNames = this._collectSurfaceNames(this.form);
    for (const surfaceName of surfaceNames) {
      const rawPath = this._parseName(surfaceName);
      const baseRaw = rawPath.slice(0, -1);
      const surfaceEl = this._getElement(baseRaw, "surface");
      const surfaceVal = surfaceEl.value;
      this._changeDisabled(rawPath[2], baseRaw, "surface", true, surfaceVal);
    }
    if (!this.lumberPart3dCtrl && this.lumberEl) {
      this.lumberPart3dCtrl =
        this.application.getControllerForElementAndIdentifier(this.lumberEl, "lumber-part3d");
    }
    const formJSON = formToJSON(this.form);
    this.lumberPart3dCtrl?.updateModel?.(formJSON)
  }

  _updateForm(e){
    // ✨ 相手が未初期化の可能性に備える
    if (!this.lumberPart3dCtrl && this.lumberEl) {
      this.lumberPart3dCtrl =
        this.application.getControllerForElementAndIdentifier(this.lumberEl, "lumber-part3d");
    }
    const el = e.target;
    if (!el.name) return;

    let formJSON = formToJSON(this.form);
    const rawPath = this._parseName(el.name);
    const baseRaw = rawPath.slice(0, -1);
    const path = this._normalizePathForFoldAttributes(rawPath);
    const basePath = path.slice(0, -1);
    const ignoreList = ["material_code", "paint_type_code", "paint_color_code", "paint_gloss_code", "name", "note"];
    if (ignoreList.includes(path.at(-1))){
      return;
    } else if (path.at(-1) === "disp") {
      const dispVal = this._getAtPath(formJSON, [...basePath, "disp"]);
      console.log("dispVal:", dispVal)
      this.lumberPart3dCtrl?.setMeshVisibilityAtPath?.(path.slice(2, 4), dispVal);
      return;
    }
    const type = path[2];
    switch(type) {
      case "hole_json":
        {
          const surfaceVal = this._getAtPath(formJSON, [...basePath, "surface"]);
          const dxVal = this._getAtPath(formJSON, [...basePath, "dx"]);
          const dyVal = this._getAtPath(formJSON, [...basePath, "dy"]);
          const depthVal = this._getAtPath(formJSON, [...basePath, "depth"]);
          this._changeDisabled(type, baseRaw, path.at(-1), true, surfaceVal);
          if (surfaceVal === "FRONT" || surfaceVal === "BACK") {
            if (!dxVal || !dyVal ||!depthVal) return;
          } else if (surfaceVal === "LEFT" || surfaceVal === "RIGHT") {
            if (!dyVal ||!depthVal) return;
          } else if (surfaceVal === "TOP" || surfaceVal === "BOTTOM") {
            if (!dxVal ||!depthVal) return;
          }
        }
        break;
      default:
    }
    this.lumberPart3dCtrl?.updateModel?.(formJSON)
  }

  _changeDisabled(type, baseRaw, lastPath, disable, val = null) {
    switch(type) {
      case "side_json":
        {
          if (lastPath === "proc") {
            const sdEl = this._getElement(baseRaw, "sd");
            sdEl.disabled = disable;
            const swEl = this._getElement(baseRaw, "sw");
            swEl.disabled = disable;
            const spEl = this._getElement(baseRaw, "sp");
            spEl.disabled = disable;
          }
        }
        break;
      case "hole_json":
        {
          if (lastPath === "surface") {
            const dxEl = this._getElement(baseRaw, "dx");
            const dyEl = this._getElement(baseRaw, "dy");
            if (val === "FRONT" || val === "BACK") {
              dxEl.disabled = false;
              dyEl.disabled = false;
            } else if (val === "LEFT" || val === "RIGHT") {
              dxEl.disabled = true;
              dyEl.disabled = false;
            } else if (val === "TOP" || val === "BOTTOM") {
              dxEl.disabled = false;
              dyEl.disabled = true;
            }
          }
        }
        break;
      default:
    }
  }

  _resizeWork() {
    // 実際のサイズ調整ロジック（例：高さ=50dvh−Header−Bottom）
    const header = document.querySelector(".MainHeader")
    const bottom = document.querySelector(".BottomBar")
    const canvas = document.querySelector(".square-half")

    const headerH =
      header && getComputedStyle(header).display !== "none"
        ? header.getBoundingClientRect().height
        : 0
    const bottomH =
      bottom && getComputedStyle(bottom).display !== "none"
        ? bottom.getBoundingClientRect().height
        : 0
    const canvasH =
      canvas && getComputedStyle(canvas).display !== "none"
        ? canvas.getBoundingClientRect().height
        : 0
    const targetH = Math.max(0, Math.round(window.innerHeight - canvasH - headerH - bottomH -10))
    document.querySelectorAll(".carousel-row").forEach(el => {
      el.style.height = `${targetH}px`
    })
  }

  _getElement(baseRaw, name){
    const elName = this._buildNameFromPath([...baseRaw, name]);
    let el = this.form?.elements?.namedItem(elName);
    if (!el) {
      const sel = `[name="${CSS.escape(elName)}"]`;
      el = this.form?.querySelector(sel);
    }
    return el;
  }

  _parseName(name) {
    return name.match(/^[^\[]+|\[(.*?)\]/g).map(s => s[0] === "[" ? s.slice(1, -1) : s);
  }

  _buildNameFromPath(path) {
    return path.reduce((acc, key, i) => {
      return acc + (i === 0 ? key : `[${key}]`);
    }, "");
  }
  _normalizePathForFoldAttributes(path) {
    return path.map((k) => k.endsWith("_attributes") ? k.slice(0, -"_attributes".length) : k);
  }

  _getAtPath(obj, path) {
    return path.reduce((cur, k) => cur?.[k], obj);
  }

  _collectSurfaceNames(form) {
     const els = form.querySelectorAll('[name$="[surface]"]');
    // name を配列で返す（重複はユニーク化）
    return [...new Set([...els].map(el => el.name))];
  }

  // ===== スクロール系ヘルパ =====
  _scrollToBottom() {
    const padding = 170;
    const el = this._scrollEl;
    const to = el.scrollHeight - el.clientHeight - padding;
    this._smoothScroll(el, Math.max(0, to));
  }

  _smoothScroll(el, top) {
    // 1) モダンブラウザ：ネイティブ smooth
    try {
      el.scrollTo({ top, behavior: "smooth" });
      return;
    } catch (_) { /* fallthrough */ }

    // 2) フォールバック：requestAnimationFrame で自前アニメ
    const start = el.scrollTop;
    const dist  = top - start;
    const dur   = this.hasScrollDurationValue ? this.scrollDurationValue : 300;
    if (dur <= 0 || Math.abs(dist) < 1) { el.scrollTop = top; return; }

    const ease = t => (t < .5 ? 4*t*t*t : 1 - Math.pow(-2*t + 2, 3)/2); // easeInOutCubic
    const t0 = performance.now();
    const tick = now => {
      const p = Math.min(1, (now - t0) / dur);
      el.scrollTop = start + dist * ease(p);
      if (p < 1) requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  }

  _nextNumber() {
    let max = 0;
    this.rowTargets.forEach(r => {
      const m = String(r.dataset.hid || "").match(/\d+/);
      if (m) max = Math.max(max, parseInt(m[0], 10));
    });
    return Math.max(max + 1, this.nextIndexValue || 1);
  }

  _updateEmptyState() {
    if (!this.hasEmptyTarget) return;
    this.emptyTarget.classList.toggle("d-none", this.rowTargets.length > 0);
  }

  // 塗装系セレクトボックス書き換え
  _rebuildSelect(selectEl, allItems, typeCode) {
    const prev = selectEl.value;

    // 許可フィルタ（allow[typeCode] が true のものだけ）
    let items = [];
    if (typeCode) {
      items = allItems.filter(i => i.allow && i.allow[typeCode]);
    }

    // 並び順: sort_order => name
    items.sort((a, b) => {
      if ((a.sort ?? 0) !== (b.sort ?? 0)) return (a.sort ?? 0) - (b.sort ?? 0);
      return (a.name || "").localeCompare(b.name || ""); // 日本語でもそこそこ自然
    });

    // 一旦クリア
    while (selectEl.options.length) selectEl.remove(0);

    // 先頭にプレースホルダ
    const ph = document.createElement("option");
    ph.value = "";
    ph.textContent = typeCode ? `選択...` : "先に塗装タイプを選択してください";
    selectEl.appendChild(ph);

    // 候補を追加
    for (const i of items) {
      const opt = document.createElement("option");
      opt.value = i.code;
      opt.textContent = i.name;
      selectEl.appendChild(opt);
    }

    // 既存値（data-current-value）を優先、なければ直前値
    const desired = selectEl.dataset.currentValue || prev;
    if (desired && items.some(i => i.code === desired)) {
      selectEl.value = desired;
    } else {
      selectEl.value = "";
    }
    // 一度使ったら邪魔しないように消しておく
    delete selectEl.dataset.currentValue;

    // 有効/無効
    selectEl.disabled = items.length === 0 || !typeCode;

    // 連動先の変更イベントを発火（必要に応じて）
    selectEl.dispatchEvent(new Event("change", { bubbles: true }));
  }
}