// src/S3Uploader.js
// This component handles file uploads to AWS S3
// It allows users to select a file, uploads it to an S3 bucket
// and displays a presigned URL link once the upload is complete
import React, { useState } from 'react';
import { configureS3, uploadToS3 } from './s3';
import PDFLink from './PDFLink'; // ✅ This will show the presigned URL

const S3Uploader = () => {
  // State to track the selected file and uploaded filename
  const [file, setFile] = useState(null);
  const [uploadedFilename, setUploadedFilename] = useState(null);

  // Configure S3 client with credentials from environment variables
  const s3 = configureS3({
    accessKeyId: process.env.REACT_APP_AWS_ACCESS_KEY,
    secretAccessKey: process.env.REACT_APP_AWS_SECRET_KEY,
    region: 'us-east-1', // update if needed
  });

  // Handle file upload to S3
  const handleUpload = async () => {
    if (!file) return;

    try {
      // Upload file to uploads/ folder
      await uploadToS3(s3, process.env.REACT_APP_S3_BUCKET_NAME, file);
      setUploadedFilename(file.name); // Save original filename
      alert('Upload successful! Waiting for conversion...');
    } catch (err) {
      console.error('Upload failed:', err);
      alert('Upload failed.');
    }
  };

  return (
    <div>
      {/* File input for selecting files to upload */}
      <input type="file" onChange={e => setFile(e.target.files[0])} />
      <button onClick={handleUpload} disabled={!file}>Upload</button>

      {/* 🔽 Show presigned URL link once uploaded */}
      {uploadedFilename && <PDFLink filename={uploadedFilename} />}
    </div>
  );
};

export default S3Uploader;

