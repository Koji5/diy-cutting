// app/javascript/controllers/edgeproc_controller.js
// =====================================================================
// Edgeproc Controller  ★rev3 2025‑06‑11
//   8 方向 edge_*_code プルダウンの活性 / 非活性を管理。
//   ルールの優先順位:
//     1. allow_edge_json  …… shape がその方向のエッジ加工を許可
//        → 許可されていなければ常に disabled。
//     2. 四隅 (tl,tr,bl,br) については allow_corner_json をチェック。
//        ・allow_corner_json が **許可していない角**  → 手順 1 の結果をそのまま採用（corner 無視）。
//        ・allow_corner_json が **許可している角**     → corner_*_code が "NONE" なら disabled、
//                                                       NONE 以外なら enabled。
//   トリガー:
//     • shape_code change   （data-action="shapeproc#shapeChanged" 等で呼ばれる）
//     • corner_*_code change （connect 時に直接 addEventListener）
// =====================================================================
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "shape",
    "tlSelect","tSelect","trSelect",
    "lSelect","rSelect",
    "blSelect","bSelect","brSelect"
  ]

  connect () {
    /* ----- ルール JSON ---------------------------------------- */
    const raw = this.element.dataset.allshapesValue || "{}";
    const cfg = JSON.parse(raw);
    this.edgeRules    = cfg.edge   || {};   // allow_edge_json
    this.cornerRules  = cfg.corner || {};   // allow_corner_json

    /* ----- corner セレクトを動的取得 --------------------------- */
    this.cornerSelects = {};
    ["tl","tr","bl","br"].forEach(dir => {
      const sel = this.element.querySelector(`[name="part[corner_${dir}_code]"]`);
      if (sel) {
        this.cornerSelects[dir] = sel;
        sel.addEventListener("change", () => this.refresh());
      }
    });

    this.refresh();
  }

  shapeChanged () { this.refresh(); }

  /* ------------------------------------------------------------------
   * refresh(): shape / corner 状態から edge プルダウンの有効/無効を再計算
   * ----------------------------------------------------------------*/
  refresh () {
    const shapeCode      = this.shapeTarget.value;
    const allowedEdges   = this.edgeRules[shapeCode]   || [];
    const allowedCorners = this.cornerRules[shapeCode] || [];

    /* ----- 四隅 corner セレクトの現在値をまとめて取得 --------------- */
    const cornerVals = {};
    ["tl","tr","bl","br"].forEach(dir => {
      cornerVals[dir] = this.cornerSelects[dir]?.value;
    });

    console.debug("[edgeproc] shape=", shapeCode,
                  "allowedEdges=", allowedEdges,
                  "allowedCorners=", allowedCorners,
                  "cornerVals=", cornerVals);

    const dirs = ["tl","t","tr","l","r","bl","b","br"];
    dirs.forEach(dir => {
      const sel = this[`${dir}SelectTarget`];
      if (!sel) return;

      /* --- ① allow_edge_json 判定 ----------------------------- */
      let enable = allowedEdges.includes(dir);

      /* --- ② corner 判定 (四隅のみ) --------------------------- */
      if (["tl","tr","bl","br"].includes(dir)) {
        if (allowedCorners.includes(dir)) {
          // corner が許可されている角は corner セレクトの値で上書き判定
          const cVal = cornerVals[dir];
          enable = (cVal !== undefined && cVal !== "NONE");
        }
        // allowedCorners に含まれていない角は corner を無視 (base enable)
      }

      /* --- DOM 反映 ------------------------------------------ */
      sel.disabled = !enable;
      if (!enable) sel.value = "NONE";
    });
  }
}
