import ezdxf
from ezdxf.addons.drawing import Frontend, RenderContext, pymupdf, config

# NOTE: ezdxf に EzDxf 型は無いので doc の型ヒントは付けない
def dxf_to_pdf_bytes(doc, mm_per_unit: float = 1.0) -> bytes:
    msp = doc.modelspace()
    ctx = RenderContext(doc)

    backend = pymupdf.PyMuPdfBackend()

    # まずはシンプルな経路（多くのバージョンで動く）
    fe = Frontend(ctx, backend)
    fe.draw_layout(msp)

    # 新しめのAPI: scale引数だけでPDF取得できることが多い
    try:
        return backend.get_pdf_bytes(scale=1 / mm_per_unit)
    except TypeError:
        # フォールバック: 背景や余白を指定する旧API系
        from ezdxf.addons.drawing import layout  # 遅延importで依存を最小化
        cfg = config.Configuration(background_policy=config.BackgroundPolicy.WHITE)
        backend2 = pymupdf.PyMuPdfBackend()
        fe2 = Frontend(ctx, backend2, config=cfg)
        fe2.draw_layout(msp)

        page = layout.Page(0, 0, layout.Units.mm, margins=layout.Margins.all(5))
        settings = layout.Settings(scale=1 / mm_per_unit, fit_page=True)
        return backend2.get_pdf_bytes(page, settings=settings)
