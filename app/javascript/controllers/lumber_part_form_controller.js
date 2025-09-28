import { Controller } from "@hotwired/stimulus"
import { formToJSON } from "lib/serialize_form";

export default class extends Controller {

  connect() {
    this.lumberEl = document.querySelector('[data-controller~="lumber-part3d"]')
    this.lumberPart3dCtrl = this.lumberEl
      ? this.application.getControllerForElementAndIdentifier(this.lumberEl, "lumber-part3d")
      : null
    this.form = this.element.closest("form") || document.forms[0]
    // 解除用にハンドラを束ねておく
    this._onChange = (e) => this._updateForm(e);
    this.form.addEventListener("change", this._onChange);
    this._initForm();
  }

  disconnect() {
    this.form?.removeEventListener("change", this._onChange)
  }

  _initForm() {
//    const procNames = this._collectProcNames(this.form);
//    for (const procName of procNames) {
//      const rawPath = this._parseName(procName);
//      const baseRaw = rawPath.slice(0, -1);
//      const procEl = this._getElement(baseRaw, "proc");
//      const procVal = procEl.value;
//      const disable = (procVal === "NONE");
//      this._changeDisabled(rawPath[2], baseRaw, "proc", disable);
//    }

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
//    const rawPath = this._parseName(el.name);
//    const baseRaw = rawPath.slice(0, -1);
//    const path = this._normalizePathForFoldAttributes(rawPath);
//    const basePath = path.slice(0, -1);
//    const ignoreList = ["material_code", "paint_type_code", "paint_color_code", "paint_gloss_code", "name", "note"];
//    if (ignoreList.includes(path.at(-1))){
//      return;
//    } else if (path.at(-1) === "disp") {
//      const dispVal = this._getAtPath(formJSON, [...basePath, "disp"]);
//      this.lumberPart3dCtrl?.setMeshVisibilityAtPath?.(path.slice(2, 4), dispVal);
//      return;
//    }
//    const type = path[2];
//    switch(type) {
//      case "side_json":
//        {
//          const procVal = this._getAtPath(formJSON, [...basePath, "proc"]);
//          const disable = (procVal === "NONE");
//          this._changeDisabled(type, baseRaw, path.at(-1), disable);
//          // formJSON更新
//          formJSON = formToJSON(this.form);
//          const edgeVal = this._getAtPath(formJSON, [...basePath, "edge"]);
//          const sdVal = this._getAtPath(formJSON, [...basePath, "sd"]);
//          const swVal = this._getAtPath(formJSON, [...basePath, "sw"]);
//          const spVal = this._getAtPath(formJSON, [...basePath, "sp"]);
//          if ((procVal !== "NONE" && (!sdVal || !swVal || !spVal)) && (edgeVal === "NONE")) return;
//        }
//        break;
//      case "hole_json":
//        {
//          const surfaceVal = this._getAtPath(formJSON, [...basePath, "surface"]);
//          const dxVal = this._getAtPath(formJSON, [...basePath, "dx"]);
//          const dyVal = this._getAtPath(formJSON, [...basePath, "dy"]);
//          const depthVal = this._getAtPath(formJSON, [...basePath, "depth"]);
//          this._changeDisabled(type, baseRaw, path.at(-1), true, surfaceVal);
//          if (surfaceVal === "FRONT" || surfaceVal === "BACK") {
//            if (!dxVal || !dyVal ||!depthVal) return;
//          } else if (surfaceVal === "LEFT" || surfaceVal === "RIGHT") {
//            if (!dyVal ||!depthVal) return;
//          } else if (surfaceVal === "TOP" || surfaceVal === "BOTTOM") {
//            if (!dxVal ||!depthVal) return;
//          }
//        }
//        break;
//      default:
//    }
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
}