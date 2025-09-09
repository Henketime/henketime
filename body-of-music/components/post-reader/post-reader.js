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
      <bandcamp-embed-renderer id="embed"></bandcamp-embed-renderer>
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
      const frontmatterMatch = text.match(/^---$([\s\S]*?)^---$/m);
      if (!frontmatterMatch) throw new Error('No frontmatter found');

      const frontmatter = frontmatterMatch[1];
      const embedInfo = frontmatter.match(/embed-info:\s*(.*)/)?.[1] || '';

      const markdown = text.replace(/^---$.*^---$/ms, '');
      const [introduction, bodyfeel] = markdown.split('----- embed -----').map(s => s.trim());

      this.shadowRoot.getElementById('introduction').setAttribute('markdown', introduction);
      this.shadowRoot.getElementById('bodyfeel').setAttribute('markdown', bodyfeel);
      this.shadowRoot.getElementById('embed').setAttribute('embed-info', embedInfo);
    } catch (err) {
      // this.shadowRoot.querySelector('.markdown-content').textContent = 'Error: ' + err.message;
    }
  }

  renderPost(introduction, bodyfeel, embedInfo) {

  }
}


{/* <markdown-reader id="introduction"></markdown-reader>
<bandcamp-embed-renderer
  media-source="bandcamp"
  embed-info="{
    'url': 'https://i-voidhangerrecords.bandcamp.com/album/im-losing-myself',
    'title': 'Im Losing Myself, by AN ISOLATED MIND',
    'description': '7 track album',
    'thumbnail_url': 'https://substack-post-media.s3.amazonaws.com/public/images/8449c99b-39f5-484c-9e56-f3dca2298185_700x700.jpeg',
    'author': 'I, Voidhanger Records',
    'embed_url': 'https://bandcamp.com/EmbeddedPlayer/album=1506319974/size=large/bgcol=ffffff/linkcol=333333/artwork=small/transparent=true/',
    'is_album': true
  }"
></bandcamp-embed-renderer>
<markdown-reader id="bodyfeel"></markdown-reader> */}

customElements.define('post-reader', PostReader);
