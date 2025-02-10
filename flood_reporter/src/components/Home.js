import React from 'react';
import { Link } from 'react-router-dom';
import DepartmentCard from './DepartmentCard';
import departments from '../data/departments';
import '../styles.css';

function Home() {
  return (
    <div className="app-container">
      <div className="header">
        <h1 className="dashboard-title">Welcome to the Dashboard</h1>
        <h2 className="user-type">User Type: Admin</h2>
      </div>
      <div className="scroll-container">
        <div className="grid-container">
          {departments.map((dept) => (
            <Link to={dept.path} key={dept.id} style={{ textDecoration: 'none' }}>
              <DepartmentCard 
                image={dept.image} 
                title={dept.name} 
                description={dept.description} 
              />
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}

export default Home;
