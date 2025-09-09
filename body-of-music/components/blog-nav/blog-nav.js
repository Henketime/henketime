class BlogNav extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
  }

  connectedCallback() {
    const title = this.getAttribute('title');
    this.shadowRoot.innerHTML = `<style>
  .nav__table {
    width: 100%;
    border-collapse: collapse;
    margin: 0 auto;
    max-width: var(--v-container-width, 720px);
  }
  .nav__row {
    height: var(--v-nav-height, 53px);
  }
  .slot {}
  .slot--left {
    text-align: left;
  }
  .title {
    height: var(--v-nav-height, 53px);
    text-align: center;
  }
  .title img {
    height: var(--v-three, 36px);
  }
  .slot--right {
    text-align: right;
  }
  .button,
  ::slotted(.button) {
    background: none;
    border: none;

    width: var(--v-button-width, 144px);
    padding: var(--v-one, 12px) var(--v-two, 24px);
    background-color: #fff;
    cursor: pointer;
  }
  .button:hover,
  ::slotted(.button:hover) {
    background-color: rgba(0, 0, 0, 0.1);
    text-decoration: underline;
  }
</style>`
    this.shadowRoot.innerHTML += `
<nav>
  <table class="nav__table"><tr class="nav__row">
    <td class="slot slot--left"><slot name="left-button"></slot></td>
    <td class="title">
      <a href="../pages/index.html">
        <img src="../assets/body-of-music.png" alt="Body of Music logo">
      </a>
    </td>
    <td class="slot slot--right"><slot name="right-button"></slot></td>
  </tr></table>
</nav>
    `;
    const leftSlot = this.shadowRoot.querySelector('slot[name="left-button"]');
    if (leftSlot) {
      leftSlot.addEventListener('slotchange', () => {
        const nodes = leftSlot.assignedElements();
        nodes.forEach(node => {
          node.classList.add('button', 'button--left');
        });
      });
    }
    const rightSlot = this.shadowRoot.querySelector('slot[name="right-button"]');
    if (rightSlot) {
      rightSlot.addEventListener('slotchange', () => {
        const nodes = rightSlot.assignedElements();
        nodes.forEach(node => {
          node.classList.add('button', 'button--right');
        });
      });
    }
  }
}

customElements.define('blog-nav', BlogNav);
