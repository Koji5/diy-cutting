import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this._updateVar();
    window.scrollTo({ top: 0, behavior: 'auto' });
    this.ticking = false;

    /* ResizeObserver */
    this.observer = new ResizeObserver(() => this._updateVar());
    this.observer.observe(this.element);

    // しきい値 (px) — わずかなホイール揺れでのチラつき防止
    const THRESHOLD = 30;
    /* Scroll handler */
    this.lastY = window.scrollY;
    this.scroll = () => {
      if (this.ticking) return;
      requestAnimationFrame(() => {
        const y = window.scrollY;
        if (Math.abs(y - this.lastY) > THRESHOLD) {
          const down = y > this.lastY;
          this._toggleHero(down);
          this.lastY = y;
        }
        this.ticking = false;
      });
      this.ticking = true;
    };
    window.addEventListener("scroll", this.scroll, { passive: true });
  }

  disconnect(){
    window.removeEventListener('scroll', this.scroll); 
    this.observer?.disconnect();
  }

  _updateVar() {
    const h = this.element.offsetHeight;
    document.documentElement
            .style.setProperty('--hero-h', `${h}px`);
  }

  _toggleHero(hide) {
    this.element.classList.toggle("hidden", hide);
    document.body.classList.toggle("hero-hidden", hide);
  }
}