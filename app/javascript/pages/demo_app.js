import React, { useEffect, useState } from "react";
import axios, {
  createCable,
  loggedIn as initLoggedIn,
  login,
  logout,
} from "../utils/axios";

export default () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loggedIn, setLoggedIn] = useState(initLoggedIn());
  const [loginError, setLoginError] = useState(false);

  const [data, setData] = useState({});
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    if (loaded) return;
    if (!loggedIn) return;

    axios({
      url: "/home/show",
    }).then((r) => {
      setLoaded(true);
      setData(r.data);
    });
  }, [loggedIn, loaded]);

  const [dad, setDad] = useState("");
  useEffect(() => {
    const cable = createCable();

    cable.subscriptions.create(
      { channel: "DemoChannel", id: "123" },
      { received: (rec) => setDad(rec) }
    );

    return () => cable.disconnect();
  }, []);

  const loginContent = (
    <>
      <div className="mb-3">
        <label className="form-label">Email</label>
        <input
          type="email"
          className="form-control"
          onChange={(e) => setEmail(e.target.value)}
        />
      </div>

      <div className="mb-3">
        <label className="form-label">Password</label>
        <input
          type="password"
          className="form-control"
          onChange={(e) => setPassword(e.target.value)}
        />
      </div>

      <button
        type="button"
        className="btn btn-primary"
        onClick={() => {
          login({
            email: email,
            password: password,
          })
            .then(() => {
              setLoggedIn(true);
              setLoginError(false);
              setLoaded(false);
              setData({});
            })
            .catch(() => {
              setLoggedIn(false);
              setLoginError(true);
              setLoaded(false);
              setData({});
            });
        }}
      >
        Login / Signup
      </button>
    </>
  );

  const showContent = (
    <>
      <button
        type="button"
        className="btn btn-primary mb-3"
        onClick={() => {
          logout().then(() => {
            setLoggedIn(false);
            setLoginError(false);
            setLoaded(false);
            setData({});
          });
        }}
      >
        Logout
      </button>

      {Object.keys(data).map((k) => {
        return (
          <div key={k} className="row">
            <div className="col-3 fw-bold">{k}</div>
            <div className="col">{data[k]}</div>
          </div>
        );
      })}
    </>
  );

  return (
    <div className="container mt-5 mb-5 font-monospace">
      <h1 className="fst-italic fw-bold mb-0">RAILSGUN</h1>

      <div className="text-muted mb-3" style={{ fontSize: "0.75em" }}>
        {dad}
      </div>

      <div className="shadow p-3 mb-5 bg-body rounded">
        {loginError && <div className="alert alert-danger">LOL nope.</div>}
        {loggedIn ? showContent : loginContent}
      </div>
    </div>
  );
};
