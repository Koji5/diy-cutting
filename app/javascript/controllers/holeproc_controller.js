import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { diameters: Object }   // { "D03":3.0, … }
  static targets = [
    // 各角の flag / ラッパ / パーツ
    "tlFlag","trFlag","blFlag","brFlag",
    "tlDyDxWrap","trDyDxWrap","blDyDxWrap","brDyDxWrap",
    "tlDiaSelWrap","trDiaSelWrap","blDiaSelWrap","brDiaSelWrap",
    "tlDiaSel","trDiaSel","blDiaSel","brDiaSel",
    "tlDiaInputWrap","trDiaInputWrap","blDiaInputWrap","brDiaInputWrap"
  ]

  connect() { this.updateAll() }

  flagChanged() { this.updateAll() }
  diaChanged(e) { this.updateDiaField(e.target) }

  /** check 変更時：dy/dx & 径セレクトを表示 */
  updateAll () {
    ["tl","tr","bl","br"].forEach(key => {
      const flag = this[`${key}FlagTarget`].checked
      this[`${key}DyDxWrapTarget`].classList.toggle("d-none", !flag)
      this[`${key}DiaSelWrapTarget`].classList.toggle("d-none", !flag)
      if (!flag) {
        // 非選択時は径入力欄も隠して値リセット
        this[`${key}DiaSelTarget`].value = ""
        this[`${key}DiaInputWrapTarget`].classList.add("d-none")
        this[`${key}DiaInputWrapTarget`].querySelector("input").value = ""
      } else {
        // 既存選択によって径入力欄を再判定
        this.updateDiaField(this[`${key}DiaSelTarget`])
      }
    })
  }

  /** 径セレクト変更時：D16P なら入力欄を表示 */
  updateDiaField(select) {
    const key = select.name.match(/hole_(..)_dia_code/)[1]   // tl など
    const isPlus = select.value === "D16P"
    this[`${key}DiaInputWrapTarget`].classList.toggle("d-none", !isPlus)
    if (!isPlus) {
      this[`${key}DiaInputWrapTarget`].querySelector("input").value = ""
    }
  }
}
