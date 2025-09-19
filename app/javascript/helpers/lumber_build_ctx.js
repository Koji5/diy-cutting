export function lumberBuildCtx(lumberJSON){
  const ctx = { L: lumberJSON.length_mm, W: lumberJSON.width_mm, T: lumberJSON.thickness_mm };
  const { L, W, T } = ctx;
  ctx.moveTo = [0, 0];

  return ctx;
}