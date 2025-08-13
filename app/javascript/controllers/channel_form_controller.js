import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["settings"]
  static values = { checkUrl: String }

  connect() {
    this.kindChanged()
  }

  kindChanged() {
    const select = this.element.querySelector('select[name="notification_channel[kind]"]')
    const kind = select ? select.value : null
    this.settingsTargets.forEach((el) => {
      const forKind = el.getAttribute('data-kind')
      el.style.display = (forKind === kind) ? '' : 'none'
    })
  }

  beforeCheck(event) {
    // Retarget this form submission to the check endpoint and Turbo Frame
    this.element.action = this.checkUrlValue
    this.element.method = 'post'
    this.element.dataset.turboFrame = 'check_result'
    // Flag this as a check submission
    let hidden = this.element.querySelector('input[name="check"]')
    if (!hidden) {
      hidden = document.createElement('input')
      hidden.type = 'hidden'
      hidden.name = 'check'
      hidden.value = '1'
      this.element.appendChild(hidden)
    }
  }
}
