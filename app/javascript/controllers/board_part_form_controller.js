import { Controller } from "@hotwired/stimulus"
import { formToJSON } from "lib/serialize_form";

export default class extends Controller {
  connect() {
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

  _initForm() {
    const procNames = this._collectProcNames(this.form);
    for (const procName of procNames) {
      const rawPath = this._parseName(procName);
      const baseRaw = rawPath.slice(0, -1);
      const procEl = this._getElement(baseRaw, "proc");
      const procVal = procEl.value;
      const disable = (procVal === "NONE");
      switch(rawPath[2]) {
        case "corner_json":
          {
            const dxEl = this._getElement(baseRaw, "dx");
            dxEl.disabled = disable;
            const dyEl = this._getElement(baseRaw, "dy");
            dyEl.disabled = disable;
            const edgeEl = this._getElement(baseRaw, "edge");
            edgeEl.disabled = disable;
          }
          break;
        case "side_json":
          {
            const sdEl = this._getElement(baseRaw, "sd");
            sdEl.disabled = disable;
            const swEl = this._getElement(baseRaw, "sw");
            swEl.disabled = disable;
            const spEl = this._getElement(baseRaw, "sp");
            spEl.disabled = disable;
          }
          break;
          default:
      }
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
    const path = this._normalizePathForFoldAttributes(rawPath);
    const basePath = path.slice(0, -1);
    if (path.at(-1) === "disp") {
      const dispVal = this._getAtPath(formJSON, [...basePath, "disp"]);
      this.boardPart3dCtrl?.setMeshVisibilityAtPath?.(path.slice(2, 4), dispVal);
      return;
    }
    const type = path[2];
    const procVal = this._getAtPath(formJSON, [...basePath, "proc"]);
    const baseRaw = rawPath.slice(0, -1);
    const disable = (procVal === "NONE");
    switch(type) {
      case "corner_json":
        {
          if (path.at(-1) === "proc") {
            const dxEl = this._getElement(baseRaw, "dx");
            dxEl.disabled = disable;
            const dyEl = this._getElement(baseRaw, "dy");
            dyEl.disabled = disable;
            const edgeEl = this._getElement(baseRaw, "edge");
            edgeEl.disabled = disable;
          }
          // formJSON更新
          formJSON = formToJSON(this.form);
          const dxVal = this._getAtPath(formJSON, [...basePath, "dx"]);
          const dyVal = this._getAtPath(formJSON, [...basePath, "dy"]);
          if (procVal !== "NONE" && (!dxVal || !dyVal)) return;
        }
        break;
      case "side_json":
        {
          if (path.at(-1) === "proc") {
            const sdEl = this._getElement(baseRaw, "sd");
            sdEl.disabled = disable;
            const swEl = this._getElement(baseRaw, "sw");
            swEl.disabled = disable;
            const spEl = this._getElement(baseRaw, "sp");
            spEl.disabled = disable;
          }
          // formJSON更新
          formJSON = formToJSON(this.form);
          const edgeVal = this._getAtPath(formJSON, [...basePath, "edge"]);
          const sdVal = this._getAtPath(formJSON, [...basePath, "sd"]);
          const swVal = this._getAtPath(formJSON, [...basePath, "sw"]);
          const spVal = this._getAtPath(formJSON, [...basePath, "sp"]);
          if ((procVal !== "NONE" && (!sdVal || !swVal || !spVal)) && (edgeVal === "NONE")) return
        }
        break;
      default:
    }
    this.boardPart3dCtrl?.updateModel?.(formJSON)
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

}
