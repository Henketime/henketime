class PostsIndex extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    this.shadowRoot.innerHTML = `
      <style>
        :host { display: block; font-family: sans-serif; }
        .posts-index { background: #fff; padding: 1em; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.07); }
      </style>
      <div class="posts-index"></div>
    `;
  }

  connectedCallback() {
    const src = this.getAttribute('src');
    if (src) {
      this.loadMarkdown(src);
    }
  }

  async loadMarkdown(url) {
    try {
      const response = await fetch(url);
      if (!response.ok) throw new Error('Failed to fetch markdown');
      const text = await response.text();
      this.renderMarkdown(text);
    } catch (err) {
      this.shadowRoot.querySelector('.posts-index').textContent = 'Error: ' + err.message;
    }
  }

  renderMarkdown(mdText) {
    if (window.marked) {
      this.shadowRoot.querySelector('.posts-index').innerHTML = window.marked.parse(mdText);
    } else {
      this.shadowRoot.querySelector('.posts-index').textContent = mdText;
    }
  }
}

customElements.define('posts-index', PostsIndex);
