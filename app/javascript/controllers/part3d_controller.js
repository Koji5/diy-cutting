/********************************************************************
 * part3d_controller.js — geoCtx + buildShape + Three.js preview
 * 完全クリーン版 2025‑06‑02
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
  connect () {
    /* フォーム --------------------------- */
    this.form = this.element.closest("form") || document.forms[0];

    /* Three.js -------------------------- */
    this._initThree();

    /* 初回描画 & 監視 ------------------- */
    this._updateModel();
    this.form.addEventListener("input", () => this._updateModel());
    window.addEventListener("resize", () => this._handleResize());

    /* Bootstrap タブが表示された瞬間にリサイズ+再描画 */
    document.addEventListener("shown.bs.tab", e => {
      const target = e.target.dataset.bsTarget || "";
      if (target === "#preview-pane") {
        // 少し遅らせて layout が確定してから実行
        setTimeout(() => {
          this._handleResize();
          this._updateModel();
        }, 10);
      }
    });

    /* コンソールデバッグ ---------------- */
    window.part3d   = this;
    window.THREE    = THREE;
    window.buildCtx = buildCtx;
    window.renderer = this.renderer;
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

  /*====================== モデル更新 ============================*/
  _updateModel () {
    /* Three.js がまだ初期化前なら抜ける */
    if (!this.camera) return;

    const ctx = buildCtx(this.form);

    /* 未入力 (L/W/T どれか 0) はメッシュを消して終了 */
    if (!ctx.L || !ctx.W1 || !ctx.T) {
      this._replaceMesh(null);
      return;
    }

    /* Mesh 生成 */
    const shape = buildShape(ctx);
    let geom = extrudePlate(shape, ctx.T);
    // --- Extrude した時点で holes が反映されるため追加 CSG 不要

    const baseMesh = new THREE.Mesh(
      geom,
      new THREE.MeshStandardMaterial({ color: 0x6699ff, metalness:0.2, roughness:0.7 })
    );
    // ③ エッジ加工を適用（戻り値を上書き）
    const finalMesh = applyEdges(baseMesh, ctx);
    this._replaceMesh(finalMesh);

    /* --- カメラとライトをモデル中心へ ------------------------- */
    const box = new THREE.Box3().setFromObject(finalMesh);
    if (!isFinite(box.max.x)) return;            // 空ジオメトリガード

    const center = box.getCenter(new THREE.Vector3());
    const size   = box.getSize(new THREE.Vector3());
    const diag   = Math.hypot(size.x, size.y) || 1;
    const offZ   = size.z || ctx.T || 10;

    this.controls.target.copy(center);
    this.camera.position.set(center.x + diag, center.y + diag, center.z + offZ * 3);
    this.camera.near = 1;
    this.camera.far  = diag * 20;
    this.camera.updateProjectionMatrix();
    this.controls.update();

    /* ライトをモデル方向へ再配置 */
    this.dirLight.position.set(center.x, center.y + diag, center.z + offZ);
  }

  /*====================== メッシュ差し替え ======================*/
  _replaceMesh (mesh) {
    if (this.mesh) this.scene.remove(this.mesh);
    this.mesh = mesh;
    if (mesh) this.scene.add(mesh);
  }
}
