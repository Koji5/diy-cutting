import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    // Three.js の <canvas> を探す
    this.canvas = document.querySelector(
      "canvas[data-part3d-target='canvas']"
    )
    // part3d コントローラがまだ未接続の可能性を考慮して遅延取得
    const tryGetPart3d = () => {
      if (!this.canvas) return;
      const el = this.canvas.closest("[data-controller~='part3d']");
      this.part3d =
        this.application.getControllerForElementAndIdentifier(el, "part3d");
      if (!this.part3d) requestAnimationFrame(tryGetPart3d);  // 1 フレーム後に再試行
    };
    tryGetPart3d();
    /* --- デバッグ: submit 発火確認 --- */
    this.element.addEventListener("submit",
      () => console.log("[thumb] form SUBMITTED"), { once: true });
    // フォーム送信直前に 1 度だけキャプチャ
    this.element.addEventListener("submit", this.capture)
  }

  capture = async (e) => {
    e.preventDefault()
    this.canvas = document.querySelector("canvas[data-part3d-target='canvas']");
    /* デバッグ: 現在のキャンバス寸法を確認 */
    console.log("[thumb] canvas size", this.canvas?.width, this.canvas?.height);

    if (!this.canvas || this.canvas.width === 0 || this.canvas.height === 0) {
      // プレビュー未表示 → サーバ側に任せる
      console.log("[thumb] width == 0 → フォールバック (SVG へ)");
      this.element.requestSubmit()
      return
    }

    /* ここに来た＝ PNG キャプチャに進むはず */
    console.log("[thumb] PNG キャプチャへ進む");

    /* --- 最新フレームを 1 度だけ描画 --- */
    if (this.part3d?.render) {                // ← ここをガード付きで
      // IntersectionObserver で stop 中でも 1 フレームだけ描画
      this.part3d.render();
    }

    /* --- hidden フィールドへ base64 --- */
    const base64 = this.canvas.toDataURL("image/png").replace(/^data:image\/png;base64,/, "")
    console.log("[thumb] base64 bytes", base64.length);
    this.element.querySelector("#thumbnail_data").value = base64
    /* 自前でリスナー解除 → 二重送信防止 */
    this.element.removeEventListener("submit", this.capture);
    /* Turbo と衝突しないよう次ティックで送信 */
    setTimeout(() => {
      console.log("[thumb] requestSubmit firing");
      this.element.requestSubmit();
    }, 0);
  }
}
