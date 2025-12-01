import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hero", "section", "feature"]

  connect() {
    console.log("Homepage controller connected")
    this.observeElements()
    this.initParallax()
    this.initTypingAnimation()
  }

  observeElements() {
    const options = {
      threshold: 0.1,
      rootMargin: '0px 0px -100px 0px'
    }

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('fade-in-up')
          observer.unobserve(entry.target)
        }
      })
    }, options)

    // Observe all sections
    this.sectionTargets.forEach(section => {
      observer.observe(section)
    })

    // Observe features if they exist
    if (this.hasFeatureTarget) {
      this.featureTargets.forEach(feature => {
        observer.observe(feature)
      })
    }
  }

  initParallax() {
    if (!this.hasHeroTarget) return

    window.addEventListener('scroll', () => {
      const scrolled = window.pageYOffset
      if (this.hasHeroTarget) {
        this.heroTarget.style.transform = `translateY(${scrolled * 0.5}px)`
        this.heroTarget.style.opacity = 1 - (scrolled / 500)
      }
    })
  }

  initTypingAnimation() {
    const heroTitle = this.element.querySelector('.hero h1')
    if (!heroTitle) return

    const text = heroTitle.textContent
    heroTitle.textContent = ''
    heroTitle.style.opacity = '1'

    let index = 0
    const typeSpeed = 80

    const type = () => {
      if (index < text.length) {
        heroTitle.textContent += text.charAt(index)
        index++
        setTimeout(type, typeSpeed)
      } else {
        heroTitle.classList.add('typing-complete')
      }
    }

    setTimeout(type, 500)
  }

  animateOnHover(event) {
    const element = event.currentTarget
    element.style.transform = 'scale(1.05) translateY(-5px)'
  }

  resetAnimation(event) {
    const element = event.currentTarget
    element.style.transform = 'scale(1) translateY(0)'
  }
}
