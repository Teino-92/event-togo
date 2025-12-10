import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    console.log("Flash controller connected")
    // Auto-dismiss after 5 seconds
    this.messageTargets.forEach(message => {
      setTimeout(() => {
        this.dismissElement(message)
      }, 5000)
    })
  }

  dismiss(event) {
    const message = event.currentTarget.closest('.flash-message')
    this.dismissElement(message)
  }

  dismissElement(element) {
    element.style.animation = 'slideOut 0.3s ease'
    setTimeout(() => {
      element.remove()
    }, 300)
  }
}
