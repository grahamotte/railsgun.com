import "channels";

import * as ActiveStorage from "@rails/activestorage";

import DemoApp from "../pages/demo_app";
import Rails from "@rails/ujs";
import React from "react";
import ReactDOM from "react-dom/client";

Rails.start();
ActiveStorage.start();

const root = ReactDOM.createRoot(
  document.body.appendChild(document.createElement("div"))
);

root.render(<DemoApp />);
