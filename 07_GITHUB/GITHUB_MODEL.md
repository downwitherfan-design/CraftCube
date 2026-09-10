# GitHub Branch Model — 13 Accounts

```text
main
└── integration
    ├── ai-01/product
    ├── ai-02/core
    ├── ai-03/puzzle-content
    ├── ai-04/gameplay-mobile
    ├── ai-05/environment-art
    ├── ai-06/characters-vfx
    ├── ai-07/uiux
    ├── ai-08/audio
    ├── ai-09/narrative-localization
    ├── ai-10/qa
    ├── ai-11/performance-android
    ├── ai-12/release
    └── ai-13/integration
```

All accounts work independently. Pull requests target `integration`; `main` accepts only release-approved merges. AI-13 owns integration sequencing and cross-track validation, but does not directly rewrite another account's implementation.
