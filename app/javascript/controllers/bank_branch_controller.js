// app/javascript/controllers/bank_branch_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "bankInput", "bankSuggestions", "bankCode",
    "branchInput", "branchSuggestions", "branchCode"
  ]

  timeout = null

  connect() {
    this.lastQuery = null
    this.lastBranchesQuery = null
    this.bankInputTarget.addEventListener("input", this.debounce(() => this.searchBanks(), 300))
    this.branchInputTarget.addEventListener("input", this.debounce(() => this.searchBranches(), 30))

    const bankCode = this.bankCodeTarget.value
    const branchCode = this.branchCodeTarget.value

    if (bankCode) {
      this.loadBankName(bankCode)
    }
    if (bankCode && branchCode) {
      this.loadBranchName(bankCode, branchCode)
    }

  }

  debounce(callback, delay = 300) {
    return (...args) => {
      clearTimeout(this.timeout)
      this.timeout = setTimeout(() => callback(...args), delay)
    }
  }

  // ------------------ 銀行名 ------------------

  async searchBanks() {
    const q = this.bankInputTarget.value.trim()

    // 🔁 直前と同じクエリならスキップ
    if (q === this.lastQuery) return
    this.lastQuery = q

    this.bankCodeTarget.value = ""
    this.dispatchBankChanged(null)

    if (!q) {
      this.bankSuggestionsTarget.hidden = true
      this.bankSuggestionsTarget.innerHTML = ""
      return
    }
    const res = await fetch(`/api/bank_branches/bank_search?q=${encodeURIComponent(q)}`)
    const banks = await res.json()

    this.bankSuggestionsTarget.innerHTML = banks.map(bank =>
      `<li class="list-group-item list-group-item-action py-1" data-code="${bank.code}" data-name="${bank.name}">${bank.name}</li>`
    ).join("")

    this.bankSuggestionsTarget.hidden = false

    this.bankSuggestionsTarget.querySelectorAll("li").forEach(li => {
      li.addEventListener("click", () => this.selectBank(li))
    })
  }

  selectBank(element) {
    const code = element.dataset.code
    const name = element.dataset.name
    this.bankInputTarget.value = name
    this.bankCodeTarget.value = code
    this.bankSuggestionsTarget.hidden = true
    this.bankSuggestionsTarget.innerHTML = ""

    this.dispatchBankChanged(code)
  }

  async loadBankName(bankCode) {
    try {
      const res = await fetch(`/api/bank_branches/bank/${bankCode}`)
      const bank = await res.json()
      this.bankInputTarget.value = bank.name
    } catch (error) {
      console.error("銀行名の取得に失敗しました", error)
      this.bankInputTarget.value = ""
    }
  }

  dispatchBankChanged(code) {
    this.branchInputTarget.value = ""
    this.branchCodeTarget.value = ""
    this.branchSuggestionsTarget.innerHTML = ""
    this.branchSuggestionsTarget.hidden = true
    this.currentBankCode = code
  }

  // ------------------ 支店名 ------------------

  async searchBranches() {
    const q = this.branchInputTarget.value.trim()
    // 🔁 直前と同じクエリならスキップ
    if (q === this.lastBranchesQuery) return
    this.lastBranchesQuery = q

    const bankCode = this.currentBankCode || this.bankCodeTarget.value

    if (!bankCode || !q) {
      this.branchSuggestionsTarget.hidden = true
      this.branchSuggestionsTarget.innerHTML = ""
      return
    }

    const res = await fetch(`/api/bank_branches/${bankCode}/branch_search?q=${encodeURIComponent(q)}`)
    const branches = await res.json()

    this.branchSuggestionsTarget.innerHTML = branches.map(branch =>
      `<li class="list-group-item list-group-item-action py-1" data-code="${branch.code}" data-name="${branch.name}">${branch.name}</li>`
    ).join("")

    this.branchSuggestionsTarget.hidden = false

    this.branchSuggestionsTarget.querySelectorAll("li").forEach(li => {
      li.addEventListener("click", () => this.selectBranch(li))
    })
  }

  selectBranch(element) {
    const code = element.dataset.code
    const name = element.dataset.name

    this.branchInputTarget.value = name
    this.branchCodeTarget.value = code
    this.branchSuggestionsTarget.hidden = true
    this.branchSuggestionsTarget.innerHTML = ""
  }

  async loadBranchName(bankCode, branchCode) {
    try {
      const res = await fetch(`/api/bank_branches/${bankCode}/branch_list`)
      const branches = await res.json()
      const match = branches.find(b => b.code === branchCode)
      if (match) {
        this.branchInputTarget.value = match.name
      }
    } catch (error) {
      console.error("支店名の取得に失敗しました", error)
      this.branchInputTarget.value = ""
    }
  }
}
