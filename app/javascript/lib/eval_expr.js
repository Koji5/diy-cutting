// app/javascript/lib/eval_expr.js

/**
 * 安全な文脈で式を評価する（with + Function）
 * @param {string} expr - 評価する式（例: "width1_mm + 1"）
 * @param {object} ctx - 式内で使用する変数コンテキスト（{width1_mm: 30} など）
 * @returns {*} 評価結果（例: 31）または false（エラー時）
 */
export function evalExpr(expr, ctx) {
  try {
    return Function("o", `with(o){ return (${expr}) }`)(ctx);
  } catch (e) {
    console.warn("式評価エラー:", expr, ctx, e);
    return false;
  }
}
