class MarkdownReader extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    this.shadowRoot.innerHTML = `
      <style>
        :host {
          display: block;
          background: #fff;
        }
        .markdown-content {
          padding: 1em;
          background-color: #fafafa;
        }
        .markdown-content img {
          width: 100%;
          max-width: 100%;
          height: auto;
          display: block;
          margin: 20px auto;
        }
        .markdown-content h1 {
          margin-top: 0;
          margin-bottom: 0;
        }
        .markdown-content h1 + h2 {
          margin-top: 0;
        }
      </style>
      <div class="markdown-content"></div>
    `;
  }

  connectedCallback() {
    if (this.hasAttribute('markdown')) {
      this.renderMarkdown(this.getAttribute('markdown'));
    }
  }

  static get observedAttributes() {
    return ['markdown'];
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === 'markdown' && newValue) {
      this.renderMarkdown(newValue);
    }
  }

  renderMarkdown(markdownText) {
    const container = this.shadowRoot.querySelector(`.markdown-content`);
    if (window.marked) {
      container.innerHTML = window.marked.parse(markdownText);
    } else {
      container.textContent = markdownText;
    }
  }
}

customElements.define('markdown-reader', MarkdownReader);
