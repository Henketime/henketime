class PostEditor extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    this.shadowRoot.innerHTML = `
      <style>
        .button-row {
          display: flex;
          margin: var(--v-one) 0;
          gap: var(--v-one);
        }
        .button-row--full-width {
          width: 100%;
          justify-content: space-between;
        }
        .button-row--right {
          justify-content: end;
        }
        .button {
          background: transparent;
          color: #336699;
          border: 1px solid #99ccff;
          padding: var(--v-one-and-a-half) var(--v-two);
          cursor: pointer;
          transition: background 0.2s;
        }
        .button:hover {
          background: #f9f9f9;
        }
      </style>
      <form id="postForm">
        <label>Title: <input type="text" id="title" required></label>
        <markdown-editor id="mdEditor"></markdown-editor>
        <div class="button-row button-row--right">
          <button type="submit" class="button">Save Post</button>
        </div>
        <div id="status"></div>
      </form>
    `;
  }

  async connectedCallback() {
    this.titleInput = this.shadowRoot.getElementById('title');
    this.mdEditor = this.shadowRoot.getElementById('mdEditor');
    this.statusDiv = this.shadowRoot.getElementById('status');
    if (this.hasAttribute('title')) {
      this.titleInput.value = this.getAttribute('title');
      await this.loadPost(this.titleInput.value);
    }
    this.shadowRoot.getElementById('postForm').onsubmit = async (e) => {
      e.preventDefault();
      await this.savePost();
    };
  }

  async getPostsDirHandle() {
    return await window.showDirectoryPicker();
  }

  async loadPost(title) {
    const dirHandle = await this.getPostsDirHandle();
    const filename = title.replace(/\s+/g, '_') + '.md';
    try {
      const fileHandle = await dirHandle.getFileHandle(filename);
      const file = await fileHandle.getFile();
      const content = await file.text();
      this.mdEditor.value = content;
    } catch (err) {
      this.mdEditor.value = '';
    }
  }

  async savePost() {
    const title = this.titleInput.value;
    const content = this.mdEditor.value;
    const dirHandle = await this.getPostsDirHandle();
    const filename = title.replace(/\s+/g, '_') + '.md';
    const fileHandle = await dirHandle.getFileHandle(filename, { create: true });
    const writable = await fileHandle.createWritable();
    await writable.write(`---\ntitle: "${title}"\ndate: ${new Date().toISOString().slice(0,10)}\n---\n\n${content}`);
    await writable.close();
    await this.updateIndexFile(dirHandle, filename, title);
    this.statusDiv.textContent = 'Post saved and index updated!';
  }

  async updateIndexFile(dirHandle, filename, title) {
    let files = [];
    for await (const entry of dirHandle.values()) {
      if (entry.kind === 'file' && entry.name.endsWith('.md')) {
        files.push(entry.name);
      }
    }
    let indexContent = 'title,filename,date\n';
    files.forEach(file => {
      const fileTitle = file.replace('.md', '').replace(/_/g, ' ');
      const date = file.slice(0, 10);
      indexContent += `${fileTitle},${file},${date}\n`;
    });
    const indexHandle = await dirHandle.getFileHandle('blogs-index.csv', { create: true });
    const writable = await indexHandle.createWritable();
    await writable.write(indexContent);
    await writable.close();
  }
}

customElements.define('post-editor', PostEditor);
