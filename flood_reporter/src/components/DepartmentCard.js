import React from 'react';

function DepartmentCard({ image, title, description }) {
  return (
    <div className="department-card">
      <img src={image} alt={title} />
      <h3>{title}</h3>
      <p>{description}</p>
    </div>
  );
}

export default DepartmentCard;