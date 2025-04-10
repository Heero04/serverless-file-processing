// src/components/ProgressBar.js
import React from 'react';

const ProgressBar = ({ progress }) => {
  return (
    <div style={{
      width: '100%',
      height: '20px',
      backgroundColor: '#f0f0f0',
      borderRadius: '10px',
      overflow: 'hidden',
      margin: '10px 0'
    }}>
      <div style={{
        width: `${progress}%`,
        height: '100%',
        backgroundColor: '#4CAF50',
        transition: 'width 0.3s ease-in-out'
      }}>
      </div>
      <div style={{
        marginTop: '5px',
        textAlign: 'center'
      }}>
        {progress}%
      </div>
    </div>
  );
};

export default ProgressBar;
