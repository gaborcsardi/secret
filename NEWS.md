
# dev

* New functions `get_github_key()` and `get_travis_key()` to retrieve
  public keys from GitHub and Travis (#23).

* `add_travis_user()` works correctly again, now it uses the Travis V2 API
  at https://api.travis-ci.com.

* `add_github_user()` now works correctly when not the first key is
  added (#21, @jiwalker-usgs).

* `get_secret()` is now faster, because it uses fingerprint matching
  instead of trying to decrypt every file (#19, @jiwalker-usgs).

* `list_secrets()` now works if `vault` is not specified
  (#22, @AlexAxthelm).

# 1.0.0

First public release.
