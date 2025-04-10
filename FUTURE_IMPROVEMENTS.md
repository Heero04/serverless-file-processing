# 🚀 Future Improvements

This document tracks ideas and planned improvements for the file processor container and overall document pipeline.

---

## 🛡️ 1. Re-enable ClamAV Antivirus Scanning

**Current Status:** Removed due to excessive false positives during file conversion.

**Plan:**
- Reinstall ClamAV in Dockerfile:
  ```dockerfile

# Install ClamAV and DejaVu fonts in one layer to reduce image size
RUN apt-get update && \
    apt-get install -y \
       # clamav \
       # clamav-daemon \
        fonts-dejavu-core \
        && rm -rf /var/lib/apt/lists/*

# Update ClamAV virus definitions
RUN freshclam

## 🔐 2. Reintroduce IAM Access Analyzer Validation in CI

**Current Status:** Temporarily disabled in GitHub Actions due to JSON extraction issues.

**Plan:**
- Re-enable this GitHub Actions step:
  ```yaml
  - name: IAM Access Analyzer - Validate Terraform IAM Policy
    run: |
      aws accessanalyzer validate-policy \
        --policy-document file://iam-policy.json \
        --policy-type IDENTITY_POLICY \
        --output json
  ```
- Ensure `iam-policy.json` is properly extracted from Terraform plans before this runs
- Optionally replace with a Terraform-managed analyzer for post-deploy monitoring

