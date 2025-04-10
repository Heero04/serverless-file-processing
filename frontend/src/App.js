// src/App.js
import React from 'react';
import S3Uploader from './S3Uploader';

function App() {
  return (
    <div className="App">
      <h1>Upload to S3 (Dev)</h1>
      <S3Uploader />
    </div>
  );
}

export default App;