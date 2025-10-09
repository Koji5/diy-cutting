class DrawingTestsController < ApplicationController
  require "base64"
  before_action :set_tmp_ns
  skip_before_action :verify_authenticity_token, only: [:preview_images]
  def new
    @payload_json = params[:payload_json].presence || default_payload
    render_flash_and_replace_main(
        template: "drawing_tests/new",
        assigns: {payload_json: @payload_json}
    )
  end
  # 3種まとめて「生成のみ」（保存先は Rails.cache）
  def generate_all
    payload = JSON.parse(params.require(:payload_json))
    files = GenerateDrawings.call(payload)

    write_tmp(:pdf,     files[:pdf][:bytes],     filename: files[:pdf][:filename],     mime: files[:pdf][:content_type])
    write_tmp(:dxf_dim, files[:dxf_dim][:bytes], filename: files[:dxf_dim][:filename], mime: files[:dxf_dim][:content_type])
    write_tmp(:dxf_cam, files[:dxf_cam][:bytes], filename: files[:dxf_cam][:filename], mime: files[:dxf_cam][:content_type])

    #dim = PythonClient.dxf_dimensioned(payload)
    #cam = PythonClient.dxf_cam(payload)
    #pdf = PythonClient.pdf(payload)

    # ファイル名・MIME
    #base = (payload["title"].presence || "drawing")
    #now  = Time.now.strftime("%Y%m%d_%H%M%S")

    #cache_write(:dxf_dim, dim, filename: "#{base}_dim_#{now}.dxf", mime: "application/dxf")
    #cache_write(:dxf_cam, cam, filename: "#{base}_cam_#{now}.dxf", mime: "application/dxf")
    #cache_write(:pdf,     pdf, filename: "#{base}_#{now}.pdf",    mime: "application/pdf")

    # ビューで存在チェックはしない前提なので、通知だけ返す（Turbo/HTML両対応）
    flash[:notice] = "3ファイルを生成しました。ダウンロードで取得してください。"
    render_flash_and_replace(
        flash: flash
    )
  rescue JSON::ParserError => e
    flash[:alert] = "JSONエラー: #{e.message}"
    render_flash_and_replace(
        flash: flash
    )
  rescue => e
    flash[:alert] = "生成失敗: #{e.message}"
    render_flash_and_replace(
        flash: flash
    )
  end

  # 個別ダウンロード（ビュー側チェック無し。無ければ404）
  def download
    kind = params.require(:kind).to_sym # :pdf | :dxf_dim | :dxf_cam
    h = read_tmp(kind)
    #h = Rails.cache.read(cache_key(kind))
    return head :not_found unless h

    send_data h[:bytes], filename: h[:filename], type: h[:mime], disposition: "attachment"
  end

  def preview_images
    payload = JSON.parse(params.require(:payload_json))

    base_svg = PythonClient.post_bytes("/preview/base.svg", payload)
    dim_png  = PythonClient.post_bytes("/preview/dim.png",  payload)
    cam_png  = PythonClient.post_bytes("/preview/cam.png",  payload)

    render json: {
      base_svg: "data:image/svg+xml;base64," + Base64.strict_encode64(base_svg),
      dim_png:  "data:image/png;base64,"     + Base64.strict_encode64(dim_png),
      cam_png:  "data:image/png;base64,"     + Base64.strict_encode64(cam_png)
    }
  rescue JSON::ParserError => e
    render json: { error: "JSONエラー: #{e.message}" }, status: 422
  rescue => e
    render json: { error: "プレビュー失敗: #{e.message}" }, status: 500
  end

  private

  def set_tmp_ns
    uid = (defined?(current_user) && current_user&.id) || session.id
    @tmp_root = Rails.root.join("tmp/draw_cache", "drawing_tests", uid.to_s)
    FileUtils.mkdir_p(@tmp_root)
  end

  def tmp_payload_path(kind) = @tmp_root.join("#{kind}")
  def tmp_meta_path(kind)    = @tmp_root.join("#{kind}.meta.json")

  def write_tmp(kind, bytes, filename:, mime:)
    File.binwrite(tmp_payload_path(kind), bytes)
    File.write(tmp_meta_path(kind), { filename:, mime: }.to_json)
  end

  def read_tmp(kind)
    p = tmp_payload_path(kind)
    m = tmp_meta_path(kind)
    return nil unless File.exist?(p) && File.exist?(m)
    meta = JSON.parse(File.read(m), symbolize_names: true)
    { bytes: File.binread(p), filename: meta[:filename], mime: meta[:mime] }
  end

  def default_payload
    JSON.pretty_generate({
      "title": "板 100x50",
      "polylines": [
        { "layer": "OUTER", "closed": true, "points": [[0,0],[100,0],[100,50],[0,50]] }
      ],
      "circles": [
        { "layer": "DRILL", "center": [20,20], "r": 3 }
      ],
      "dimensions": [
        { "kind":"aligned", "p1":[0,0], "p2":[100,0], "base":[50,-10],
          "override": { "dimtxt": 3.5, "dimasz": 2.0 } },
        { "kind":"aligned", "p1":[0,0], "p2":[0,50], "base":[-10,25],
          "override": { "dimtxt": 3.5, "dimasz": 2.0 } },
        { "kind":"aligned", "p1":[0,20], "p2":[20,20], "base":[10,-15],
          "override": { "dimtxt": 3.5 } },
        { "kind":"aligned", "p1":[20,0], "p2":[20,20], "base":[-15,10],
          "override": { "dimtxt": 3.5 } }
      ]
    })
#    JSON.pretty_generate({
#      title: "板 100x50",
#      polylines: [{ layer: "OUTER", closed: true, points: [[0,0],[100,0],[100,50],[0,50]] }],
#      circles:   [{ layer: "DRILL", center: [20,20], r: 3 }],
#      dimensions:[{ kind: "linear", p1: [0,0], p2: [100,0], base: [50,-10], override: { "dimtxt": 3.5 } }]
#    })
  end
end
