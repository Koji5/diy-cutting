RSpec.describe Part, type: :model do
  subject(:part) { build(:part) }

  # ─── 正常系：エラーがひとつでも出たら失敗 ───
  describe "正常データ" do
    it "is valid (no errors)" do
      expect(part).to be_valid                      # ① true/false 判定
      expect(part.errors).to be_empty               # ② 念のためエラー集合が空
    end
  end

  # ─── 異常系：エラーが 0 件なら失敗 ───
  describe "幅が 0mm のとき" do
    before { part.width1_mm = 0 }

    it "is invalid (any error counts)" do
      expect(part).to be_invalid                    # 少なくとも 1 件は出ること
    end
  end
end
