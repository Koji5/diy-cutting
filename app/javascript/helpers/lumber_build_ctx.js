export function lumberBuildCtx(lumberJSON){
  const ctx = { L: lumberJSON.length_mm, W: lumberJSON.width_mm, T: lumberJSON.thickness_mm };
  const { W, T } = ctx;
  ctx.moveTo = [0, 0];
  const sideJSON   = lumberJSON.side_json || {};
  const holeJSON   = lumberJSON.hole_json || {};
  ctx.sideJSON = sideJSON;
  ctx.holeJSON = holeJSON;
  const proc = sideJSON["c"]?.proc ?? "NONE";
  if (proc === "NONE") {
    ctx.moveTo = [0, 0];
    ctx["b"] = { type: "side", start: [0, 0], end: [T, 0] }
    ctx["r"] = { type: "side", start: [T, 0], end: [T, W] }
    ctx["t"] = { type: "side", start: [T, W], end: [0, W] }
    ctx["l"] = { type: "side", start: [0, W], end: [0, 0] }
    return ctx;
  } else {
    switch(proc){
      case "CHAMF_BTH":
        ctx.moveTo = [0, 1];
        ctx["bl"] = { type: "corner", corner: [0, 0], process: [{ type: "line", start: [0, 1], end: [1, 0] } ] };
        ctx["b"] = { type: "side", start: [1, 0], end: [T - 1, 0] };
        ctx["br"] = { type: "corner", corner: [T, 0], process: [{ type: "line", start: [T - 1, 0], end: [T, 1] } ] };
        ctx["r"] = { type: "side", start: [T, 1], end: [T, W - 1] };
        ctx["tr"] = { type: "corner", corner: [T, W], process: [{ type: "line", start: [T, W - 1], end: [T - 1, W] } ] };
        ctx["t"] = { type: "side", start: [T - 1, W], end: [1, W] };
        ctx["tl"] = { type: "corner", corner: [0, W], process: [{ type: "line", start: [1, W], end: [0, W - 1] } ] };
        ctx["l"] = { type: "side", start: [0, W - 1], end: [0, 1] };
        break;
      case "CHM5MM":
        ctx.moveTo = [0, 5];
        ctx["bl"] = { type: "corner", corner: [0, 0], process: [{ type: "line", start: [0, 5], end: [5, 0] } ] };
        ctx["b"] = { type: "side", start: [5, 0], end: [T - 5, 0] };
        ctx["br"] = { type: "corner", corner: [T, 0], process: [{ type: "line", start: [T - 5, 0], end: [T, 5] } ] };
        ctx["r"] = { type: "side", start: [T, 5], end: [T, W - 5] };
        ctx["tr"] = { type: "corner", corner: [T, W], process: [{ type: "line", start: [T, W - 5], end: [T - 5, W] } ] };
        ctx["t"] = { type: "side", start: [T - 5, W], end: [5, W] };
        ctx["tl"] = { type: "corner", corner: [0, W], process: [{ type: "line", start: [5, W], end: [0, W - 5] } ] };
        ctx["l"] = { type: "side", start: [0, W - 5], end: [0, 5] };
        break;
      case "CHM10MM":
        ctx.moveTo = [0, 10];
        ctx["bl"] = { type: "corner", corner: [0, 0], process: [{ type: "line", start: [0, 10], end: [10, 0] } ] };
        ctx["b"] = { type: "side", start: [10, 0], end: [T - 10, 0] };
        ctx["br"] = { type: "corner", corner: [T, 0], process: [{ type: "line", start: [T - 10, 0], end: [T, 10] } ] };
        ctx["r"] = { type: "side", start: [T, 10], end: [T, W - 10] };
        ctx["tr"] = { type: "corner", corner: [T, W], process: [{ type: "line", start: [T, W - 10], end: [T - 10, W] } ] };
        ctx["t"] = { type: "side", start: [T - 10, W], end: [10, W] };
        ctx["tl"] = { type: "corner", corner: [0, W], process: [{ type: "line", start: [10, W], end: [0, W - 10] } ] };
        ctx["l"] = { type: "side", start: [0, W - 10], end: [0, 10] };
        break;
      case "R5ROUND":
        {
          const processBl = {
            type: "arc", start: [0, 5], end: [5, 0],
            arc: { center: [5, 5], r: 5, startAngle: Math.PI, endAngle: -Math.PI / 2, wise: false }
          }
          const processBr = {
            type: "arc", start: [T - 5, 0], end: [T, 5],
            arc: { center: [T - 5, 5], r: 5, startAngle: -Math.PI / 2, endAngle: 0, wise: false }
          }
          const processTr = {
            type: "arc", start: [T, W - 5], end: [T - 5, W],
            arc: { center: [T - 5, W - 5], r: 5, startAngle: 0, endAngle: Math.PI / 2, wise: false }
          }
          const processTl = {
            type: "arc", start: [5, W], end: [0, W - 5],
            arc: { center: [5, W - 5], r: 5, startAngle: Math.PI / 2, endAngle: Math.PI, wise: false }
          }
          ctx.moveTo = [0, 5];
          ctx["bl"] = { type: "corner", corner: [0, 0], process: [processBl] };
          ctx["b"] = { type: "side", start: [5, 0], end: [T - 5, 0] };
          ctx["br"] = { type: "corner", corner: [T, 0], process: [processBr] };
          ctx["r"] = { type: "side", start: [T, 5], end: [T, W - 5] };
          ctx["tr"] = { type: "corner", corner: [T, W], process: [processTr] };
          ctx["t"] = { type: "side", start: [T - 5, W], end: [5, W] };
          ctx["tl"] = { type: "corner", corner: [0, W], process: [processTl] };
          ctx["l"] = { type: "side", start: [0, W - 5], end: [0, 5] };
        }
        break;
      case "R10ROUND":
        {
          const processBl = {
            type: "arc", start: [0, 10], end: [10, 0],
            arc: { center: [10, 10], r: 10, startAngle: Math.PI, endAngle: -Math.PI / 2, wise: false }
          }
          const processBr = {
            type: "arc", start: [T - 10, 0], end: [T, 10],
            arc: { center: [T - 10, 10], r: 10, startAngle: -Math.PI / 2, endAngle: 0, wise: false }
          }
          const processTr = {
            type: "arc", start: [T, W - 10], end: [T - 10, W],
            arc: { center: [T - 10, W - 10], r: 10, startAngle: 0, endAngle: Math.PI / 2, wise: false }
          }
          const processTl = {
            type: "arc", start: [10, W], end: [0, W - 10],
            arc: { center: [10, W - 10], r: 10, startAngle: Math.PI / 2, endAngle: Math.PI, wise: false }
          }
          ctx.moveTo = [0, 10];
          ctx["bl"] = { type: "corner", corner: [0, 0], process: [processBl] };
          ctx["b"] = { type: "side", start: [10, 0], end: [T - 10, 0] };
          ctx["br"] = { type: "corner", corner: [T, 0], process: [processBr] };
          ctx["r"] = { type: "side", start: [T, 10], end: [T, W - 10] };
          ctx["tr"] = { type: "corner", corner: [T, W], process: [processTr] };
          ctx["t"] = { type: "side", start: [T - 10, W], end: [10, W] };
          ctx["tl"] = { type: "corner", corner: [0, W], process: [processTl] };
          ctx["l"] = { type: "side", start: [0, W - 10], end: [0, 10] };
        }
        break;
      default:
    }
    return ctx;
  }
}