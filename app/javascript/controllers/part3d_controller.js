/********************************************************************
 * part3d_controller.js — geoCtx + buildShape + Three.js preview
 * リファクタ版 2025‑06‑18
 *   - 同期初期化 _synchronization()
 *   - 非同期描画   _asynchronousProcessing()
 *******************************************************************/
import { Controller }    from "@hotwired/stimulus";
import * as THREE        from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";

import { buildCtx   }    from "helpers/build_ctx";
import { buildShape }    from "helpers/shape_builders";
import {
  extrudePlate,
  applyEdges
} from "helpers/modifiers";

export default class extends Controller {
  static values = { shaderUrl: String }
  woodMat = null;           // キャッシュ済み ShaderMaterial
  cameraInitialized = false;

  /*=============================  接続 ============================*/
  async connect () {
    const loaderCtrl = this.application.getControllerForElementAndIdentifier(
      document.body, "page-loading"
    )

    // --- 即時完了する初期化（同期） -----------------------------
    this._synchronization()

    // --- 非同期: 初回モデルを描画し終わるまで待つ --------------
    const p = this._asynchronousProcessing()
    loaderCtrl?.register(p)
    await p                         // 完了してから connect() を抜ける
  }

  /*====================  ⚡同期初期化処理 ========================*/
  _synchronization () {
    /* フォーム --------------------------------- */
    this.form = this.element.closest("form") || document.forms[0]

    /* Three.js --------------------------------- */
    this._initThree()

    /* イベント --------------------------------- */
    this.form.addEventListener("input",  () => this._updateModel())
    window.addEventListener("resize", () => this._handleResize())

    document.addEventListener("shown.bs.tab", e => {
      if ((e.target.dataset.bsTarget || "") === "#preview-pane") {
        setTimeout(() => {
          this._handleResize()
          this._updateModel()
        }, 10)
      }
    })
  }

  /*================  🕒初回モデル描画（非同期） =================*/
  _asynchronousProcessing () {
    // _updateModel は async 関数 → Promise を返す
    return this._updateModel()
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

    /* カメラ */
    this.camera = new THREE.PerspectiveCamera(45, this.w/this.h, 1, 5000);
    this.camera.position.set(300, 300, 300);

    /* ライト */
    this.dirLight = new THREE.DirectionalLight(0xffffff, 0.8);
    this.dirLight.position.set(1, 1, 1);
    this.scene.add(this.dirLight);
    this.scene.add(new THREE.AmbientLight(0xffffff, 0.5));

    /* レンダラー */
    this.renderer = new THREE.WebGLRenderer({ antialias:true });
    this.renderer.setPixelRatio(window.devicePixelRatio);
    this.renderer.setSize(this.w, this.h, false);
    this.element.appendChild(this.renderer.domElement);

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
    const rect = this.element.getBoundingClientRect();
    this.w = rect.width;
    this.h = rect.height || rect.width * 9/16;
    this.renderer.setSize(this.w, this.h, false);
    this.camera.aspect = this.w / this.h;
    this.camera.updateProjectionMatrix();
  }

  /*====================== モデル更新 (async) ====================*/
  async _updateModel () {
    if (!this.camera) return Promise.resolve();

    const ctx = buildCtx(this.form);

    /* 入力不足 → メッシュを消して終わり */
    if (!ctx.L || !ctx.W1 || !ctx.T) {
      this._replaceMesh(null);
      return Promise.resolve();
    }

    /* --- Geometry 生成 -------------------------------------- */
    const shape = buildShape(ctx);
    const geom  = extrudePlate(shape, ctx.T);

    /* --- マテリアル取得 -------------------------------------- */
    let mat;
    if (this.woodMat) {
      mat = this.woodMat;           // キャッシュ済み
    } else {
      try {
        const res  = await fetch(this.shaderUrlValue);
        const data = await res.json();
        // 色を THREE.Color に変換しておくと後で setRGB が使える
        if (data.uniforms.baseColor) {
          const c  = data.uniforms.baseColor.value;
          data.uniforms.baseColor.value = new THREE.Color(c.r, c.g, c.b);
        }
        if (data.uniforms.darkColor) {
          const c  = data.uniforms.darkColor.value;
          data.uniforms.darkColor.value = new THREE.Color(c.r, c.g, c.b);
        }
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

    return Promise.resolve();           // 呼び出し側へ完了を通知
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
