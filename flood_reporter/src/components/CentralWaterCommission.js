import React, { useState, useEffect } from 'react';

import '../styles.css';

const API_BASE = "http://192.168.125.188:5001";

function CentralWaterCommission() {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [reports, setReports] = useState([]);
  const [userLoggedIn, setUserLoggedIn] = useState(false);

  const handleAuth = async (endpoint) => {
    if (!email || !password) return alert("Please fill all fields!");
    if (!isLogin && password !== confirmPassword) return alert("Passwords do not match!");

    const response = await fetch(`${API_BASE}/${isLogin ? 'login' : 'register'}/CentralWaterCommission`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username: email, password })
    });

    const data = await response.json();
    if (response.ok) {
      alert(isLogin ? "Login Successful!" : "Registration Successful!");
      if (isLogin) {
        fetchReports();
        setUserLoggedIn(true);
      } else {
        setIsLogin(true);
      }
    } else {
      alert(data.error || "Something went wrong!");
    }
  };

  const fetchReports = async () => {
    const response = await fetch(`http://192.168.125.188:5000/reports/CentralWaterCommission`);
    const data = await response.json();
    setReports(data);
  };

  useEffect(() => {
    if (isLogin) setReports([]);
  }, [isLogin]);

  return (
    <div className="container">
      {!userLoggedIn ? (
        <div className="auth-box">
          {isLogin ? (
            <>
              <h2>Login</h2>
              <input type="email" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
              <input type="password" placeholder="Password" value={password} onChange={(e) => setPassword(e.target.value)} />
              <button className="login-btn" onClick={() => handleAuth("login")}>Login</button>
              <p>Don't have an account? <span onClick={() => setIsLogin(false)}>Register</span></p>
            </>
          ) : (
            <>
              <h2>Register</h2>
              <input type="email" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
              <input type="password" placeholder="Password" value={password} onChange={(e) => setPassword(e.target.value)} />
              <input type="password" placeholder="Confirm Password" value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} />
              <button className="register-btn" onClick={() => handleAuth("register")}>Register</button>
              <p>Already have an account? <span onClick={() => setIsLogin(true)}>Login</span></p>
            </>
          )}
        </div>
      ) : (
        <div className="reports-container">
        <h2>Reports</h2>
        <div className="reports-grid">
          {reports.length > 0 ? (
            reports.map((report) => (
              <div key={report.id} className="report-card">
                <div className="report-image-container">
                  <img src={report.image_url ? `http://192.168.125.188:5000/${report.image_url}` : 'default-placeholder.jpg'} alt="Report" className="report-image" />
                </div>
                <div className="report-details">
                  <h3 className="report-username">{report.username}</h3>
                  <p><strong>Description:</strong> {report.description}</p>
                  <p><strong>Category:</strong> {report.category}</p>
                  <p><strong>Department:</strong> {report.department}</p>
                  <p><strong>Address:</strong> {report.address}</p>
                </div>
              </div>
            ))
          ) : (
            <div className="no-reports-box">
              No reports available.
            </div>
          )}
        </div>
      </div>
      
      )}
    </div>
  );
}

export default CentralWaterCommission;