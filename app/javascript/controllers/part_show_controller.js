import { Controller } from "@hotwired/stimulus";
import { inflateGeometryFromJSON } from "helpers/geometry_serializers";
import * as THREE        from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";

export default class extends Controller {

  static values = { geometryUrl: String }

  async connect() {
    const loaderCtrl = this.application.getControllerForElementAndIdentifier(
      document.body, "page-loading"
    )
    const p = this._bootInitial();  // ← Promise を返す
    loaderCtrl?.register(p);        // ローダに登録
    await p;                        // 完了まで待ってから connect を抜ける
  }

  async _bootInitial() {
    this._initThree();
    this._setupResizeObserver();     // 下に例あり
    this._restoreCameraState();      // 同期でOK
    this.start();                    // アニメーションループ開始（あなたの既存）

    // 幾何のロード
    if (this.hasGeometryUrlValue) {
      const res = await fetch(this.geometryUrlValue);
      const geoJSON = await res.json();
      const geometry = inflateGeometryFromJSON(geoJSON);
      this.mesh = new THREE.Mesh(geometry, this.mat.clone());
      this.scene.add(this.mesh);
    }

    this._initCamera();              // 同期でOK
    this.render();                   // 1回描画

    // ★ 初回フレームが実際に画面に出るまで待つ
    await this._waitForFirstPaint();
  }

  // 「描画完了」待機ユーティリティ
  _waitForFirstPaint() {
    // 1回目のRAFでレンダコマンドがフラッシュされ、
    // 2回目のRAFの時点でフレームが表示されていることが多い
    return new Promise(resolve => {
      requestAnimationFrame(() => requestAnimationFrame(resolve));
    });
  }

  // ResizeObserver のセットアップ
  _setupResizeObserver() {
    this.resizeObs = new ResizeObserver(entries => {
      const { width, height } = entries[0].contentRect;
      if (!width || !height) return;
      this.renderer.setSize(width, height, false);
      this.camera.aspect = width / height;
      this.camera.updateProjectionMatrix();
      this.render();
    });
    this.resizeObs.observe(this.element);
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
    this.scene.background = new THREE.Color(0xfafaea);

    /* カメラ */
    this.camera = new THREE.PerspectiveCamera(45, 1, 1, 5000);
    this.camera.position.set(4, 4, 6);

    /* ライト */
    this.dirLight = new THREE.DirectionalLight(0xffffff, 1.2);
    this.dirLight.position.set(6, 8, 4);
    this.dirLight.castShadow = true;
    this.scene.add(this.dirLight);
    // 影品質（重要）
    this.dirLight.shadow.mapSize.set(2048, 2048);   // 解像度
    this.dirLight.shadow.camera.near = 1;
    this.dirLight.shadow.camera.far  = 30;
    this.dirLight.shadow.camera.left   = -10;
    this.dirLight.shadow.camera.right  =  10;
    this.dirLight.shadow.camera.top    =  15;
    this.dirLight.shadow.camera.bottom = -15;
    this.dirLight.shadow.bias = -0.0005;      // アクネ対策
    this.dirLight.shadow.normalBias = 0.02;   // モデルが厚い/スケールが大きい時に有効
    /* マテリアル */
    this.mat = new THREE.MeshStandardMaterial({
          color: 0x7d4712,
          transparent: true,   // ← 必須
          opacity: 0.5,       // 0(完全透明)〜1(不透明)
          depthWrite: true,   // 透過重なりのチラつき軽減に有効（必要に応じて）
          metalness: 0,
          roughness: 0.9,
          side: THREE.FrontSide, // 両面にしたいなら DoubleSide。ただし透過はアーティファクトが増えやすい
          flatShading: true
        });
    this.mat.needsUpdate = true;
    // 環境光は弱めに（影が見えやすい）
    this.scene.add(new THREE.AmbientLight(0xffffff, 0.1));
    // 背面光
    this.rim = new THREE.DirectionalLight(0xffffff, 0.9);
    this.rim.position.set(-6, -8, -4);
    this.rim.castShadow = false;
    this.scene.add(this.rim);
    /* レンダラー */
    this.renderer = new THREE.WebGLRenderer({ 
      antialias:             true,
      alpha:                 true,
      preserveDrawingBuffer: true
    });
    this.renderer.setPixelRatio(window.devicePixelRatio);
    /* 仮サイズで一旦 setSize —— 実サイズは ResizeObserver が上書き */
    this.renderer.setSize(1, 1, false);
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap; // 柔らかい影
    // ① プレースホルダを本物キャンバスに置き換え
    const ph = this.element.querySelector("canvas[data-part-show-target='canvas']");
    ph?.replaceWith(this.renderer.domElement);
    // 置き換えた canvas に 100% 指定を必ず付与
    Object.assign(this.renderer.domElement.style, {
      width: "100%",
      height: "100%",
      display: "block"
    });
    // ② data-attribute を付け直し (thumb_capture が拾いやすいように)
    this.renderer.domElement.dataset.partShowTarget = "canvas";

    /* Controls */
    this.controls = new OrbitControls(this.camera, this.renderer.domElement);
    this.controls.enableDamping = true;

    /* === ここで 1 フレーム描画して黒画面を防ぐ === */
    this.renderer.render(this.scene, this.camera);
  }

  _initCamera() {
    const box = new THREE.Box3().setFromObject(this.mesh);
    this._buildAxesAndLabels(box);
    const radius = box.getSize(new THREE.Vector3()).length() * 0.5;
    this.camera.near = 0.1;
    this.camera.far  = radius * 10;
    this.camera.updateProjectionMatrix();
  }

  _restoreCameraState() {
    const el = this._getCameraStateInput();
    if (!el) return;

    const raw = (el.value || "").trim();
    if (!raw) return;

    let st;
    try {
      st = JSON.parse(raw);
    } catch (e) {
      console.warn("camera_state_json の JSON パースに失敗:", e);
      return;
    }

    const isVec3 = (a) =>
      Array.isArray(a) && a.length === 3 && a.every((x) => Number.isFinite(+x));

    // pos / tgt / zoom の妥当性チェック
    if (!isVec3(st.pos) || !isVec3(st.tgt)) {
      console.warn("camera_state_json の pos/tgt が不正:", st);
      return;
    }

    const [px, py, pz] = st.pos.map(Number);
    const [tx, ty, tz] = st.tgt.map(Number);
    const zm = Number(st.zoom);

    // 反映（※ controls 初期化済みであること）
    const cam = this.camera;
    const ctr = this.controls;
    if (!cam || !ctr) {
      console.warn("camera/controls 未初期化のため復元スキップ");
      return;
    }

    cam.position.set(px, py, pz);
    ctr.target.set(tx, ty, tz);

    if (Number.isFinite(zm) && zm > 0) {
      cam.zoom = zm;               // Perspective でも zoom 反映可
      cam.updateProjectionMatrix();
    }

    ctr.update();
  }

  // 保存済みのカメラ状態を hidden に入れておく想定
  // <input type="hidden" id="camera_state_json" ...>
  _getCameraStateInput() {
    return (
      document.getElementById("camera_state_json")
    );
  }

  _buildAxesAndLabels(box = null) {
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
