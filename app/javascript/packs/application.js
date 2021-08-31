import Rails from "rails-ujs";
import "@hotwired/turbo-rails";
import * as ActiveStorage from "@rails/activestorage";
import "channels";
import "controllers";

import SearchModal from "../src/components/SearchModal";
import StudentQueueView from "../src/components/StudentQueueView";
import AddCourseByCode from "../src/components/AddCourseByCode";
import FilterDropdown from "../src/components/search/FilterDropdown";
import queryClient from "../src/utilities/queryClientFile";
import ReactStudentChannel from "../channels/react_student_channel";
import CourseStatus from "../src/components/CourseStatus";
import NotificationFeed from "../src/components/NotificationFeed";
import Prefetcher from "../src/components/Prefetcher";
import QuestionAnswererPage from "../src/components/QuestionAnswererPage";
import QueueInfoPanel from "../src/components/QueueInfoPanel";
import TAActionPane from "../src/components/TAActionPane";
import TALog from "../src/components/TALog";
import TAQueueView from "../src/components/TAQueueView";
import UserSettings from "../src/components/Settings";

import attachTurboEvents from "../src/utilities/turboExtraEvents";
import registerManager from "../src/utilities/registerComponent";
import QuestionAnsweringTime from "../src/components/QuestionAnsweringTime";
import Popover from "bootstrap/js/dist/popover";
import "ransack-search-element";

registerManager.register_component(AddCourseByCode, "#add-course-by-code");
registerManager.register_component(CourseStatus, "#course-status");
registerManager.register_component(FilterDropdown, "#dropdown-filter");
registerManager.register_component(NotificationFeed, "#notification-feed");
registerManager.register_component(Prefetcher, "#prefetcher");
registerManager.register_component(QuestionAnswererPage, "#question-answerer");
registerManager.register_component(QueueInfoPanel, "#queue-info-panel");
registerManager.register_component(SearchModal, "#hello-react");
registerManager.register_component(StudentQueueView, "#student-queue-view");
registerManager.register_component(TAActionPane, "#ta-action-pane");
registerManager.register_component(TALog, "#ta-chart");
registerManager.register_component(TAQueueView, "#ta-queue-view");
registerManager.register_component(UserSettings, "#user-settings");
registerManager.register_component(QuestionAnsweringTime, "#question-time");

attachTurboEvents();

registerManager.render_components();
registerManager.register_hooks();

window.queryClient = queryClient;

ReactStudentChannel.received = async (data) => {
  console.log("invalidating", data.invalidate);

  await queryClient.invalidateQueries(data.invalidate);

  await queryClient.refetchQueries(data.invalidate);
};

document.addEventListener("turbo:load", function (event) {
  var popoverTriggerList = [].slice.call(
    document.querySelectorAll('[data-bs-toggle="popover"]')
  );

  var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
    return new Popover(popoverTriggerEl);
  });
});

Rails.start();
ActiveStorage.start();

Rails.delegate(
  document,
  Rails.linkDisableSelector,
  "turbo:before-cache",
  Rails.enableElement
);
Rails.delegate(
  document,
  Rails.buttonDisableSelector,
  "turbo:before-cache",
  Rails.enableElement
);
Rails.delegate(
  document,
  Rails.buttonDisableSelector,
  "turbo:submit-end",
  Rails.enableElement
);

Rails.delegate(
  document,
  Rails.formSubmitSelector,
  "turbo:submit-start",
  Rails.disableElement
);
Rails.delegate(
  document,
  Rails.formSubmitSelector,
  "turbo:submit-end",
  Rails.enableElement
);
Rails.delegate(
  document,
  Rails.formSubmitSelector,
  "turbo:before-cache",
  Rails.enableElement
);
