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

## 🧠 3. Reintroduce IAM Policy Linting with policy_sentry

**Current Status:** Temporarily removed from GitHub Actions for simplicity during development.

**Plan:**
- Re-enable this GitHub Actions step:
  ```yaml
  - name: Install policy_sentry
    run: pip install policy_sentry

  - name: Lint Terraform IAM Policy with policy_sentry
    run: |
      echo "## 🧠 policy_sentry Analysis" >> $GITHUB_STEP_SUMMARY
      if policy_sentry analyze --input-file iam-policy.json > ps-report.txt; then
        echo "✅ policy_sentry passed. Least privilege looks good." >> $GITHUB_STEP_SUMMARY
        cat ps-report.txt >> $GITHUB_STEP_SUMMARY
      else
        echo "❌ policy_sentry found issues in the policy." >> $GITHUB_STEP_SUMMARY
        cat ps-report.txt >> $GITHUB_STEP_SUMMARY
        exit 1
      fi
  ```
- Ensure `iam-policy.json` is valid and generated prior to this step
- Use in conjunction with Access Analyzer for full IAM policy coverage

