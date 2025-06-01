/********************************************************************
 *  Stimulus controller – 3-D preview (Rectangle & Niche only)
 *******************************************************************/
import { Controller }      from "@hotwired/stimulus";
import * as THREE          from "three";
import { OrbitControls }   from "three/examples/jsm/controls/OrbitControls.js";

import {
  buildRect,
  buildNicheSagitta,
  buildCornerFillet,
  buildSideArc1,
  buildSideUArc,
  buildTriEq,
  buildCircle,
  buildSemiCircle,
  buildCornerTri
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
    const num = name => {
      const v = parseFloat(
        this.form.querySelector(`[name='part[${name}]']`)?.value ?? ""
      );
      return Number.isFinite(v) ? v : 0;        // ← NaN を 0 扱い
    };
    const rad = name => num(name) || 0;

    const radii = {
      tl: rad("shape_tl_r"),
      tr: rad("shape_tr_r"),
      bl: rad("shape_bl_r"),
      br: rad("shape_br_r")
    };

    const str = name => this.form.querySelector(`[name='part[${name}]']`)?.value || "";

    const w1 = num("width1_mm");
    const w2 = num("width2_mm");
    const l  = num("length_mm");
    const t  = num("thickness_mm");
    const shape = str("shape_code") || "NICHE";
    const r  = {
      tl: num("shape_tl_r"),
      tr: num("shape_tr_r"),
      bl: num("shape_bl_r"),
      br: num("shape_br_r")
    };
    if (!w1 || !l || !t) return null;
    return { shape, w1, w2, l, t, ...r };
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
      case "CORNER_R1":
        shape = buildCornerFillet({ w:ctx.w1,l:ctx.l, rBL:ctx.bl });
        break;
      case "CORNER_R2":
        shape = buildCornerFillet({ w:ctx.w1,l:ctx.l, rBL:ctx.bl, rBR:ctx.br });
        break;
      case "CORNER_R4":
        shape = buildCornerFillet({
          w:ctx.w1,l:ctx.l,
          rTL:ctx.tl,rTR:ctx.tr,rBL:ctx.bl,rBR:ctx.br
        });
        break;
      case "SIDE_ARC1":
        shape = buildSideArc1({ w:ctx.w1,l:ctx.l, rTL:ctx.tl,rBL:ctx.bl });
        break;
      case "SIDE_UARC1":
        shape = buildSideUArc({ w: ctx.w1, l: ctx.l, both: false });
        break;
      case "SIDE_UARC2":
        shape = buildSideUArc({ w: ctx.w1, l: ctx.l, both: true });
        break;
      case "TRI_EQ":
        shape = buildTriEq({ l:ctx.l });
        break;
      case "CIRC":
        shape = buildCircle({ d:ctx.w1 });
        break;
      case "SEMI":
        shape = buildSemiCircle({ d:ctx.w1 });
        break;
      case "CORNER_TRI":
        shape = buildCornerTri({ w: ctx.w1 });
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
