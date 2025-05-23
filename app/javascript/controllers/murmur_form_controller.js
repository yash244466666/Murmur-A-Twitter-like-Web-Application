import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['content', 'charCount', 'submit'];
  static values = {
    maxLength: Number,
  };

  connect () {
    this.maxLengthValue = this.maxLengthValue || 280;
    this.updateCharCount ();
  }

  updateCharCount () {
    const remaining = this.maxLengthValue - this.contentTarget.value.length;
    this.charCountTarget.textContent = `${remaining} characters remaining`;

    if (remaining < 0) {
      this.submitTarget.disabled = true;
      this.charCountTarget.classList.add ('text-red-500');
    } else {
      this.submitTarget.disabled = false;
      this.charCountTarget.classList.remove ('text-red-500');
    }
  }
}
