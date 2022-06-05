import React, { useEffect, useState } from "react";
import axios, {
  createCable,
  loggedIn as initLoggedIn,
  login,
  logout,
} from "../utils/req";

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
      { channel: "DadChannel", id: "123" },
      { received: (rec) => setDad(rec) }
    );

    return () => cable.disconnect();
  }, [loggedIn]);

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
      {Object.keys(data).map((cat) => {
        return (
          <div key={cat} className="shadow p-3 mb-2 bg-body rounded">
            <h6>{cat}</h6>
            {Object.keys(data[cat]).map((key) => {
              return (
                <div key={`${cat}${key}`} className="row">
                  <div className="col-4 fw-bold overflow-hidden text-end">
                    {key}
                  </div>
                  <div className="col overflow-hidden">{data[cat][key]}</div>
                </div>
              );
            })}
          </div>
        );
      })}
    </>
  );

  return (
    <div
      className="container mt-5 mb-5 font-monospace"
      style={{ fontSize: "0.75em" }}
    >
      <div className="row mb-3">
        <div className="col">
          <h1
            className="mb-0"
            style={{
              fontFamily: "Jaldi Bold",
            }}
          >
            RAILSGUN! <i className="fa-solid fa-meteor"></i>
          </h1>
          <div className="text-muted">{dad}</div>
        </div>
        <div className="col text-end align-self-end">
          {loggedIn && (
            <button
              type="button"
              className="btn btn-primary"
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
          )}
        </div>
      </div>

      {loggedIn ? (
        showContent
      ) : (
        <div className="row">
          <div className="col-lg-6">
            <div className="shadow p-3 mb-5 bg-body rounded">
              {loginError && (
                <div className="alert alert-danger">LOL nope.</div>
              )}
              {loginContent}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
