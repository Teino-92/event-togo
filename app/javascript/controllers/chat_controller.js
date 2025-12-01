import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "input", "submit"]

  connect() {
    console.log("Chat controller connected")
    this.scrollToBottom()

    // Listen for turbo stream updates
    document.addEventListener("turbo:before-stream-render", this.handleStreamRender.bind(this))
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this.handleStreamRender.bind(this))
  }

  handleStreamRender(event) {
    // Scroll to bottom after stream renders
    requestAnimationFrame(() => {
      this.scrollToBottom()
    })
  }

  submit(event) {
    console.log("🚀 Form submitted, showing typing indicator")

    // Add loading message immediately
    this.addLoadingMessage()

    // Disable form inputs
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
    }
    if (this.hasInputTarget) {
      this.inputTarget.disabled = true
    }

    // Re-enable form after response (Turbo will handle the actual re-rendering)
    document.addEventListener('turbo:submit-end', () => {
      if (this.hasSubmitTarget) {
        this.submitTarget.disabled = false
      }
      if (this.hasInputTarget) {
        this.inputTarget.disabled = false
        this.inputTarget.value = ''
      }
    }, { once: true })
  }

  addLoadingMessage() {
    // Remove any existing loading indicator first
    const existingLoading = document.getElementById('ai-loading')
    if (existingLoading) {
      existingLoading.remove()
    }

    // Find the messages container
    const messagesTarget = this.messagesTarget
    if (!messagesTarget) return

    const loadingHTML = `
      <div class="messages-left" id="ai-loading" style="animation: fadeInUp 0.3s ease;">
        <div class="message-wrapper left">
          <img src="/assets/bot.png" class="avatar" alt="AI">
          <div class="message-content" style="background: #F8F9FA; padding: 20px; border-radius: 12px;">
            <div class="typing-indicator">
              <span></span>
              <span></span>
              <span></span>
            </div>
            <p style="color: #3F0071; font-style: italic; margin-top: 10px; margin-bottom: 0;">AI is thinking...</p>
          </div>
        </div>
      </div>
    `
    messagesTarget.insertAdjacentHTML('beforeend', loadingHTML)
    this.scrollToBottom()
  }

  scrollToBottom() {
    const messagesContainer = document.getElementById('chat-messages-container')
    if (messagesContainer) {
      messagesContainer.scrollTo({
        top: messagesContainer.scrollHeight,
        behavior: 'smooth'
      })
    }
  }
}
