import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "text", "spinner"]

  submit() {
    // Evita doppio submit
    this.buttonTarget.disabled = true

    // Mostra spinner
    this.textTarget.style.display = "none"
    this.spinnerTarget.style.display = "inline-block"
  }
}
