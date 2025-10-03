import { Controller }    from "@hotwired/stimulus";
import * as THREE        from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import { buildMeshesFromCtx } from "helpers/lumber_builders"

export default class extends Controller {

  cameraInitialized = false;
  lastL = 0;
  lastW = 0;
  lastT = 0;
  lumberMeshes = {};
  _restoringCamera = false;
  _cameraSyncEnabled = false;
  _restoredCameraOnce = false;

  connect () {
    /* Three.js --------------------------------- */
    this._initThree()
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
    this._restoreCameraState();

    this.controls.addEventListener("change", () => this._syncCameraState());
    this._cameraSyncEnabled = true;
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
    this.scene.background = new THREE.Color(0xecfeff);

    /* グループ */
    this.group = new THREE.Group();
    this.group.name = "side_json";
    this.scene.add(this.group);

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
    this.lumberMat = new THREE.MeshStandardMaterial({
          color: 0x7d4712,
          transparent: true,   // ← 必須
          opacity: 0.5,       // 0(完全透明)〜1(不透明)
          depthWrite: true,   // 透過重なりのチラつき軽減に有効（必要に応じて）
          metalness: 0,
          roughness: 0.9,
          side: THREE.FrontSide, // 両面にしたいなら DoubleSide。ただし透過はアーティファクトが増えやすい
          flatShading: true
        });
    this.lumberMat.needsUpdate = true;
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
    const ph = this.element.querySelector("canvas[data-lumber-part3d-target='canvas']");
    ph?.replaceWith(this.renderer.domElement);
    // 置き換えた canvas に 100% 指定を必ず付与
    Object.assign(this.renderer.domElement.style, {
      width: "100%",
      height: "100%",
      display: "block"
    });
    // ② data-attribute を付け直し (thumb_capture が拾いやすいように)
    this.renderer.domElement.dataset.lumberPart3dTarget = "canvas";

    /* Controls */
    this.controls = new OrbitControls(this.camera, this.renderer.domElement);
    this.controls.enableDamping = true;

    /* === ここで 1 フレーム描画して黒画面を防ぐ === */
    this.renderer.render(this.scene, this.camera);
  }

  setMeshVisibilityAtPath(path, visible) {
    console.log("path:", path)
    if (path[path.length - 1] === "c") {
      this.group.visible = !!visible;
      return true;
    }
    const mesh = this._getAtPath(this.lumberMeshes, path);
    if (mesh?.isMesh || mesh instanceof THREE.Mesh) {
      mesh.visible = !!visible;
      return true;                 // 成功
    }
    return false;                  // 見つからず/非Mesh
  }
  _getAtPath(obj, path) {
    return path.reduce((cur, key) => {
      if (cur == null) return cur;
      return cur[/^\d+$/.test(key) ? Number(key) : key];
    }, obj);
  }

  /*====================== モデル更新 ====================*/
  updateModel (formJSON) {
    if (!this.camera) return
    const lumberJSON = formJSON.part.lumber_part
    if(lumberJSON.lumber_size_code){
      const [w, t] = lumberJSON.lumber_size_code.split(/[x×]/).map(s => Number(s.trim()));
      lumberJSON.width_mm     = w
      lumberJSON.thickness_mm = t
      this._replaceMesh(null);
    }
    lumberJSON.length_mm    = Number(lumberJSON.length_mm)

    /* 入力不足 → メッシュを消して終わり */
    if (!lumberJSON.length_mm || !lumberJSON.thickness_mm || !lumberJSON.width_mm) {
      this._replaceMesh(null);
      return;
    }
    console.log(lumberJSON)
    /* Geometry 生成 */
    this.lumberMeshes = buildMeshesFromCtx(lumberJSON);
    this._replaceMesh(this.lumberMeshes.lumber);
    this.lumberMeshes.lumber.material = this.lumberMat.clone();
    let sideDisp = false;
    this._forEachMesh(this.lumberMeshes, (mesh, path) => {
      if (path[path.length - 2] === "c") {
        const dispPath = [...path.slice(0, -1), "disp"]
        sideDisp = this._getValueByPath(lumberJSON, dispPath) === true;
        this.group.attach(mesh);
      } else {
        const dispPath = [...path, "disp"]
        const isLumberTop = (path.length === 1 && path[0] === "lumber") || this._getValueByPath(lumberJSON, dispPath) === true;
        mesh.visible = isLumberTop;   // lumber だけ true、他は false
        this.scene.add(mesh)
      }
    });
    this.group.visible = sideDisp;
    const box = new THREE.Box3().setFromObject(this.lumberMeshes.lumber);
    console.log("cameraInside?", box.containsPoint(this.camera.position));
    if (isFinite(box.max.x)) {
      const center = box.getCenter(new THREE.Vector3());
      const cameraReset = this.lastL !== lumberJSON.length_mm || this.lastW !== lumberJSON.width_mm || this.lastT !== lumberJSON.thickness_mm
      /* ★ 初回だけ固定アングルにセット（ただし復元済みならスキップ） */
      if ((!this.cameraInitialized || cameraReset) && !this._restoredCameraOnce) {
        /* ① モデル中心から “斜め前上” 方向へ伸ばす距離を計算  */
        const dir = new THREE.Vector3(0, 1, 5).normalize();  // 視線方向 (縦-横比同じ)

        /* ② 半径 r × 4 だけ離す ── 数字を大きくすると遠ざかる */
        const r = box.getSize(new THREE.Vector3()).length() * 0.5;  // ≈ bounding sphere 半径
        this.camera.position.copy(center).addScaledVector(dir, r * 4);
        this.controls.target.copy(center);    // ← ② モデル中心を見る
        this.controls.update();               // ← ③ 行列を同期
        this.cameraInitialized = true;        // フラグを立てる
        this.lastL = lumberJSON.length_mm
        this.lastW = lumberJSON.width_mm
        this.lastT = lumberJSON.thickness_mm
      }
      this._buildAxesAndLabels(box);
      /* --- クリップ面は毎回更新（大型モデル対策） --- */
      const radius = box.getSize(new THREE.Vector3()).length() * 0.5;
      this.camera.near = 0.1;
      this.camera.far  = radius * 10;
      this.camera.updateProjectionMatrix();
    }
    this.render()
  }

  _forEachMesh(node, fn, path = []) {
    if (!node) return;
    if (node instanceof THREE.Mesh) {
      fn(node, path);
    } else if (Array.isArray(node)) {
      node.forEach((child, i) => this._forEachMesh(child, fn, path.concat(String(i))));
    } else if (typeof node === "object") {
      for (const key in node) {
        this._forEachMesh(node[key], fn, path.concat(key));
      }
    }
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
        console.log("DISPOSE CHECK:",
          "lumberMat", this.lumberMat?.uuid
        );
        const mat = me.material
        if (Array.isArray(mat)) mat.forEach(m => m?.dispose?.())
        else mat?.dispose?.()
      })
    }
    this.mesh = mesh;
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

    const lx = makeLabelSprite("長さ(x)");
    lx.position.set(X * 1.1, 0, 0);

    const ly = makeLabelSprite("縦巾 (y)");
    ly.position.set(0, Y * 1.1, 0);

    const lz = makeLabelSprite("厚み (z)");
    lz.position.set(0, 0, -(Z * 1.1));

    g.add(lx, ly, lz);

    // --- 6) シーンに追加 ---
    this.scene.add(g);
  }

  _getValueByPath(obj, path) {
    return path.reduce((acc, key) => acc?.[key], obj)
  }

  // サムネイル
  async captureBlob({ maxWidth = 640, quality = 0.85, mime = "image/jpeg" } = {}) {
    const src = this.renderer?.domElement;
    if (!src || src.width === 0 || src.height === 0) return null;

    // 最新フレームを描画
    this.controls?.update?.();
    this.renderer.render(this.scene, this.camera);

    const scale = Math.min(1, maxWidth / src.width);
    if (scale < 1) {
      const off = document.createElement("canvas");
      off.width = Math.round(src.width * scale);
      off.height = Math.round(src.height * scale);
      off.getContext("2d").drawImage(src, 0, 0, off.width, off.height);
      return await new Promise(resolve => off.toBlob(b => resolve(b), mime, quality));
    } else {
      return await new Promise(resolve => src.toBlob(b => resolve(b), mime, quality));
    }
  }

  getGeometry() {
    return this.lumberMeshes.lumber.geometry;
  }

  // 保存済みのカメラ状態を hidden に入れておく想定
  // <input type="hidden" id="camera_state_json" ...>
  _getCameraStateInput() {
    return (
      document.getElementById("camera_state_json") ||
      document.querySelector('input[name="part[lumber_part_attributes][camera_state_json]"]') ||
      document.querySelector('input[name$="[camera_state_json]"]')
    );
  }
  _syncCameraState() {
    if (!this._cameraSyncEnabled || this._restoringCamera) return;
    const cam  = this.camera;
    const el  = this._getCameraStateInput();
    if (!cam || !el) return;
    const json = JSON.stringify({
      pos:  [cam.position.x, cam.position.y, cam.position.z],
      tgt:  [this.controls.target.x, this.controls.target.y, this.controls.target.z],
      zoom: cam.zoom
    });
    el.value = json;
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
    this._restoringCamera = true;

    cam.position.set(px, py, pz);
    ctr.target.set(tx, ty, tz);

    if (Number.isFinite(zm) && zm > 0) {
      cam.zoom = zm;               // Perspective でも zoom 反映可
      cam.updateProjectionMatrix();
    }

    ctr.update();
    this._restoringCamera = false;
    // ★ 復元できたので、以後は初期アングル当てない
    this._restoredCameraOnce = true;
    this.cameraInitialized = true;   // 既存ロジックとの互換のため
    this._cameraSyncEnabled = true;
    this._syncCameraState();
  }

}