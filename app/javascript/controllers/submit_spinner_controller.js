import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "text", "spinner"]

  submit(event) {
    // Prevent double submit
    this.buttonTarget.disabled = true

    // Show spinner
    this.textTarget.style.display = "none"
    this.spinnerTarget.style.display = "inline-block"
    this.spinnerTarget.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Creating your plan...'
  }
}
