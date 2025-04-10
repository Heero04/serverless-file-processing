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
