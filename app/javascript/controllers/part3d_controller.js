import { Controller } from "@hotwired/stimulus"
import * as THREE from "three"
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js"
import { buildRoundedRect, applyRoundHoles } from "helpers/modifiers" // ★ 追加

/**
 * 部品 3D プレビュー Stimulus コントローラ
 *   - RECT + 角R + 丸穴 対応
 */
export default class extends Controller {
  connect () {
    this.#initScene()
    this.#initCamera()
    this.#initLights()
    this.#initRenderer()
    this.#initControls()

    this.form   = this.element.closest("form")
    this.handle = () => this.#updateModel()
    this.form.addEventListener("input",  this.handle)
    this.form.addEventListener("change", this.handle)

    this.#updateModel()
  }

  disconnect () {
    cancelAnimationFrame(this.rafId)
    this.resizeObserver.disconnect()
    this.form.removeEventListener("input", this.handle)
    this.form.removeEventListener("change", this.handle)
    this.controls.dispose()
    this.renderer.dispose()
  }

  /* ---------- init ---------- */
  #initScene () { this.scene = new THREE.Scene() }

  #initCamera () {
    const { clientWidth: w, clientHeight: h } = this.element
    this.camera = new THREE.PerspectiveCamera(45, w / h, 0.1, 10000)
  }

  #initLights () {
    this.scene.add(new THREE.AmbientLight(0xffffff, 0.9))
    const dir = new THREE.DirectionalLight(0xffffff, 0.7)
    dir.position.set(2, 3, 1)
    this.scene.add(dir)
  }

  #initRenderer () {
    this.renderer = new THREE.WebGLRenderer({ antialias:true })
    this.renderer.setPixelRatio(window.devicePixelRatio)
    this.renderer.setClearColor(0xf8f9fa)
    this.element.append(this.renderer.domElement)

    this.resizeObserver = new ResizeObserver(() => this.#resize())
    this.resizeObserver.observe(this.element)
    this.#resize()
  }

  #initControls () {
    this.controls = new OrbitControls(this.camera, this.renderer.domElement)
    this.controls.enableDamping = true
  }

  #resize () {
    const { clientWidth: w, clientHeight: h } = this.element
    this.camera.aspect = w / h
    this.camera.updateProjectionMatrix()
    this.renderer.setSize(w, h, false)
  }

  /* ---------- build ---------- */
  #updateModel () {
    const ctx = this.#buildCtx()
    if (!ctx) { this.#clearMesh(); this.renderer.render(this.scene, this.camera); return }

    this.#clearMesh()

    /* --- ベース形状 --- */
    let geom = ctx.r > 0 ? buildRoundedRect(ctx)
                         : new THREE.BoxGeometry(ctx.w, ctx.t, ctx.l)

    /* --- 丸穴 --- */
    let mesh = new THREE.Mesh(geom, new THREE.MeshPhongMaterial({ color:0x888888 }))
    mesh = applyRoundHoles(mesh, ctx)

    this.mesh = mesh
    this.scene.add(mesh)

    /* --- camera fit --- */
    const s = new THREE.Box3().setFromObject(mesh).getBoundingSphere(new THREE.Sphere())
    const r = s.radius * 1.35
    this.camera.position.set(r, r * 0.7, r)
    this.camera.lookAt(s.center)
    this.controls.target.copy(s.center)
    this.controls.update()

    if (!this.rafId) this.#animate()
  }

  #animate = () => {
    this.rafId = requestAnimationFrame(this.#animate)
    this.controls.update()
    this.renderer.render(this.scene, this.camera)
  }

  /* ---------- ctx ---------- */
  #buildCtx () {
    const num = name => parseFloat(this.form.querySelector(`[name='part[${name}]']`)?.value || "")
    const shape = this.form.querySelector(`[name='part[shape_code]']`)?.value
    const t = num("thickness_mm")
    const w = num("width1_mm")
    const l = num("length_mm")
    if (!shape || !t || !w || !l) return null

    // 角R (corner_radius_mm) と丸穴リスト (hole_x_mm, hole_z_mm, hole_dia_mm) を取得
    const r = num("corner_radius_mm") || 0

    const holes = []
    this.form.querySelectorAll("[data-hole]").forEach(el => {
      const x = parseFloat(el.dataset.x), z = parseFloat(el.dataset.z), dia = parseFloat(el.dataset.dia)
      if (!isNaN(x) && !isNaN(z) && !isNaN(dia)) holes.push({ x, z, dia })
    })

    return { shape, t, w, l, r, holes }
  }

  #clearMesh () {
    if (this.mesh) {
      this.mesh.geometry.dispose()
      this.scene.remove(this.mesh)
      this.mesh = null
    }
  }
}
