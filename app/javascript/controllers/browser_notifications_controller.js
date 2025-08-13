import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    title: String,
    body: String
  }

  connect() {
    try {
      if (!("Notification" in window)) {
        this.remove()
        return
      }

      if (Notification.permission === "granted") {
        this.notify()
      } else if (Notification.permission !== "denied") {
        Notification.requestPermission().then((permission) => {
          if (permission === "granted") {
            this.notify()
          } else {
            this.remove()
          }
        })
        return
      }
    } catch (e) {
      // fail silently
    } finally {
      // ensure we do not accumulate nodes
      this.remove()
    }
  }

  notify() {
    const title = this.hasTitleValue ? this.titleValue : "Notification"
    const body = this.hasBodyValue ? this.bodyValue : ""
    try {
      new Notification(title, { body })
    } catch (e) {
      // ignore
    }
  }

  remove() {
    this.element.remove()
  }
}
