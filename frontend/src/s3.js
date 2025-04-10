// Import AWS SDK for interacting with AWS services
import AWS from 'aws-sdk';

/**
 * Configures and initializes an S3 client instance
 * @param {Object} config - Configuration object
 * @param {string} config.accessKeyId - AWS access key ID
 * @param {string} config.secretAccessKey - AWS secret access key  
 * @param {string} config.region - AWS region
 * @returns {AWS.S3} Configured S3 client instance
 */
export const configureS3 = ({ accessKeyId, secretAccessKey, region }) => {
  AWS.config.update({
    accessKeyId,
    secretAccessKey, 
    region,
  });

  return new AWS.S3();
};

/**
 * Uploads a file to an S3 bucket
 * @param {AWS.S3} s3 - Configured S3 client instance
 * @param {string} bucketName - Name of the target S3 bucket
 * @param {File} file - File object to upload
 * @returns {Promise} Upload promise that resolves when complete
 */
export const uploadToS3 = (s3, bucketName, file) => {
  const params = {
    Bucket: bucketName,
    Key: `uploads/${file.name}`,
    Body: file,
    ContentType: file.type,
  };

  return s3.upload(params).promise();
};

