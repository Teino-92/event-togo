import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight
  }

  // Cette méthode est appelée à chaque Turbo Stream
  scroll() {
    this.scrollToBottom()
  }
}
