import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["box"]

  update(event) {
    const file = event.target.files[0]
    if (!file) return
    const reader = new FileReader()
    reader.onload = () => {
      // <img> を動的に差し込む（object-fit でトリム）
      this.boxTarget.innerHTML =
        `<img src="${reader.result}" class="w-100 h-100 object-fit-cover" alt="">`
    }
    reader.readAsDataURL(file)
  }
}
