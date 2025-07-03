import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preview", "input", "removeFlag"]

  update(event) {
    const file = event.target.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = () => {
      this.previewTarget.src = reader.result
      this.previewTarget.classList.remove("d-none")
      // 削除フラグをリセット
      if (this.hasRemoveFlagTarget) this.removeFlagTarget.value = "0"
    }
    reader.readAsDataURL(file)
  }

  remove() {
    // プレビュー非表示
    this.previewTarget.src = ""
    this.previewTarget.classList.add("d-none")
    // file_field をリセット
    this.inputTarget.value = ""

    // 削除フラグON
    if (this.hasRemoveFlagTarget) this.removeFlagTarget.value = "1"
  }

  triggerFileSelect() {
    this.inputTarget.click()
  }
}
