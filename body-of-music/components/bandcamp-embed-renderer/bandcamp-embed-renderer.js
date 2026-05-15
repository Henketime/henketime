class BandcampEmbedRenderer extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    this.embedInfo = {};
  }

  connectedCallback() {
    // this.renderEmbed(this.getAttribute('embed-info'));
  }

  static get observedAttributes() {
    return ['embed-info'];
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === 'embed-info' && newValue) {
      this.renderEmbed(newValue);
    }
  }

  renderEmbed(embedInfoString) {
    try {
      const jsonString = embedInfoString.replace(/'/g, '"');
      this.embedInfo = JSON.parse(jsonString);
    } catch (error) {
      console.log('Error loading embed info:', error);
      this.shadowRoot.innerHTML = '<p>Error: ' + error.message + '</p>';
      return;
    }
    if (!this.embedInfo?.embed_url) {
      this.shadowRoot.innerHTML = '<p>No embed info provided.</p>';
      return;
    }

    this.shadowRoot.innerHTML = `
      <style>
        :host {
          display: block;
          font-family: Arial sans-serif;
          background: #fff;
          width: 100%;
        }
        .bandcamp-wrap {
          position: relative;
          width: 100%;
          height: 120px;
          overflow: hidden;
          margin: var(--v-one) auto;
          border-bottom: 1px solid #ccc;
        }
        .bandcamp-wrap iframe {
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          border: 0;
        }
      </style>
      <div
        class="bandcamp-wrap album"
        data-attrs=${JSON.stringify(this.embedInfo)}
        data-component-name="BandcampToDOM"
      >
        <iframe
          src=${this.embedInfo?.embed_url}
          frameborder="0"
          allow="autoplay"
          scrolling="no"
          allowfullscreen="true"
        ></iframe>
      </div>
    `;
  }
}

customElements.define('bandcamp-embed-renderer', BandcampEmbedRenderer);
