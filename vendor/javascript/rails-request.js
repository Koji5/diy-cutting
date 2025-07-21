import { FetchRequest } from "@rails/request.js";

// イベント登録（Turboより先に処理したいので capture: true）
document.addEventListener("click", async (event) => {
  const link = event.target.closest("a[data-method]");
  if (!link || link.dataset.turbo === "false") return;

  const method = link.dataset.method?.toLowerCase();
  if (!method || method === "get") return;

  event.preventDefault();
  event.stopImmediatePropagation(); // Turboの介入を防ぐ

  const confirmMessage = link.dataset.confirm;
  if (confirmMessage && !window.confirm(confirmMessage)) return;

  try {
    await new FetchRequest(method, link.href).perform();
  } catch (e) {
    console.error("Request failed", e);
  }
}, true); // ← capture フェーズで登録（重要）
