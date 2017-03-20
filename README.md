# secret: Share Sensitive Information in R Packages




[![Linux Build Status](https://travis-ci.org/gaborcsardi/secret.svg?branch=master)](https://travis-ci.org/gaborcsardi/secret)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/gaborcsardi/secret?svg=true)](https://ci.appveyor.com/project/gaborcsardi/secret)
[![](http://www.r-pkg.org/badges/version/secret)](http://www.r-pkg.org/pkg/secret)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/secret)](http://www.r-pkg.org/pkg/secret)
[![Coverage Status](https://img.shields.io/codecov/c/github/andrie/secret/master.svg)](https://codecov.io/github/andrie/secret?branch=master)

Allow sharing sensitive information, for example passwords, 'API' keys,
etc., in R packages, using public key cryptography.

## Installation

Install the package using the `install-github.me` service:


```r
source("https://install-github.me/gaborcsardi/secret")
```
    
Or using `devtools`:


```r
devtools::install_github("gaborcsardi/secret")
```


## Usage

### Load the package:


```r
library(secret)
```


### Set up your keys:

Ensure you know the location of your public and private keys. In Linux this is usually the folder `~/.ssh`, so on Windows you may want to choose the same folder.

By default, the package looks for your private key at 

1. `~/.ssh/id_rsa`
1. `~/.ssh/id_rsa.pem`.

You can change this default by setting an environment variable `USER_KEY`:


```r
Sys.setenv(USER_KEY = "path/to/private/key")
```

Test that the package can read your key:


```r
local_key()
```

```
#> [1024-bit rsa private key]
#> md5: 7794640c6bebe1e52a28caf792ea2896
```

### Create a vault:

    
You can create a vault by using `create_vault()`


```r
vault <- file.path(tempdir(), ".vault")
dir.create(vault)
create_vault(vault)
```

A vault consists of two folders for:

* `users`: contains user and their public keys
* `secrets`: contains the encrypted secrets


```r
dir(vault)
```

```
#> [1] "README"  "secrets" "users"
```

Alternatively, you can create a vault in an R package:


```r
pkg_root <- "/path/to/package"
create_package_vault(pkg_root)
```


### Add users to the vault:

The `secret` package contains some public and private keys you can use for demonstration purposes


```r
key_dir <- file.path(system.file(package = "secret"), "user_keys")
alice_public_key <- file.path(key_dir, "alice.pub")
alice_private_key <- file.path(key_dir, "alice.pem")
openssl::read_pubkey(alice_public_key)
```

```
#> [2048-bit rsa public key]
#> md5: 1d858d316afb8b7d0efd69ec85dc7174
```

Add the public key of Alice to the vault:


```r
add_user("alice", alice_public_key, vault = vault)
```
    

### Add a secret using your public key.

A secret can be any R object - this object will be serialised and encrypted using your local private key.


```r
secret_to_keep <- c(password = "my_password")
add_secret("secret_one", secret_to_keep, users = "alice", vault = vault)
```
  
### Decrypt a secret by providing your private key:

You can decrypt a secret if you have the private key that corresponds to the public key that was used to encrypt the secret,


```r
get_secret("secret_one", key = alice_private_key, vault = vault)
```

```
#>      password 
#> "my_password"
```


### Note for Windows users

  * If you use windows, you most likely created your keys using PuttyGen. Note that the key created by default from PuttyGen is not in OpenSSH format, so you have to convert your format first. To do this, use the  `/Conversions/Export OpenSSH` key PuttyGen menu.
  
  * Note that the folder `~/.ssh` in Windows usually expands to `C:\\Users\\YOURNAME\\Documents\\.ssh`. You can find the full path by using:

    
    ```r
    normalizePath("~/.ssh", mustWork = FALSE)
    ```
    
    ```
    #> [1] "C:\\Users\\adevries\\Documents\\.ssh"
    ```



## License

MIT © Gábor Csárdi
