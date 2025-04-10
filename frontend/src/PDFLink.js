// src/PDFLink.js
// This component handles the PDF conversion process and provides a download link
// It polls an S3 bucket every 10 seconds to check if the converted PDF is ready
import React, { useEffect, useState } from 'react';
import AWS from 'aws-sdk';

// AWS configuration constants
const REGION = 'us-east-1';
const BUCKET = process.env.REACT_APP_S3_BUCKET_NAME;

// ✅ Initialize AWS S3 client with credentials from environment variables
const s3 = new AWS.S3({
  region: REGION,
  accessKeyId: process.env.REACT_APP_AWS_ACCESS_KEY,
  secretAccessKey: process.env.REACT_APP_AWS_SECRET_KEY,
});

// PDFLink component that takes a filename prop
export default function PDFLink({ filename }) {
  // State to store the presigned URL for the converted PDF
  const [url, setUrl] = useState(null);

  useEffect(() => {
    // Skip if no filename provided
    if (!filename) return;

    // ✅ Match ECS: remove only the last extension (e.g., .docx)
    // Create the output key for the converted PDF file
    const baseName = filename.split('.').slice(0, -1).join('.');
    const outputKey = `converted/${baseName}.pdf`;

    console.log("📦 Polling for file:", outputKey);

    // Set up polling interval to check for converted file
    const interval = setInterval(() => {
      const params = { Bucket: BUCKET, Key: outputKey };

      // Check if file exists in S3
      s3.headObject(params, (err) => {
        if (err) {
          console.warn("⏳ File not ready yet:", err.code || err.message);
        } else {
          console.log("✅ PDF found! Generating presigned URL...");
          // Generate temporary signed URL for file download
          const signedUrl = s3.getSignedUrl('getObject', {
            Bucket: BUCKET,
            Key: outputKey,
            Expires: 3600, // 1 hour
          });
          setUrl(signedUrl);
          clearInterval(interval); // 🔁 Stop polling once file is found
        }
      });
    }, 10000); // Poll every 10 seconds

    // Cleanup function to clear interval when component unmounts
    return () => clearInterval(interval); // 🧹 Cleanup on unmount
  }, [filename]); // Re-run effect when filename changes

  // Render download button or loading message
  return (
    <div style={{ marginTop: '20px' }}>
      {url ? (
        <a href={url} target="_blank" rel="noopener noreferrer">
          <button>📄 Download Converted PDF</button>
        </a>
      ) : (
        <p>⏳ Waiting for PDF conversion will takes at most 30 seconds</p>
      )}
    </div>
  );
}

