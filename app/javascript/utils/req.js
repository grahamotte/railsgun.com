import Axios from "axios";
import { createConsumer } from "@rails/actioncable";

export const token = () => localStorage.getItem("jwt");
export const env = () => document.querySelector('meta[name="env"]').content;
export const domain = () =>
  document.querySelector('meta[name="domain"]').content;

const axios = ({ method, url, data, params, headers }) => {
  return Axios({
    method: method || "get",
    url: url,
    params: { ...params },
    data: { ...data },
    headers: {
      Authorization: `Bearer ${token()}`,
      ...headers,
    },
  }).catch((e) => {
    if (e.response && e.response.status === 401) logout();

    throw e;
  });
};

export const createCable = () => {
  return createConsumer(
    `${
      env() === "development" ? "ws" : "wss"
    }://${domain()}/cable?jwt=${token()}`
  );
};

export const axiosNoAuth = ({ method, url, data, params, headers }) => {
  return Axios({
    method: method || "get",
    url: url,
    params: { ...params },
    data: { ...data },
    headers: { ...headers },
  });
};

export const login = ({ email, password }) => {
  return axios({
    method: "post",
    url: "/users/login",
    data: {
      email: email,
      password: password,
    },
  }).then((r) => {
    localStorage.setItem("jwt", r.data.token);
  });
};

export const logout = () => {
  return new Promise((r) => {
    localStorage.removeItem("jwt");
    r();
  });
};

export const email = () => {
  try {
    return JSON.parse(atob(token().split(".")[1])).email;
  } catch (e) {
    return null;
  }
};

export const loggedIn = () => {
  return !!email();
};

export default axios;
