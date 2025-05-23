import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    autohide: Boolean,
    duration: {type: Number, default: 5000},
  };

  initialize () {
    this.isClosing = false;
    this.hideTimeout = null;
    this.removeTimeout = null;
  }

  connect () {
    this.element.style.opacity = '0';
    this.element.style.transform = 'translateX(100%)';
    this.element.style.transition =
      'opacity 300ms ease-in-out, transform 300ms ease-in-out';

    void this.element.offsetWidth;

    setTimeout (() => {
      this.element.style.opacity = '1';
      this.element.style.transform = 'translateX(0)';
    }, 50);

    if (this.autohideValue) {
      this.hideTimeout = setTimeout (() => {
        this.close ();
      }, this.durationValue);
    }
  }

  close (event) {
    if (event) {
      event.preventDefault ();
    }

    if (this.isClosing || !this.element.parentNode) {
      return;
    }

    this.isClosing = true;

    if (this.hideTimeout) {
      clearTimeout (this.hideTimeout);
      this.hideTimeout = null;
    }

    this.element.style.pointerEvents = 'none';
    this.element.style.opacity = '0';
    this.element.style.transform = 'translateX(100%)';

    this.removeTimeout = setTimeout (() => {
      if (this.element && this.element.parentNode) {
        this.element.remove ();
      }
      this.isClosing = false;
    }, 300);
  }

  disconnect () {
    if (this.hideTimeout) {
      clearTimeout (this.hideTimeout);
      this.hideTimeout = null;
    }
    if (this.removeTimeout) {
      clearTimeout (this.removeTimeout);
      this.removeTimeout = null;
    }
  }
}
