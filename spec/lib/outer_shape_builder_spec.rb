require "rails_helper"

RSpec.describe OuterShapeBuilder do
  let(:raw_ctx) do
    {
      shape_code:  "RECT",
      width1_mm:   100,
      width2_mm:   100,
      length_mm:   200,
      corner_proc_json: {},  # 角加工なし
      shape_json:  {}
    }
  end

  it "returns a closed polyline for RECT" do
    ctx  = CtxNormalizer.call(raw_ctx)
    poly = described_class.build_outer_path(ctx)

    # ① 始点と終点が同じ (= close 済み)
    expect(poly.first).to eq poly.last

    # ② 点数が 5 （矩形 4 点 + close 1 点）
    expect(poly.size).to eq 5
  end
end
