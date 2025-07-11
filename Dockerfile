####################################################################
# DIY-Cutting – Amazon Linux 2023 版（librsvg + GEOS ソースビルド）
####################################################################
FROM public.ecr.aws/amazonlinux/amazonlinux:2023 AS build

# ── 1) 標準パッケージ更新 ────────────────────────────────
RUN dnf -y update

# ── 2) 開発ツールチェーン ───────────────────────────────
RUN dnf -y groupinstall "Development Tools"

# ── 3) 必要ライブラリを rpm で入れる（EPEL 不要）────────
RUN dnf -y install \
      ruby ruby-devel                       \
      libyaml-devel zlib-devel openssl-devel\
      postgresql16 postgresql16-devel       \
      nodejs npm                            \
      ImageMagick ImageMagick-libs \
      librsvg2-tools cairo pango \
      tzdata git pkgconf-pkg-config cmake &&      \
    dnf clean all && npm install -g yarn

# ── GEOS ソースビルド (CMake 方式) ─────────────────────
ARG GEOS_VER=3.12.2
RUN curl -sSL https://download.osgeo.org/geos/geos-${GEOS_VER}.tar.bz2 \
      | tar xj && \
    cd geos-${GEOS_VER} && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DCMAKE_INSTALL_LIBDIR=lib64 \
      . && \
    make -j"$(nproc)" && make install &&  \
    echo "/usr/local/lib64" > /etc/ld.so.conf.d/local-geos.conf && \
    ldconfig && \
    cd .. && rm -rf geos-${GEOS_VER} && \
    cd .. && rm -rf geos-${GEOS_VER}

# ── 5) アプリ依存 Gems ──────────────────────────────────
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install -j"$(nproc)"

# ── 6) 残りのソース ──────────────────────────────────────
COPY . .

# ── 7) エントリポイント（foreman/bin/dev）───────────────
CMD ["bin/dev"]
