import "channels";

import * as ActiveStorage from "@rails/activestorage";

import DemoApp from "../pages/demo_app";
import Rails from "@rails/ujs";
import React from "react";
import { render } from "react-dom";

Rails.start();
ActiveStorage.start();

document.addEventListener("DOMContentLoaded", () => {
  render(<DemoApp />, document.body.appendChild(document.createElement("div")));
});
