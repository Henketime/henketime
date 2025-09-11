class MarkdownEditor extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    this.textarea = document.createElement('textarea');
    this.textarea.id = 'markdown-content';
    this.shadowRoot.appendChild(this.textarea);
    const style = document.createElement('style');
    style.textContent = `
      textarea { width: 100%; min-height: 300px; }
    `;
    this.shadowRoot.appendChild(style);
  }

  connectedCallback() {
    if (window.EasyMDE) {
      this.easyMDE = new window.EasyMDE({
        autoDownloadFontAwesome: true,
        autofocus: true,
        autosave: {enabled: false},
        spellChecker: true,
        hideIcons: [],
        element: this.textarea,
      });
      this.easyMDE.codemirror.on('change', () => {
        this.dispatchEvent(new CustomEvent('change', {
          detail: { value: this.value }
        }));
      });
    } else {
      console.error('EasyMDE is not loaded.');
    }

    fetch('/lib/easymde.min.css')
      .then(res => res.text())
      .then(css => {
        const style = document.createElement('style');
        style.textContent = css;
        this.shadowRoot.appendChild(style);
      });

    fetch('/lib/font-awesome.min.css')
      .then(res => res.text())
      .then(css => {
        const style = document.createElement('style');
        style.textContent = css;
        this.shadowRoot.appendChild(style);
      });
  }

  get value() {
    return this.easyMDE ? this.easyMDE.value() : this.textarea.value;
  }

  set value(val) {
    if (this.easyMDE) {
      this.easyMDE.value(val);
    } else {
      this.textarea.value = val;
    }
  }
}

customElements.define('markdown-editor', MarkdownEditor);
