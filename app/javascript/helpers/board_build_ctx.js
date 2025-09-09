export function boardBuildCtx(boardJSON){
  const ctx = { L: boardJSON.length_mm, W: boardJSON.width_mm, T: boardJSON.thickness_mm };
  const { L, W, T } = ctx;

  const cornerJSON = boardJSON.corner_json || {};
  const sideJSON   = boardJSON.side_json   || {};
  const holeJSON   = boardJSON.hole_json   || {};
  console.log("holeJSON:", holeJSON);

  ["tl","tr","bl","br"].forEach(pos=>{
    let CX = 0, CY = 0;
    switch (pos) {
      case "tl": CX = 0; CY = W; break;
      case "tr": CX = L; CY = W; break;
      case "bl": CX = 0;  CY = 0; break;
      case "br": CX = L; CY = 0; break;
      default:
    }
    const posJSON = cornerJSON[pos] || null;
    if (!posJSON) {
      console.warn("CORNER JSON Not Found:", JSON.stringify(pos), "len=", String(pos).length,
              "codes=", [...String(pos)].map(c => c.charCodeAt(0)));
      ctx[pos] = {
        type: "corner",
        corner: [CX, CY],
        start: [CX, CY],
        end: [CX, CY]
      }
      if (pos === "bl") ctx.moveTo = [0, 0];
      return;
    }
    const DX = Number(posJSON?.dx ?? 0);
    const DY = Number(posJSON?.dy ?? 0);
    let signX = 1, signY = 1, pix = 0, piy = 0, startX = 0, startY = 0, endX = 0, endY = 0, posAxis = "", moveTo = [];
    switch (pos) {
      case "tl":
        signX = +1; signY = -1;
        pix = Math.PI / 2; piy = Math.PI;
        startX = DX; startY = CY; endX = 0; endY = CY - DY;
        posAxis = "Y";
        break;
      case "tr":
        signX = -1; signY = -1;
        pix = Math.PI / 2; piy = 0;
        startX = CX; startY = CY - DY; endX = CX - DX; endY = CY;
        posAxis = "X";
        break;
      case "bl":
        signX = +1; signY = +1; pix = -Math.PI / 2; piy = Math.PI;
        startX = 0; startY = DY; endX = DX; endY = 0;
        posAxis = "X";
        ctx.moveTo = [startX, startY];
        break;
      case "br":
        signX = -1; signY = +1; pix = -Math.PI / 2; piy = 0;
        startX = CX - DX; startY = 0; endX = CX; endY = DY;
        posAxis = "Y";
        break;
      default:
    }
    const h = DX > DY ? DY : DX;
    const l = DX > DY ? DX : DY;
    const r = h === 0 ? 0 : ((l * 2) ** 2) / (8 * h) + h / 2;
    const theta = r === 0 ? 0 : Math.asin(l / r);
    let process = null;
    switch(posJSON.proc) {
      case "BEVEL":
        process = {
          type: "line",
          line: [[startX, startY], [endX, endY] ]
        }
        break;
      case "CHAMFER":
        {
          const point = (posAxis === "X") ? [endX, startY] : [startX, endY];
          process = {
            type: "line",
            line: [ [startX, startY], [...point], [endX, endY] ]
          }
        }
        break;
      case "ROUND_R":
        {
          const sx = DX > DY ? CX + signX * DX : CX + signX * r;
          const sy = DX > DY ? CY + signY * r : CY + signY * DY;
          let startAngle = 0, endAngle = 0;
          if (DX > DY) {
            if (pos === "tl" || pos === "br"){
              startAngle = pix;
              endAngle = pix - signX * signY * theta;
            } else {
              startAngle = pix - signX * signY * theta;
              endAngle = pix;
            }
          } else {
            if (pos === "tl" || pos === "br"){
              startAngle = piy + signX * signY * theta;
              endAngle = piy;
            } else {
              startAngle = piy;
              endAngle = piy + signX * signY * theta;
            }
          }
          process = {
            type: "arc",
            arc: {
              center: [sx, sy],
              r: r,
              startAngle: startAngle,
              endAngle: endAngle,
              wise: false
            }
          }
        }
        break;
      case "INROUND":
        {
          const sx = DX > DY ? CX : CX + signX * (DX - r);
          const sy = DX > DY ? CY + signY * (DY - r) : CY;
          let startAngle = 0, endAngle = 0;
          if (DX > DY) {
            if (pos === "tl" || pos === "br"){
              startAngle = -pix - signX * signY * theta;
              endAngle = -pix;
            } else {
              startAngle = -pix;
              endAngle = -pix - signX * signY * theta;
            }
          } else {
            if (pos === "tl" || pos === "br"){
              startAngle =  Math.PI - piy;
              endAngle = Math.PI - piy + signX * signY * theta;
            } else {
              startAngle = Math.PI - piy + signX * signY * theta;
              endAngle = pix + Math.PI / 2;
            }
          }
          process = {
            type: "arc",
            arc: {
              center: [sx, sy],
              r: r,
              startAngle: startAngle,
              endAngle: endAngle,
              wise: true
            }
          }
        }
        break;
      default:
    }
    ctx[pos] = {
      type: "corner",
      proc: posJSON.proc,
      edge: posJSON.edge,
      dx: DX,
      dy: DY,
      longerAxis: DY - DX > 0 ? "DY" : "DX",
      corner: [CX, CY],
      start: [startX, startY],
      end: [endX, endY]
    }
    if (process) ctx[pos].process = process;
  });
  const sideCorner = {
    b: {start: "bl", end: "br"},
    r: {start: "br", end: "tr"},
    t: {start: "tr", end: "tl"},
    l: {start: "tl", end: "bl"},
  };
  ["b","r","t","l"].forEach(pos=>{
    const posJSON = sideJSON[pos] || null;
    const proc = posJSON?.proc ?? "NONE";
    const startSide = ctx[sideCorner[pos].start].end;
    const endSide = ctx[sideCorner[pos].end].start;
    const SD = Number(posJSON?.sd ?? 0);
    const SW = Number(posJSON?.sw ?? 0);
    const SP = Number(posJSON?.sp ?? 0);
    if (SD === 0 || SW === 0 || SP === 0){
      ctx[pos] = {
        type: "side",
        proc: proc,
        edge: posJSON?.edge ?? "NONE",
        start: startSide,
        end: endSide
      }
      return;
    }
    const r = (SD ** 2) / (8 * SW) + SW / 2;
    const theta = Math.asin(SD / (2 * r));
    const d = r * Math.cos(theta);
    let sx1 = 0, sx2 = 0, sx3 = 0, sx4 = 0, pi = 0, sy1 = 0, sy2 = 0, sy3 = 0, sy4 = 0, sx = 0, sy = 0;
    switch (pos) {
      case "t":
        sx4 = SP - SD / 2; sy4 = W;
        sx3 = SP - SD / 2; sy3 = W - SW;
        sx2 = SP + SD / 2; sy2 = W - SW;
        sx1 = SP + SD / 2; sy1 = W;
        sx = SP; sy = W + d;
        pi = -Math.PI / 2;
        break;
      case "r":
        sx4 = L; sy4 = SP + SD / 2;
        sx3 = L - SW; sy3 = SP + SD / 2;
        sx2 = L - SW; sy2 = SP - SD / 2;
        sx1 = L; sy1 = SP - SD / 2;
        sx = L + d; sy = SP;
        pi = Math.PI;
        break;
      case "b":
        sx4 = SP + SD / 2; sy4 = 0;
        sx3 = SP + SD / 2; sy3 = SW;
        sx2 = SP - SD / 2; sy2 = SW;
        sx1 = SP - SD / 2; sy1 = 0;
        sx = SP; sy = -d;
        pi = Math.PI / 2;
        break;
      case "l":
        sx4 = 0; sy4 = SP - SD / 2;
        sx3 = SW; sy3 = SP - SD / 2;
        sx2 = SW; sy2 = SP + SD / 2;
        sx1 = 0; sy1 = SP + SD / 2;
        sx = -d; sy = SP;
        pi = 0;
        break;
      default:
    }
    let process = null
    switch(proc) {
      case "SQUARE":
        {
          if (SD !== 0 && SW !== 0 && SP !== 0){
            process = {
              type: "line",
              line: [ 
                [sx1,  sy1],
                [sx2,  sy2],
                [sx3,  sy3],
                [sx4,  sy4]
              ]
            }
          }
        }
        break;
      case "ROUND":
        {
          if (SD / 2 < SW){
            console.warn("SD / 2 < SW pos:", JSON.stringify(pos), "len=", String(pos).length,
                    "codes=", [...String(pos)].map(c => c.charCodeAt(0))), " proc:", JSON.stringify(posJSON.proc), "len=", String(posJSON.proc).length,
                    "codes=", [...String(posJSON.proc)].map(c => c.charCodeAt(0))
          } else {
            process = {
              type: "arc",
              arc: {
                center: [sx, sy],
                r: r,
                startAngle: pi + theta,
                endAngle: pi - theta
              },
              startPoint: [sx1,  sy1],
              endPoint: [sx4,  sy4]
            }
          }
        }
        break;
      case "NONE":
      default:
    }
    ctx[pos] = {
      type: "side",
      proc: proc,
      edge: posJSON?.edge ?? null,
      start: startSide,
      end: endSide
    }
    if (process) ctx[pos].process = process;
  });

  // ネジ・ダボ穴
  ctx["hole"] = {};
  Object.keys(holeJSON).forEach(key => {
    const hole = holeJSON[key];
    const surface =  hole?.surface ?? "";
    const dx = Number(hole?.dx ?? 0);
    const dy = Number(hole?.dy ?? 0);
    let rad = [0, 0, 0], trans = [0, 0, 0];
    switch(surface) {
      case "LEFT": rad = [0, -Math.PI / 2, 0]; trans = [0, dy, -T / 2]; break;
      case "RIGHT": rad = [0, Math.PI / 2, 0]; trans = [L, dy, -T / 2]; break;
      case "TOP": rad = [-Math.PI / 2, 0, 0]; trans = [dx, W, -T / 2]; break;
      case "BOTTOM": rad = [Math.PI / 2, 0, 0]; trans = [dx, 0, -T / 2]; break;
      case "FRONT": rad = [0, 0, 0]; trans = [dx, dy, 0]; break;
      case "BACK": rad = [Math.PI, 0, 0]; trans = [dx, dy, -T]; break;
      default:
    }
    ctx["hole"][key] = {
      surface: surface,
      dx: dx, dy: dy,
      spec_code: hole?.spec_code ?? "",
      countersink: hole?.countersink ?? false,
      depth: Number(hole?.depth ?? 0),
      rad: rad, trans: trans
    };
  });

  return ctx;
}