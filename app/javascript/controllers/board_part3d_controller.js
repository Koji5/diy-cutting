import { Controller }    from "@hotwired/stimulus";
import * as THREE        from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import { buildMeshesFromCtx } from "helpers/board_builders"

export default class extends Controller {

  cameraInitialized = false;
  lastL = 0;
  lastW = 0;
  lastT = 0;
  boardMeshes = {};

  connect () {
    /* Three.js --------------------------------- */
    this._initThree()
    this.controls.addEventListener("change", () => this._syncCameraState());
    /* === ResizeObserver でキャンバスサイズを監視 === */
    this.resizeObs = new ResizeObserver(entries => {
      const { width, height } = entries[0].contentRect
      if (!width || !height) return          // 幅 0 は無視
      this.renderer.setSize(width, height, false)
      this.camera.aspect = width / height
      this.camera.updateProjectionMatrix()
      this.render()                          // 1 フレームだけ描画
    })
    this.resizeObs.observe(this.element)
    this.start()
  }

  disconnect() {

  }

  start() { this.renderer.setAnimationLoop(this.render) }
  stop()  { this.renderer.setAnimationLoop(null)        }

  /*======================== 描画ループ ========================*/
  /*  start() で renderer.setAnimationLoop(this.render) が呼ばれ、
      stop()   で null がセットされて停止します。            */
  render = (time) => {
    // OrbitControls を使っている場合、update() が必要
    this.controls?.update();
  
    // シーンを描画
    this.renderer.render(this.scene, this.camera);
  };

  /*=====================  Three.js 初期化 =======================*/
  _initThree () {

    /* シーン */
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x006666);

    /* カメラ */
    this.camera = new THREE.PerspectiveCamera(45, 1, 1, 5000);
    this.camera.position.set(300, 300, 300);

    /* ライト */
    this.dirLight = new THREE.DirectionalLight(0xffffff, 0.8);
    this.dirLight.position.set(1, 1, 1);
    this.scene.add(this.dirLight);

    /* マテリアル */
    this.boardMat = new THREE.MeshStandardMaterial({
          color: 0x7d4712,
          transparent: true,   // ← 必須
          opacity: 0.35,       // 0(完全透明)〜1(不透明)
          depthWrite: true,   // 透過重なりのチラつき軽減に有効（必要に応じて）
          side: THREE.FrontSide // 両面にしたいなら DoubleSide。ただし透過はアーティファクトが増えやすい
        });

    /* レンダラー */
    this.renderer = new THREE.WebGLRenderer({ 
      antialias:             true,
      alpha:                 true,
      preserveDrawingBuffer: true
    });
    this.renderer.setPixelRatio(window.devicePixelRatio);
    /* 仮サイズで一旦 setSize —— 実サイズは ResizeObserver が上書き */
    this.renderer.setSize(1, 1, false);
    // ① プレースホルダを本物キャンバスに置き換え
    const ph = this.element.querySelector("canvas[data-board-part3d-target='canvas']");
    ph?.replaceWith(this.renderer.domElement);
    // 置き換えた canvas に 100% 指定を必ず付与
    Object.assign(this.renderer.domElement.style, {
      width: "100%",
      height: "100%",
      display: "block"
    });
    // ② data-attribute を付け直し (thumb_capture が拾いやすいように)
    this.renderer.domElement.dataset.boardPart3dTarget = "canvas";

    /* Controls */
    this.controls = new OrbitControls(this.camera, this.renderer.domElement);
    this.controls.enableDamping = true;

    /* === ここで 1 フレーム描画して黒画面を防ぐ === */
    this.renderer.render(this.scene, this.camera);
  }

  /*====================== モデル更新 ====================*/
  updateModel (ctx) {
    if (!this.camera) return
    const boardCtx = ctx.part.board_part
    boardCtx.width_mm     = Number(boardCtx.width_mm)
    boardCtx.length_mm    = Number(boardCtx.length_mm)
    boardCtx.thickness_mm = Number(boardCtx.thickness_mm)
    /* 入力不足 → メッシュを消して終わり */
    if (!boardCtx.length_mm || !boardCtx.thickness_mm || !boardCtx.width_mm) {
      this._replaceMesh(null);
      return;
    }
    /* Geometry 生成 */
    this.boardMeshes = buildMeshesFromCtx(boardCtx);
    /* --- マテリアル取得 */
    const mat = this.boardMat
    //const baseMesh  = new THREE.Mesh(boardMeshes.board);
    const baseMesh  = this.boardMeshes.board
    this._replaceMesh(baseMesh);
    baseMesh.material = mat;
    this._forEachMesh(this.boardMeshes, (mesh, path) => {
      const isBoardTop = path.length === 1 && path[0] === "board";
      mesh.visible = isBoardTop;   // board だけ true、他は false
      this.scene.add(mesh)
    });
    const box = new THREE.Box3().setFromObject(baseMesh);
    console.log("isFinite(box.max.x):", isFinite(box.max.x));
    if (isFinite(box.max.x)) {
      const center = box.getCenter(new THREE.Vector3());

      const cameraReset = this.lastL !== boardCtx.length_mm || this.lastW !== boardCtx.width_mm || this.lastT !== boardCtx.thickness_mm
      /* ★ 初回だけ固定アングルにセット */
      console.log("!this.cameraInitialized || cameraReset:", !this.cameraInitialized || cameraReset);
      if (!this.cameraInitialized || cameraReset) {
        /* ① モデル中心から “斜め前上” 方向へ伸ばす距離を計算  */
        const dir = new THREE.Vector3(0, 1, 5).normalize();  // 視線方向 (縦-横比同じ)

        /* ② 半径 r × 4 だけ離す ── 数字を大きくすると遠ざかる */
        const r = box.getSize(new THREE.Vector3()).length() * 0.5;  // ≈ bounding sphere 半径
        this.camera.position.copy(center).addScaledVector(dir, r * 4);
        this.controls.target.copy(center);    // ← ② モデル中心を見る
        this.controls.update();               // ← ③ 行列を同期
        this.dirLight.position.copy(this.camera.position).multiplyScalar(1.2);
        this.cameraInitialized = true;        // フラグを立てる
        this.lastL = boardCtx.length_mm
        this.lastW = boardCtx.width_mm
        this.lastT = boardCtx.thickness_mm
      }
      this._buildAxesAndLabels(box);

      /* --- クリップ面は毎回更新（大型モデル対策） --- */
      const radius = box.getSize(new THREE.Vector3()).length() * 0.5;
      this.camera.near = 0.1;
      this.camera.far  = radius * 10;
      this.camera.updateProjectionMatrix();

      /* ライト位置はカメラと一緒に動かすと自然 */
      this.dirLight.position.copy(this.camera.position).multiplyScalar(1.2);
    }
    console.log("this.scene:",this.scene)
    this.render()
  }

  _forEachMesh(node, fn, path = []) {
    if (!node) return;
    if (node instanceof THREE.Mesh) {
      fn(node, path);
    } else if (Array.isArray(node)) {
      node.forEach((child, i) => forEachMesh(child, fn, path.concat(String(i))));
    } else if (typeof node === "object") {
      for (const key in node) {
        this._forEachMesh(node[key], fn, path.concat(key));
      }
    }
  }

  _syncCameraState() {
    const cam  = this.camera;
    const json = JSON.stringify({
      pos:  [cam.position.x, cam.position.y, cam.position.z],
      tgt:  [this.controls.target.x, this.controls.target.y, this.controls.target.z],
      zoom: cam.zoom
    });
    document.getElementById("camera_state_json").value = json;
  }

  /*====================== メッシュ差し替え ======================*/
  _replaceMesh (mesh) {

    // 旧メッシュと旧エッジを撤去＆破棄
    if (this.mesh) {
      const targets = []
       this.scene.traverse(obj => {
        if (obj.isMesh) targets.push(obj)           // Group配下も拾う
        // 必要なら obj.isPoints / obj.isLine も対象に
      })
      targets.forEach(me => {
        me.parent?.remove(me)                   // シーンから外す
        try { me.geometry?.dispose?.() } catch (e) {}
        const mat = me.material
        if (Array.isArray(mat)) mat.forEach(m => m?.dispose?.())
        else mat?.dispose?.()
      })
    }
    this.mesh = mesh;
    //if (!mesh) return;
    //mesh.material = mat;
    // エッジをメッシュの子にする（一緒に動く）
    //const edges = new THREE.LineSegments(
    //  new THREE.EdgesGeometry(mesh.geometry ,/* thresholdAngle */30),
    //  new THREE.LineBasicMaterial({ color: 0x333333, depthTest: true, depthWrite: false })
    //);
    //edges.renderOrder = 999;
    //mesh.renderOrder  = 998;
    //mesh.add(edges);
  }

  _buildAxesAndLabels(box = null) {
    // --- 1) 前回の軸＆ラベルを破棄 ---
    if (this.axisGroup) {
      this.axisGroup.traverse(o => {
        if (o.isSprite && o.material) {
          if (o.material.map) o.material.map.dispose();
          o.material.dispose();
        }
        if (o.material) {
          (Array.isArray(o.material) ? o.material : [o.material]).forEach(m => {
            if (m.map) m.map.dispose();
            m.dispose();
          });
        }
        if (o.geometry) o.geometry.dispose();
      });
      this.scene.remove(this.axisGroup);
      this.axisGroup = null;
    }

    let X = 0;
    let Y = 0;
    let Z = 0;
    if (box && !box.isEmpty()) {
      X = Math.max(Math.abs(box.min.x), Math.abs(box.max.x)) * 1.5;
      Y = Math.max(Math.abs(box.min.y), Math.abs(box.max.y)) * 1.5;
      Z = Math.min(X, Y);
    }

    // --- 3) 新しいグループを作成 ---
    const g = this.axisGroup = new THREE.Group();
    g.name = "axisGroup";

    // --- 4) 軸（+X, +Y, -Z） ---
    const origin = new THREE.Vector3(0, 0, 0);
    g.add(new THREE.ArrowHelper(new THREE.Vector3( 1, 0, 0), origin, X, 0xff0000));
    g.add(new THREE.ArrowHelper(new THREE.Vector3( 0, 1, 0), origin, Y, 0x00ff00));
    g.add(new THREE.ArrowHelper(new THREE.Vector3( 0, 0,-1), origin, Z, 0x0000ff));

    // --- 5) ラベル（Sprite） ---
    const makeLabelSprite = (text, fontPx = 64, pad = 24) => {
      const canvas = document.createElement("canvas");
      const ctx = canvas.getContext("2d");
      ctx.font = `bold ${fontPx}px system-ui, -apple-system, "Segoe UI", Roboto, "Noto Sans JP", sans-serif`;
      const w = Math.ceil(ctx.measureText(text).width);
      canvas.width  = w + pad * 2;
      canvas.height = fontPx + pad * 2;

      const cx = canvas.width/2, cy = canvas.height/2;
      ctx.font = `bold ${fontPx}px system-ui, -apple-system, "Segoe UI", Roboto, "Noto Sans JP", sans-serif`;
      ctx.textAlign = "center"; ctx.textBaseline = "middle";
      ctx.lineWidth = 10; ctx.strokeStyle = "rgba(0,0,0,0.7)";
      ctx.strokeText(text, cx, cy);
      ctx.fillStyle = "white";
      ctx.fillText(text, cx, cy);

      const tex = new THREE.CanvasTexture(canvas);
      tex.anisotropy = this.renderer.capabilities.getMaxAnisotropy?.() || 1;

      const mat = new THREE.SpriteMaterial({ map: tex, transparent: true, depthTest: false });
      const sp = new THREE.Sprite(mat);

      // px→ワールドの変換係数（Lに比例させて見やすさ一定化）
      const k = (Z / 500); // 好みで調整
      sp.scale.set(canvas.width * k, canvas.height * k, 1);
      sp.renderOrder = 999;
      return sp;
    };

    const lx = makeLabelSprite("横巾 (x)");
    lx.position.set(X * 1.1, 0, 0);

    const ly = makeLabelSprite("縦巾 (y)");
    ly.position.set(0, Y * 1.1, 0);

    const lz = makeLabelSprite("厚み (z)");
    lz.position.set(0, 0, -(Z * 1.1));

    g.add(lx, ly, lz);

    // --- 6) シーンに追加 ---
    this.scene.add(g);
  }
}