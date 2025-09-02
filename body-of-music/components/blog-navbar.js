class BlogNavbar extends HTMLElement {
  constructor() {
    super();
    console.log ('BlogNavbar constructed');
    this.attachShadow({ mode: 'open' });
  }

  connectedCallback() {
    console.log ('Title connected', this.getAttribute('title'));
    const title = this.getAttribute('title');
    this.shadowRoot.innerHTML = `
<style>
  :host {
    display: block;
    font-family: sans-serif;
    background: #fff;
    margin-bottom: var(--v-one);
  }
  navbar {
    display: flex;
  }
  .blog-navbar-title {
    line-height: var(--v-three);
  }
  .blog-navbar-buttons {
    display: flex;
  }
  .blog-navbar-buttons--left { margin-right: auto; }
  .blog-navbar-buttons--right { margin-left: auto; }

  .blog-navbar-button,
  ::slotted(.blog-navbar-button) {
    background: none;
    background-color: #fff;
    border: none;
    padding: var(--v-one) var(--v-two);
    cursor: pointer;
  }
  .blog-navbar-button:hover,
  ::slotted(.blog-navbar-button:hover) {
      background-color: rgba(0, 0, 0, 0.1);
      text-decoration: underline;
  }
</style>
    `
    this.shadowRoot.innerHTML += `
<navbar>
  <div class="blog-navbar-buttons blog-navbar-buttons--left">
    <slot name="left-button"></slot>
  </div>
  <div class="blog-navbar-title">
    <button id="titleButton" class="blog-navbar-button blog-navbar-button--title">${title}</button>
  </div>
  <div class="blog-navbar-buttons blog-navbar-buttons--right">
    <slot name="right-button"></slot>
  </div>
</navbar>
    `;
    const leftSlot = this.shadowRoot.querySelector('slot[name="left-button"]');
    if (leftSlot) {
      leftSlot.addEventListener('slotchange', () => {
        const nodes = leftSlot.assignedElements();
        nodes.forEach(node => {
          console.log('Left button slotchanged', node);
          node.classList.add('blog-navbar-button', 'blog-navbar-button--left');
        });
      });
    }
    const rightSlot = this.shadowRoot.querySelector('slot[name="right-button"]');
    if (rightSlot) {
      rightSlot.addEventListener('slotchange', () => {
        const nodes = rightSlot.assignedElements();
        nodes.forEach(node => {
          console.log('Right button slotchanged', node);
          node.classList.add('blog-navbar-button', 'blog-navbar-button--right');
        });
      });
    }
    this.shadowRoot.getElementById('titleButton').addEventListener('click', () => {
      console.log ('Title button clicked');
      window.location.href = '../index.html'
    });
  }
}

customElements.define('blog-navbar', BlogNavbar);
