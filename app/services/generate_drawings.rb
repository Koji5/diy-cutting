# app/services/generate_drawings.rb
class GenerateDrawings
  def self.call(payload)
    dim = PythonClient.dxf_dimensioned(payload)
    cam = PythonClient.dxf_cam(payload)
    pdf = PythonClient.pdf(payload)

    base = (payload["title"].presence || "drawing")
    now  = Time.current.strftime("%Y%m%d_%H%M%S")

    {
      pdf:     { bytes: pdf, filename: "#{base}_#{now}.pdf",     content_type: "application/pdf" },
      dxf_dim: { bytes: dim, filename: "#{base}_dim_#{now}.dxf", content_type: "application/dxf" },
      dxf_cam: { bytes: cam, filename: "#{base}_cam_#{now}.dxf", content_type: "application/dxf" }
    }
  end
end
