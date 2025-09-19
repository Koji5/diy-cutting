// app/javascript/controllers/part_show_controller.js
import { Controller } from "@hotwired/stimulus"
import * as THREE        from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import { buildCtx   }    from "helpers/build_ctx";
import { buildShape }    from "helpers/shape_builders";
import {
  extrudePlate,
  applyEdges
} from "helpers/modifiers";

export default class extends Controller {
  static targets = ["flag", "select", "number", "canvas"]
  static values = { shaderUrl: String }
  woodMat = null;           // キャッシュ済み ShaderMaterial
  cameraInitialized = false;

  connect () {
    console.log("✅ part-show connected")
    // 初期表示
    this.flagTargets.forEach(flag => this.toggleFlagSection(flag))
    this.selectTargets.forEach(sel => this.toggleSelectSection(sel))
    this.numberTargets.forEach(num => this.toggleNumberSection(num))
    /* フォーム --------------------------------- */
    this.form = this.element.closest("form") || document.forms[0]
    /* Three.js --------------------------------- */
    this._initThree()
    /* 初回描画 & 監視 --------------------------------- */
    this._updateModel();
    this.form.addEventListener("input",  () => this._updateModel())
    window.addEventListener("resize", () => this._handleResize())
  }

  // ----------------------------------
  toggleFlagSection (checkbox) {
    const sectionKey = checkbox.dataset.readonlySectionParam
    const blocks = this.element.querySelectorAll(
      `[data-readonly-section="${sectionKey}"]`
    )
    blocks.forEach(b => {
      b.classList.toggle("d-none", !checkbox.checked)
    })
  }
  toggleSelectSection(sel) {
    const hideCode = sel.dataset.readonlyHideCode          // "NONE"
    const sectionKey = sel.dataset.readonlySectionParam    // "corner_tl_select"
    const blocks = this.element.querySelectorAll(
      `[data-readonly-section="${sectionKey}"]`
    )
    blocks.forEach(b => {
      b.classList.toggle("d-none", sel.value === hideCode || sel.value === "")
    })
  }
  toggleNumberSection (num) {
    const isBlank   = num.value === "" || num.value === "0"
    const section   = num.dataset.readonlySectionParam // "shape_tl_r"
    const selector  = `[data-readonly-section="${section}"]`
    this.element.querySelectorAll(selector).forEach(block => {
      block.classList.toggle("d-none", isBlank)
    })
  }

  refresh () {
    this._handleResize();
    this._updateModel();
  }

  /*=====================  Three.js 初期化 =======================*/
  _initThree () {
    /* サイズ (高さ 0 → 16:9 仮決め) */
    const rect = this.element.getBoundingClientRect();
    this.w = rect.width;
    this.h = rect.height || rect.width * 9/16;

    /* シーン */
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x202020);
    this.scene.add(new THREE.AxesHelper(100));

    /* カメラ */
    this.camera = new THREE.PerspectiveCamera(45, this.w/this.h, 1, 5000);
    this.camera.position.set(300, 300, 300);

    /* ライト */
    this.dirLight = new THREE.DirectionalLight(0xffffff, 0.8);
    this.dirLight.position.set(1, 1, 1);
    this.scene.add(this.dirLight);
    this.scene.add(new THREE.AmbientLight(0xffffff, 0.5));

    /* レンダラー */
    const canvas = this.canvasTarget
    this.renderer = new THREE.WebGLRenderer({ canvas, antialias:true });
    this.renderer.setPixelRatio(window.devicePixelRatio);
    this.renderer.setSize(this.w, this.h, false);

    /* Controls */
    this.controls = new OrbitControls(this.camera, this.renderer.domElement);
    this.controls.enableDamping = true;

    /* ループ */
    const animate = () => {
      requestAnimationFrame(animate);
      this.controls.update();
      this.renderer.render(this.scene, this.camera);
    };
    animate();
  }

  /*========================= リサイズ ============================*/
  _handleResize () {
    const rect = this.canvasTarget.getBoundingClientRect()
    this.w = rect.width;
    this.h = rect.height || rect.width * 9/16;
    this.renderer.setSize(this.w, this.h, false);
    this.camera.aspect = this.w / this.h;
    this.camera.updateProjectionMatrix();
  }

  /*====================== モデル更新 ============================*/
  async _updateModel () {
    /* Three.js がまだ初期化前なら抜ける */
    if (!this.camera) return;

    const ctx = buildCtx(this.form);

    /* Mesh 生成 */
    const shape = buildShape(ctx);
    let geom = extrudePlate(shape, ctx.T);

    /* --- マテリアル取得 -------------------------------------- */
    let mat;
    if (this.woodMat) {
      mat = this.woodMat;           // キャッシュ済み
    } else {
      try {
        const res  = await fetch(this.shaderUrlValue);
        const data = await res.json();

        this.woodMat = new THREE.ShaderMaterial({
          uniforms:       data.uniforms,
          vertexShader:   data.vertexShader,
          fragmentShader: data.fragmentShader,
          side: THREE.DoubleSide
        });
        mat = this.woodMat;
      } catch (err) {
        console.error("wood shader load failed:", err);
        mat = new THREE.MeshStandardMaterial({
          color: 0x6699ff, metalness: 0.2, roughness: 0.7
        });
      }
    }

    /* --- メッシュ生成 & シーン反映 --------------------------- */
    const baseMesh  = new THREE.Mesh(geom);
    const finalMesh = applyEdges(baseMesh, ctx);
    this._replaceMesh(finalMesh, mat);

    /* --- カメラ / ライト 再配置 ------------------------------- */
    const box = new THREE.Box3().setFromObject(finalMesh);
    if (isFinite(box.max.x)) {
      const center = box.getCenter(new THREE.Vector3());

      /* ★ 初回だけ固定アングルにセット */
      if (!this.cameraInitialized) {
        /* ① モデル中心から “斜め前上” 方向へ伸ばす距離を計算  */
        const dir = new THREE.Vector3(0, 1, 5).normalize();  // 視線方向 (縦-横比同じ)

        /* ② 半径 r × 4 だけ離す ── 数字を大きくすると遠ざかる */
        const r = box.getSize(new THREE.Vector3()).length() * 0.5;  // ≈ bounding sphere 半径
        this.camera.position.copy(center).addScaledVector(dir, r * 5);
        this.controls.target.copy(center);    // ← ② モデル中心を見る
        this.controls.update();               // ← ③ 行列を同期
        this.cameraInitialized = true;        // フラグを立てる
      }

      /* --- クリップ面は毎回更新（大型モデル対策） --- */
      const radius = box.getSize(new THREE.Vector3()).length() * 0.5;
      this.camera.near = 0.1;
      this.camera.far  = radius * 10;
      this.camera.updateProjectionMatrix();

      /* ライト位置はカメラと一緒に動かすと自然 */
      this.dirLight.position.copy(this.camera.position).multiplyScalar(1.2);
    }
  }

  /*====================== メッシュ差し替え ======================*/
  _replaceMesh (mesh, mat) {
    /* --- 1. 旧メッシュをシーンから外し、GPUメモリを解放 --- */
    const old = this.mesh;                // 退避
    if (old) {
      this.scene.remove(old);             // detach

      // dispose は try‐catch で念のためガード
      try { old.geometry.dispose(); } catch(e){}

      if (Array.isArray(old.material)) {
        old.material.forEach(m => m.dispose?.());
      } else {
        old.material?.dispose?.();
      }
    }

    /* --- 2. 新メッシュを登録・マテリアル差し替え --- */
    this.mesh = mesh;

    if (mesh) {
      mesh.material = mat;          // ← 差し替え
      mesh.material.needsUpdate = true;
      this.scene.add(mesh);
    }
  }
}
