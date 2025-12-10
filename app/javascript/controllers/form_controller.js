import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "progressBar"]

  connect() {
    console.log("✅ Form controller connected")
    this.currentStep = 0
    this.totalSteps = this.stepTargets.length
    console.log("📊 Total steps found:", this.totalSteps)

    // Initialize - show first step
    this.showCurrentStep()
  }

  next(event) {
    event.preventDefault()
    console.log("▶️ Next button clicked, current step:", this.currentStep)

    if (!this.validateCurrentStep()) {
      console.log("❌ Validation failed")
      return
    }

    if (this.currentStep < this.totalSteps - 1) {
      this.currentStep++
      console.log("✅ Moving to step:", this.currentStep)
      this.showCurrentStep()
    }
  }

  previous(event) {
    event.preventDefault()
    console.log("◀️ Previous button clicked")

    if (this.currentStep > 0) {
      this.currentStep--
      this.showCurrentStep()
    }
  }

  showCurrentStep() {
    console.log("🔄 Showing step:", this.currentStep)

    this.stepTargets.forEach((step, index) => {
      if (index === this.currentStep) {
        step.style.display = 'block'
        console.log("👁️ Step", index, "visible")
      } else {
        step.style.display = 'none'
      }
    })

    this.updateProgress()
  }

  validateCurrentStep() {
    const currentStepElement = this.stepTargets[this.currentStep]
    const requiredFields = currentStepElement.querySelectorAll('input[required], select[required], textarea[required]')
    console.log("🔍 Validating", requiredFields.length, "required fields")

    let isValid = true
    requiredFields.forEach(field => {
      const value = field.value ? field.value.trim() : ''
      console.log("Field:", field.name, "Value:", value, "Valid:", value !== '')

      if (value === '') {
        isValid = false
        this.shakeField(field)
      }
    })

    return isValid
  }

  shakeField(field) {
    const wrapper = field.closest('.form-group') || field.closest('div[data-form-target="field"]') || field.parentElement
    wrapper.classList.add('shake-error')
    setTimeout(() => wrapper.classList.remove('shake-error'), 500)
  }

  updateProgress() {
    if (this.hasProgressBarTarget) {
      const progress = ((this.currentStep + 1) / this.totalSteps) * 100
      this.progressBarTarget.style.width = `${progress}%`
      console.log("📊 Progress:", progress + "%")
    }
  }

  focusIn(event) {
    const wrapper = event.target.closest('.form-group')
    if (wrapper) wrapper.classList.add('focused')
  }

  focusOut(event) {
    const wrapper = event.target.closest('.form-group')
    if (wrapper) {
      wrapper.classList.remove('focused')
      if (event.target.value) {
        wrapper.classList.add('filled')
      } else {
        wrapper.classList.remove('filled')
      }
    }
  }
}
