import { Controller } from "@hotwired/stimulus"
import { Dropdown } from "bootstrap"

export default class extends Controller {
  connect() {
    // Initialize all dropdowns when the controller connects
    const dropdownElementList = this.element.querySelectorAll('[data-bs-toggle="dropdown"]')
    const dropdownList = [...dropdownElementList].map(dropdownToggleEl => new Dropdown(dropdownToggleEl))
  }
}
