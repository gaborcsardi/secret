
pkg_root <- make_pkg_root()
create_package_vault(pkg_root)

context("travis and github")

travis_key <- paste0(
  '{ "key":\n',
  '"-----BEGIN PUBLIC KEY-----\\n',
  'MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAlhKjkvKRZN/sI2X/Fcy2\\n',
  'wqmd8Y2Tey2ZCjuVei/sVOVB+7CazyfCDbR/QB6R7WFXrJ/4gqQsQyBTXldvc+QY\\n',
  'VJ4lhK9m+yRdJACsOWY4ZaYy2iOe+ilsPdNce3igxUQDppqfX7F2RaPHb8ogwJnV\\n',
  'gLEYPhcGH0e7YweAMUQfASiAHyzOCj/SYKkQYSEimd7B09SfrEzLsCb5njSJVdQ1\\n',
  'xqmxTkjJOo27yPB4Y4CLpXcRqoLi+ju0vcxURU6sH+iwldap1pKMYLmZtHRcAdhh\\n',
  'TDs3SYX72iQ3f3C2O/WK6DGCS7+iQdO63/q9qfx1wP+kpZXVob7bekuN1Av3DomQ\\n',
  'HpmnkGXCf7ud9DdSV4Z+ecJkvvi0UY9DOz5vpz0DiEV4Y9wqmrz9xkNgNw0mHQSy\\n',
  'aSZbM/4MemeOIgN2bHVqXGgE09eZIYmVmvBVqdRg0rtTKicCU9EwsGfqpbcs49Uy\\n',
  'e3gK7zsNbCC6X8+bKHUgHdaaPtY/eVydHd/iHthi44Xdo+t3ykbF9/JqprUssnMU\\n',
  'iVK8MTsNPkv1HUnja9zLGzcmHbrpNDEdu4ASqC1A7XKUaU807aDT6XjcLObcTH7R\\n',
  '15RwzGF/e1Q10xUMyCfC5zvwTXXoV9IB4po6/vDEXR6nZCHnB3HibUaDTjLFFJE4\\n',
  '59bGPpJEle95EpUBqR76ShsCAwEAAQ==\\n',
  '-----END PUBLIC KEY-----\\n',
  '", "fingerprint":"8a:63:d6:f1:6a:2f:ed:e1:36:65:61:b8:16:65:2f:16"}'
)

test_that("can add travis user", {

  ## This is a bit cumbersome, because we don't call the mocked function
  ## directly...
  mockery::stub(
    add_travis_user, "get_travis_key", function(travis_repo) {
      mockery::stub(get_travis_key, "curl", travis_key)
      get_travis_key(travis_repo)
    }
  )

  expect_equal(
    basename(
      add_travis_user("gaborcsardi/secret", vault = pkg_root)
    ),
    "travis-gaborcsardi-secret.pem"
  )
  expect_true(
    file.exists(
      file.path(pkg_root,
                "inst", "vault", "users", "travis-gaborcsardi-secret.pem"
      )
    )
  )
})

github_key <- paste0(
  '[{ "id": 6261674,\n',
  '"key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhylC70CzZoGpOrEBRX',
  'dKmm+YjSGXiYvTg/b7+gvt28hEuwXXT53mWEWJvQWjIdgzeEBI6sO0uVS4BC7qWe0',
  'TGQ8eXdF1htnXpVOsA4ZHrRjTIAttLesFPvdKUwq43eL6xC2umzCWLk21fEJbdECE',
  'tkShP7AZL+/5uVX1AWAd4gllF4NX/N0MwW7x+jjbptl/bFV33zPev++0ZXAM5FyTG',
  'CC5T46BwhQwHNxVeU3nd3rl15S4PLcIyv6knzz9IA0HPAlviUjxjRtP5eEZkYJRI9',
  '8t5pIKt5yQGKBQN2qm1fvcZ1EpfM4HkpKm7JKN8jYyY48+JsJCGyKQvQVqK5jDN"',
  '}]'
)

test_that("can add github user",{

  mockery::stub(
    add_github_user, "get_github_key", function(github_user, i = 1) {
      mockery::stub(
        get_github_key,
        "curl_fetch_memory",
        list(content = charToRaw(github_key))
      )
      get_github_key(github_user, i)
    }
  )

  expect_equal(
    basename(
      add_github_user("gaborcsardi", vault = pkg_root)
    ),
    "github-gaborcsardi.pem"
  )
  expect_true(
    file.exists(
      file.path(pkg_root, "inst", "vault", "users", "github-gaborcsardi.pem"
      )
    )
  )
})
