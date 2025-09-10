import { Controller } from "@hotwired/stimulus"
import { formToJSON } from "lib/serialize_form";

export default class extends Controller {

  static targets = ["list", "template", "row", "empty", "scroller"];
  static values = {
    basePath: String,      // "part[board_part_attributes][hole_json]"
    nextIndex: Number,      // サーバ側で初期化した次の番号
    scrollDuration: Number
  };

  get _scrollEl() { return this.hasScrollerTarget ? this.scrollerTarget : this.listTarget; }

  connect() {
    this._updateEmptyState();
    this.boardEl = document.querySelector('[data-controller~="board-part3d"]')
    this.boardPart3dCtrl = this.boardEl
      ? this.application.getControllerForElementAndIdentifier(this.boardEl, "board-part3d")
      : null
    this.form = this.element.closest("form") || document.forms[0]
    // 解除用にハンドラを束ねておく
    this._onChange = (e) => this._updateForm(e);
    this.form.addEventListener("change", this._onChange);
    this._onResize = () => {
      cancelAnimationFrame(this._rafId)
      this._rafId = requestAnimationFrame(() => this._resizeWork())
    }

    window.addEventListener("resize", this._onResize)
    this._resizeWork();
    this._initForm();
  }

  disconnect() {
    this.form?.removeEventListener("change", this._onChange)
    window.removeEventListener("resize", this._onResize)
    cancelAnimationFrame(this._rafId)
  }

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

    // 初期フォーカス
    root.querySelector(`input[name="${this.basePathValue}[${hid}][dx]"]`)?.focus();
    // ★ 一番下へスムーススクロール（次フレームで高さが確定してから）
    requestAnimationFrame(() => this._scrollToBottom());
  }

  remove(event) {
    const row = event.currentTarget.closest("[data-board-part-form-target='row']");
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

  _initForm() {
    const procNames = this._collectProcNames(this.form);
    for (const procName of procNames) {
      const rawPath = this._parseName(procName);
      const baseRaw = rawPath.slice(0, -1);
      const procEl = this._getElement(baseRaw, "proc");
      const procVal = procEl.value;
      const disable = (procVal === "NONE");
      this._changeDisabled(rawPath[2], baseRaw, "proc", disable);
    }
  }

  _updateForm(e){
    // ✨ 相手が未初期化の可能性に備える
    if (!this.boardPart3dCtrl && this.boardEl) {
      this.boardPart3dCtrl =
        this.application.getControllerForElementAndIdentifier(this.boardEl, "board-part3d");
    }
    const el = e.target;
    if (!el.name) return;
    let formJSON = formToJSON(this.form);
    const rawPath = this._parseName(el.name);
    const baseRaw = rawPath.slice(0, -1);
    const path = this._normalizePathForFoldAttributes(rawPath);
    const basePath = path.slice(0, -1);
    if (path.at(-1) === "disp") {
      const dispVal = this._getAtPath(formJSON, [...basePath, "disp"]);
      this.boardPart3dCtrl?.setMeshVisibilityAtPath?.(path.slice(2, 4), dispVal);
      return;
    }
    const type = path[2];
    switch(type) {
      case "corner_json":
        {
          const procVal = this._getAtPath(formJSON, [...basePath, "proc"]);
          const disable = (procVal === "NONE");
          this._changeDisabled(type, baseRaw, path.at(-1), disable);
          // formJSON更新
          formJSON = formToJSON(this.form);
          const dxVal = this._getAtPath(formJSON, [...basePath, "dx"]);
          const dyVal = this._getAtPath(formJSON, [...basePath, "dy"]);
          if (procVal !== "NONE" && (!dxVal || !dyVal)) return;
        }
        break;
      case "side_json":
        {
          const procVal = this._getAtPath(formJSON, [...basePath, "proc"]);
          const disable = (procVal === "NONE");
          this._changeDisabled(type, baseRaw, path.at(-1), disable);
          // formJSON更新
          formJSON = formToJSON(this.form);
          const edgeVal = this._getAtPath(formJSON, [...basePath, "edge"]);
          const sdVal = this._getAtPath(formJSON, [...basePath, "sd"]);
          const swVal = this._getAtPath(formJSON, [...basePath, "sw"]);
          const spVal = this._getAtPath(formJSON, [...basePath, "sp"]);
          if ((procVal !== "NONE" && (!sdVal || !swVal || !spVal)) && (edgeVal === "NONE")) return;
        }
        break;
      case "hole_json":
        {
          const dxVal = this._getAtPath(formJSON, [...basePath, "dx"]);
          const dyVal = this._getAtPath(formJSON, [...basePath, "dy"]);
          const depthVal = this._getAtPath(formJSON, [...basePath, "depth"]);
          if (!dxVal || !dyVal ||!depthVal) return;
        }
        break;
      default:
    }
    this.boardPart3dCtrl?.updateModel?.(formJSON)
  }

  _changeDisabled(type, baseRaw, lastPath, disable) {
    switch(type) {
      case "corner_json":
        {
          if (lastPath === "proc") {
            const dxEl = this._getElement(baseRaw, "dx");
            dxEl.disabled = disable;
            const dyEl = this._getElement(baseRaw, "dy");
            dyEl.disabled = disable;
            const edgeEl = this._getElement(baseRaw, "edge");
            edgeEl.disabled = disable;
          }
        }
        break;
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

  _collectProcNames(form) {
    // [name$="[proc]"] … name 属性が "[proc]" で終わる要素を全部取得
    const els = form.querySelectorAll('[name$="[proc]"]');
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
}
