# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [v0.1.0]
### Uncategorised
- 👷 Adds Coverall tests
- 📝 Adds shields, updates install instructions
- ➕ Use credo for static analysis
- ⚰️ Helpers are not needed in this
- 📝 Includes small details on how the app works
- ➕ adds credo_naming
- ♻️ handle errors, checks validity of JWT, more rails
- ✅ Improve coverage

- init should set `halt_on_error: true` as a default if not set
- call with `shop_origin_type` not set should pass conn through and do nothing
- call with `shop_origin_type: :jwt`, and valid JWT headers should run with success
- invalid token should fail
- token with mismatched signature should fail
- ✅ adds tests for soft validation failures
- 🔧 Add json_library for Phoenix in dev and test
- 🚨 Fix linter warnings
- 🐛 Fix incorrectly formatted tuple

resolved authenticate/2 returning a malformed :error struct
- ✅ Test for empty values passed with "authorization" header
- ✅ Test for missing authorization header
- ✅ Test for potential opportunistic MITM attacks
- ✨ Add respond with 401
- ➕ add :git_cli
- :rocket: Bump version to 0.2.0

## [v0.0.0]
### Uncategorised
- first commit
- 🔧 Add config
- 🔧 Add dotfiles
- 📄 Adds license
- 🎉 Adds mix
- 🎉 Adds helpers
- Fork mainfiles from plug_shopify_verify_timestamp
- 👷 Adds Github CI
- ➕ Adds joken
- 📌 Add Joken, Update ex_doc
- ✨ v0.0.0 forked from Enron
- ✅ Added tests for 0.0.0

