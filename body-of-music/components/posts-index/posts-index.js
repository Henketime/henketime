class PostsIndex extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    this.shadowRoot.innerHTML = `
      <style>
        :host {
          display: block;
          font-family: sans-serif;
        }
        .posts-index {
          background: #fff;
          padding: var(--v-one, 12px);
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.07);
        }
      </style>
      <div class="posts-index"></div>
    `;
  }

  connectedCallback() {
    const src = this.getAttribute('src');
    if (src) {
      this.loadCSV(src);
    }
  }

  async loadCSV(url) {
    try {
      const response = await fetch(url);
      if (!response.ok) throw new Error('Failed to fetch CSV');
      const text = await response.text();
      this.renderLinks(text);
    } catch (err) {
      this.shadowRoot.querySelector('.posts-index').textContent = 'Error: ' + err.message;
    }
  }

  renderLinks(csvText) {
    const posts = csvText.trim().split('\n').slice(1);
    if (posts.length < 2) {
      this.shadowRoot.querySelector('.posts-index').innerHTML = '<p>No posts available.</p>';
      return;
    }
    const links = posts.map(post => {
      const [title, filename, date] = post.split(',');
      return `<li><a href="reader.html?file=${encodeURIComponent(filename)}">${title}</a> <small>${date}</small></li>`;
    }).join('');
    this.shadowRoot.querySelector('.posts-index').innerHTML = `<ul>${links}</ul>`;
  }
}

customElements.define('posts-index', PostsIndex);
