/********************************************************************
 *  Stimulus controller – 3-D preview (Rectangle & Niche only)
 *******************************************************************/
import { Controller }      from "@hotwired/stimulus";
import * as THREE          from "three";
import { OrbitControls }   from "three/examples/jsm/controls/OrbitControls.js";

import {
  buildRect,
  buildNicheSagitta
} from "helpers/shape_builders";

import { extrudePlate }    from "helpers/modifiers";  // 何も加工しない場合でも必須

export default class extends Controller {
  static targets = ["canvas"];

  connect() {
    /* DOM */
    this.form   = this.element.closest("form");
    this.canvas = this.hasCanvasTarget ? this.canvasTarget : this._makeCanvas();

    /* THREE scene */
    this.scene  = new THREE.Scene();
    this.camera = new THREE.PerspectiveCamera(35, 1, 0.1, 5000);
    this.camera.position.set(800, 400, 800);

    this.renderer = new THREE.WebGLRenderer({ antialias:true, alpha:true, canvas:this.canvas });
    this._resize();

    this.controls = new OrbitControls(this.camera, this.renderer.domElement);
    this.controls.enableDamping = true;
    this.scene.add(new THREE.HemisphereLight(0xffffff, 0x444444, 1));

    /* events */
    window.addEventListener("resize", () => this._resize());
    this.form.addEventListener("input",  () => this._refresh());
    this.form.addEventListener("change", () => this._refresh());

    this._animate = this._animate.bind(this);
    this._loopId  = requestAnimationFrame(this._animate);

    this._refresh();
  }

  disconnect() {
    cancelAnimationFrame(this._loopId);
    this.renderer.dispose();
  }

  /* ------------------------------ build ctx --------------------- */
  _ctx() {
    const num = name => parseFloat(this.form.querySelector(`[name='part[${name}]']`)?.value || "");
    const str = name => this.form.querySelector(`[name='part[${name}]']`)?.value || "";

    const w1 = num("width1_mm");
    const w2 = num("width2_mm");
    const l  = num("length_mm");
    const t  = num("thickness_mm");
    const shape = str("shape_code") || "NICHE";

    if (!w1 || !l || !t) return null;   // 必須チェック

    return { shape, w1, w2: Number.isFinite(w2) ? w2 : undefined, l, t };
  }

  /* ------------------------------ refresh model ----------------- */
  _refresh() {
    clearTimeout(this._deb);
    this._deb = setTimeout(() => this._updateModel(), 150);
  }

  _updateModel() {
    const ctx = this._ctx();
    if (!ctx) return;

    let shape;
    switch (ctx.shape) {
      case "RECT":
        shape = buildRect({ w: ctx.w1, l: ctx.l });
        break;
      case "NICHE":
      default:
        shape = buildNicheSagitta({ w1: ctx.w1, w2: ctx.w2, l: ctx.l });
        break;
    }

    const geom = extrudePlate(shape, ctx.t);
    const mesh = new THREE.Mesh(geom, new THREE.MeshStandardMaterial({ color:0x888888 }));

    if (this._mesh) {
      this.scene.remove(this._mesh);
      this._dispose(this._mesh);
    }
    this._mesh = mesh;
    this.scene.add(mesh);
  }

  /* ------------------------------ render loop ------------------- */
  _animate() {
    this.controls.update();
    this.renderer.render(this.scene, this.camera);
    this._loopId = requestAnimationFrame(this._animate);
  }

  _resize() {
    const w = this.canvas.clientWidth  || 600;
    const h = this.canvas.clientHeight || 400;
    this.renderer.setSize(w, h, false);
    this.camera.aspect = w / h;
    this.camera.updateProjectionMatrix();
  }

  /* ------------------------------ helpers ----------------------- */
  _makeCanvas() {
    const c = document.createElement("canvas");
    c.classList.add("w-100", "h-100");
    this.element.appendChild(c);
    return c;
  }

  _dispose(mesh) {
    mesh.geometry.dispose();
    (Array.isArray(mesh.material) ? mesh.material : [mesh.material]).forEach(m => m.dispose());
  }
}
