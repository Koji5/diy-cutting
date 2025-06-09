require "mini_magick"

MiniMagick.configure do |config|
  config.cli = :imagemagick7   # ← これだけ
end
