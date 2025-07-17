import { Controller } from "@hotwired/stimulus"

// --------------------------------------------------
// フォームバリデーション用 Stimulus コントローラ
//
// ✅ 使い方：form_with の書き方
// <%= form_with model: ..., 
//               data: { controller: "form-validation", "form-validation-context-value": "recipe-new" }, 
//               html: { class: "needs-validation", novalidate: true } do |f| %>
//
// ✅ HTML5 バリデーションの記述例（form-control に追加）
// <%= f.text_field :name, 
//       class: "form-control", 
//       required: true, 
//       maxlength: 60, 
//       pattern: "[ぁ-んァ-ヶー一-龠々]+" %>
//
// ✅ エラーメッセージを表示したい場合（Bootstrap対応）
// <div class="invalid-feedback">
//   名前は必須です（60文字以内）
// </div>
//
// ✅ フォームごとのバリデーションを切り替えたい場合は
// controllerの data 属性に "form-validation-context-value" を追加し、
// Stimulus側で this.contextValue に応じて切り替えてください。
// （独自バリデーションが必要な場合は switch(contextValue) に case を追加する）
// --------------------------------------------------
export default class extends Controller {
  static values = {
    context: String
  }

  connect() {
    console.log("フォームコンテキスト:", this.contextValue)

    this.element.addEventListener("submit", (event) => {
      if (!this.validate()) {
        event.preventDefault()
        event.stopPropagation()
      }
      this.element.classList.add("was-validated")
    })
  }

  validate() {
    // 共通HTML5チェック
    let allValid = this.element.checkValidity()

    // フォーム別のカスタムチェック
    switch (this.contextValue) {
      case "recipe-new": {
        // 子要素チェック
        const container = this.element.querySelector("#floatingInput")
        const feedback = this.element.querySelector("#floatingInput + .invalid-feedback")

        console.log("子要素数:", container.children.length)
        if (container && container.children.length === 0) {
          container.classList.remove("is-valid")
          container.classList.add("is-invalid")
          feedback?.classList.remove("d-none")
          feedback?.classList.add("d-block")
          allValid = false
        } else {
          container?.classList.remove("is-invalid")
          container.classList.add("is-valid")
          feedback?.classList.remove("d-block")
          feedback?.classList.add("d-none")
        }
        break
      }

      // 他のフォームコンテキストもここに追加可能
      // case "user-signup":
      //   ...独自チェック...

      default:
        // コンテキストが未指定またはマッチしない場合は何もしない
        break
    }
    console.log("バリデーション結果:", allValid)
    // 最後に共通バリデーション結果を返す
    return allValid
  }
}
