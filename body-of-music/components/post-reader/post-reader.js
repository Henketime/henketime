class PostReader extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    this.shadowRoot.innerHTML = `
      <style>
        :host {
          display: block;
          background: #fff;
          padding-top: var(--v-one, 12px);
        }
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
      </style>
      <markdown-reader id="introduction"></markdown-reader>
      <div id="embed"></div>
      <markdown-reader id="bodyfeel"></markdown-reader>
    `;
  }

  async connectedCallback() {
    if (this.hasAttribute('src')) {
      const postParts = await this.createPostParts(this.getAttribute('src'));
      this.renderPost(postParts.introduction, postParts.bodyfeel, postParts.embedInfo);
    }
  }

  static get observedAttributes() {
    return ['src'];
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === 'src' && newValue) {
      const postParts = this.createPostParts(newValue);
      this.renderPost(postParts.introduction, postParts.bodyfeel, postParts.embedInfo);
    }
  }

  async createPostParts(fileUrl) {
    try {
      const response = await fetch(fileUrl);
      if (!response.ok) throw new Error('Failed to fetch markdown');

      const text = await response.text();

      const markdown = text.replace(/^---$.*^---$/ms, '');
      const [introduction, bodyfeel] = markdown.split('----- embed -----').map(s => s.trim());

      this.shadowRoot.getElementById('introduction').setAttribute('markdown', introduction);
      this.shadowRoot.getElementById('bodyfeel').setAttribute('markdown', bodyfeel);

      const frontmatterMatch = text.match(/^---$([\s\S]*?)^---$/m);
      if (!frontmatterMatch) throw new Error('No frontmatter found');

      const frontmatter = frontmatterMatch[1];
      const embedInfo = frontmatter.match(/embed-info:\s*(.*)/)?.[1] || '';
      const parsedEmbedInfo = embedInfo ? JSON.parse(embedInfo.replace(/'/g, '"')) : null;
      const mediaType = parsedEmbedInfo?.url?.includes('bandcamp.com') ? 'bandcamp' : 'youtube';

      const embedDiv = this.shadowRoot.getElementById('embed');
      embedDiv.innerHTML = ''; // Clear previous content

      if (mediaType === 'bandcamp') {
        const bandcamp = document.createElement('bandcamp-embed-renderer');
        bandcamp.setAttribute('embed-info', embedInfo);
        embedDiv.appendChild(bandcamp);
      } else if (mediaType === 'youtube') {
        const youtube = document.createElement('youtube-embed-renderer');
        youtube.setAttribute('embed-info', embedInfo);
        embedDiv.appendChild(youtube);
      }
    } catch (error) {
      // TODO: Create global error space/handler
      console.error ('An error has occurred:', error)
      // this.shadowRoot.querySelector('.markdown-content').textContent = 'Error: ' + err.message;
    }
  }

  renderPost(introduction, bodyfeel, embedInfo) {

  }
}

customElements.define('post-reader', PostReader);
