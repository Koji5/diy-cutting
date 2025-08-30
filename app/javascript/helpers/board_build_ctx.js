export function boardBuildCtx(boardJSON){
  if (!boardJSON) return;
  const ctx = { L: boardJSON.length_mm, W: boardJSON.width_mm, T: boardJSON.thickness_mm }
  ["tl","tr","bl","br"].forEach(pos=>{
    let CX = 0, CY = 0;
    switch (pos) {
      case "tl": CX = 0; CY = ctx.W; break;
      case "tr": CX = ctx.L; CY = ctx.W; break;
      case "bl": CX = 0;  CY = 0; break;
      case "br": CX = ctx.L; CY = 0; break;
      default:
    }
    const posJSON = boardJSON.corner_json[pos]
    if (!posJSON) {
      console.warn("CORNER JSON Not Found:", JSON.stringify(pos), "len=", String(pos).length,
              "codes=", [...String(pos)].map(c => c.charCodeAt(0)));
      ctx[pos] = {
        type: "corner",
        cx: CX,
        cy: CY
      }
      return;
    }
    const DX = Number(posJSON?.dx ?? 0);
    const DY = Number(posJSON?.dy ?? 0);
    let signX = 1, signY = 1, pix = 0, piy = 0, startX = 0, startY = 0, endX = 0, endY = 0, posAxis = "";
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
          line: [
            [startX, startY], [endX, endY]
          ]
        }
        break;
      case "CHAMFER":
        {
          const point = (posAxis === "X") ? [endX, startY] : [startX, endY];
          process = {
            type: "line",
            line: [
              [startX, startY], [...point], [endX, endY]
            ]
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
              endAngle: endAngle
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
              endAngle: endAngle
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
      cx: CX,
      cy: CY,
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
  }
  ["b","r","t","l"].forEach(pos=>{
    const posJSON = boardJSON.side_json[pos];
    if (!posJSON) {
      console.warn("SIDE JSON Not Found:", JSON.stringify(pos), "len=", String(pos).length,
              "codes=", [...String(pos)].map(c => c.charCodeAt(0)));
      ctx[pos] = {
        type: "side"
      }
      return;
    }
    const startCorner= sideCorner[pos].start;
    const endCorner = sideCorner[pos].end;
    let startX, startY, endX, endY; 

  });
}