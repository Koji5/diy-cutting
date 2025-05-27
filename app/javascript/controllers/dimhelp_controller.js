import { Controller } from "@hotwired/stimulus"

// モーダルが開くたびに shape_code を参照して説明文を差し替える
export default class extends Controller {
  static targets = ["modal"]

  connect () {
    this.modalBody = this.element.querySelector(".dim-help-body")
    this.element.addEventListener("show.bs.modal", () => this.updateHelp())
  }

  updateHelp () {
    const shapeCode = document.querySelector("[data-dims-target='shape']").value

    const help = {
      "NICHE": "ニッチ形状では巾2 (棚奥行) も入力してください。",
      "TRI_EQ": "正三角形は巾1=一辺、長さは自動入力されます。",
      "CIRC": "円型は巾1=直径、長さは自動入力されます。",
      "SEMI": "半円型は巾1=直径、長さは自動入力されます。",
      "CORNER_TRI": "コーナー△型では巾1=辺長、長さは自動入力されます。",
      "default": "厚み・巾・長さをミリ単位で入力してください。"
    }

    this.modalBody.textContent = help[shapeCode] || help.default
  }
}
