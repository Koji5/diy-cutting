# Rails 8 / Ruby 3.3
require "net/http"
require "json"
require "uri"

class PythonClient
  HOST = ENV.fetch("PY_HOST", "py")     # docker-compose の service 名
  PORT = ENV.fetch("PY_PORT", "8000")

  def self.post_bytes(path, payload)
    uri = URI("http://#{HOST}:#{PORT}#{path}")
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req.body = JSON.generate(payload)

    Net::HTTP.start(uri.host, uri.port, read_timeout: 120, open_timeout: 5) do |http|
      res = http.request(req)
      unless res.is_a?(Net::HTTPSuccess)
        ct = res["Content-Type"]
        body_preview = res.body&.byteslice(0, 800)
        raise "Python service error: #{res.code} #{ct} #{body_preview}"
      end
      res.body
    end
  end

  def self.pdf(payload)         = post_bytes("/pdf/drawing", payload)
  def self.dxf_dimensioned(p)   = post_bytes("/dxf/dimensioned", p)
  def self.dxf_cam(p)           = post_bytes("/dxf/cam", p)
end
