# BackgroundGuard Roadmap

This document outlines the planned direction of BackgroundGuard.
It helps contributors understand what the project is focusing on, what is out of scope, and how they can help.

The roadmap is subject to change based on real-world usage and feedback.

---

## 🎯 Project Vision

BackgroundGuard aims to make background task reliability on Android **observable, debuggable, and fixable**.

Instead of guessing why background work fails, developers should be able to:
- detect failures
- guide users to fix system restrictions
- verify that the fix actually worked

---

## 🚀 v1.0.0 — Initial Stable Release (Current)

**Status:** In progress / Release candidate

### Core Features
- Background execution proof (one-off & periodic heartbeat)
- Persistent background health tracking
- Device & OEM detection (Samsung, Xiaomi, Oppo, Vivo, Huawei, OnePlus)
- Battery optimization and power-saving diagnostics
- Settings navigation with safe fallbacks
- Verification loop (detect → guide → verify)
- Example app demonstrating full flow

### Non-Goals (v1.0.0)
- Bypassing Android or OEM restrictions
- Guaranteed background execution
- iOS support
- Advanced analytics or telemetry

---

## 🧭 v1.1.x — Developer Experience Improvements

**Status:** Planned

- Public `BackgroundHealth` model (typed API)
- Health status streams / listeners
- Drop-in Health Panel widget
- Improved logs and debug helpers
- Expanded OEM guidance text
- Better example UI

---

## 🔧 v1.2.x — OEM & Platform Enhancements

**Status:** Planned

- Improved OEM-specific settings intents
- More granular restriction detection
- Safer fallbacks for new Android versions
- Configuration options for strict vs relaxed checks
- CI improvements and additional tests

---

## 🍎 v2.0.0 — iOS Exploration (Experimental)

**Status:** Exploratory

- Background execution observability on iOS
- Limitations clearly documented
- Experimental parity where feasible

> Note: iOS background behavior is heavily restricted and will not match Android capabilities.

---

## ❌ Explicitly Out of Scope

The following are **not planned**:
- Root-based or privileged workarounds
- Private or undocumented system APIs
- Highlighting or auto-selecting app rows in system Settings
- Forcing OEM-specific behavior

---

## 🤝 How to Contribute

Before contributing, please:
1. Check existing issues and roadmap items
2. Open an issue to discuss large changes
3. Align contributions with current roadmap goals

Pull Requests that align with the roadmap are more likely to be accepted.

---

## 🗺 Roadmap Ownership

The roadmap is maintained by the project maintainers.
Feedback and suggestions are welcome via issues and discussions.

---

_Last updated: January 2026_
