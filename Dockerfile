# ベースイメージ
FROM ruby:3.3-alpine

# OS パッケージをインストール
RUN apk add --no-cache \
      build-base \
      postgresql-dev \
      postgresql-client \
      yaml-dev \
      tzdata \
      nodejs \
      npm \
      yarn \
      git \
      geos geos-dev
# ImageMagick を追加（MiniMagick が呼び出す CLI）
RUN apk add --no-cache \
      imagemagick \
      librsvg
# Debian / Ubuntu 用（参考）
# RUN apt-get update -qq && apt-get install -y --no-install-recommends imagemagick ghostscript
# Amazon Linux 用（参考）
# RUN yum -y update && yum -y install imagemagick

# 作業ディレクトリを /app に設定
WORKDIR /app

# 依存 gem をレイヤキャッシュ用に先にインストール
COPY Gemfile Gemfile.lock ./
RUN bundle install -j$(nproc)

# 残りのソースコードをコピー
COPY . .

# Rails 開発サーバー（Procfile.dev に従い foreman/bin/dev を起動）
CMD ["bin/dev"]
