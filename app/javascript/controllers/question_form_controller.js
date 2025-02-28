import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["form"];
  static values = { courseId: Number, newRecord: Boolean, courseOpen: Boolean };

  closed = !this.courseOpenValue;

  courseOpenHandler(e) {
    console.log('her')
    if (this.courseIdValue === e.detail.course_id) {
      this.closed = false;
      if (this.hasFormTarget) {
        this.formTarget.classList.remove("disabled");
      }
    }
  }

  courseCloseHandler(e) {
    console.log(this.courseIdValue === e.detail.course_id)
    console.log(this.hasFormTarget && this.newRecordValue)
    if (this.courseIdValue === e.detail.course_id) {
      this.closed = true;
      if (this.hasFormTarget && this.newRecordValue) {
        this.formTarget.classList.add("disabled");
      }
    }
  }

  initialize() {
  }

  connect() {
    this.courseCloseHandler = this.courseCloseHandler.bind(this);
    this.courseOpenHandler = this.courseOpenHandler.bind(this);
    document.addEventListener("course:open", this.courseOpenHandler);
    document.addEventListener("course:close", this.courseCloseHandler);
  }

  formTargetConnected() {
    if (this.closed === true && this.newRecordValue) {
      this.formTarget.classList.add("disabled");
    } else if (this.closed === false && this.newRecordValue) {
      this.formTarget.classList.remove("disabled");
    }
  }

  formTargetDisconnected() {
  }

  disconnect() {
    document.removeEventListener("course:close", this.courseCloseHandler);
    document.removeEventListener("course:open", this.courseOpenHandler);
  }
}
