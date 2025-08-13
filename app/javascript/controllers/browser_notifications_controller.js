import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    title: String,
    body: String
  }

  connect() {
    try {
      if (!("Notification" in window)) {
        return
      }
      if (Notification.permission === "granted") {
        this.notify()
      }
      // Do not auto request permission on connect; require user gesture
    } catch (e) {
      // ignore
    }
  }

  requestAndNotify() {
    try {
      if (!("Notification" in window)) return
      if (Notification.permission === "granted") {
        this.notify()
        return
      }
      Notification.requestPermission().then((permission) => {
        if (permission === "granted") {
          this.notify()
        }
      })
    } catch (e) {
      // ignore
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
}
