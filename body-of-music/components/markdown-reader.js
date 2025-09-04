class MarkdownReader extends HTMLElement {
  constructor() {
    super();
    console.log ('MarkdownReader constructed');
    this.attachShadow({ mode: 'open' });
    this.shadowRoot.innerHTML = `
      <style>
        :host { display: block; font-family: sans-serif; }
        .markdown-content { background: #fff; padding: 1em; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.07); }
      </style>
      <div class="markdown-content"></div>
    `;
  }

  static get observedAttributes() {
    return ['src', 'markdown'];
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === 'src' && newValue) {
      console.log ('loadMarkdown', newValue)
      this.loadMarkdown(newValue);
    } else if (name === 'markdown') {
      console.log ('renderMarkdown', newValue)
      this.renderMarkdown(newValue);
    }
  }

  async loadMarkdown(url) {
    try {
      const response = await fetch(url);
      if (!response.ok) throw new Error('Failed to fetch markdown');
      const text = await response.text();
      this.renderMarkdown(text);
    } catch (err) {
      console.log ('Error loading markdown:', err);
      this.shadowRoot.querySelector('.markdown-content').textContent = 'Error: ' + err.message;
    }
  }

  renderMarkdown(mdText) {
    if (window.marked) {
      this.shadowRoot.querySelector('.markdown-content').innerHTML = window.marked.parse(mdText);
    } else {
      this.shadowRoot.querySelector('.markdown-content').textContent = mdText;
    }
  }
}

customElements.define('markdown-reader', MarkdownReader);
