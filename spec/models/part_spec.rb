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
  describe "異常系" do
    it "幅が 0mm のとき" do
      part.width1_mm = "0" 
      expect(part).to be_invalid
    end
    it "幅>長さ のとき" do
      part.width1_mm = "300" 
      part.length_mm = "299"
      expect(part).to be_invalid
    end
    it "穴と外周が重なっている状態"  do
      part.hole_tl_dx = "10"
      expect(part).to be_invalid
    end
  end
end
