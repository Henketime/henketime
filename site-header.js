class SiteHeader extends HTMLElement {
  connectedCallback() {
    this.innerHTML = `
      <style>
        :host {
          display: block;
        }

        header.site-header {
          position: sticky;
          top: 0;
          left: 0;
          right: 0;
          z-index: 1000;
          display: flex;
          align-items: center;
          height: 60px;
          padding: 1rem;
          background: #171717;
          box-sizing: border-box;
          font-size: 2rem;
          border-bottom: 10px solid var(--bg);
        }
        .site-header section {
          margin: 0 1rem;
        }

        .site-header a {
          margin: 1rem 0;
          color: #f1ede6;
          text-decoration: underline;
          text-underline-offset: 0.14em;
          text-decoration-thickness: 0.08em;
          font: inherit;
        }

        .site-header a:visited {
          color: #d4d0c8;
        }

        .site-header a:focus-visible {
          outline: 2px solid #f1ede6;
          outline-offset: 3px;
        }
      </style>
      <header class="site-header">
        <section>
          <a href="https://henketime.com/index.html" aria-label="Henketime home page">
            Henketime
          </a>
        </section>
      </header>
    `;
  }
}

customElements.define('site-header', SiteHeader);
