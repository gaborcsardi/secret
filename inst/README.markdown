


<!-- badges: start -->
[![R build status](https://github.com/gaborcsardi/secret/workflows/R-CMD-check/badge.svg)](https://github.com/gaborcsardi/secret/actions)
[![](http://www.r-pkg.org/badges/version/secret)](http://www.r-pkg.org/pkg/secret)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/secret)](http://www.r-pkg.org/pkg/secret)
[![Coverage Status](https://img.shields.io/codecov/c/github/gaborcsardi/secret/master.svg)](https://codecov.io/github/gaborcsardi/secret?branch=master)
<!-- badges: end -->

Allow sharing sensitive information, for example passwords, 'API' keys,
etc., in R packages, using public key cryptography.

## Disclaimer

1. Although the package authors did what they could to make sure that
   the package is secure and cryptographically sound, they are not
   security experts.

2. Memory areas for secrets, user passwords, passpharases, private keys and
   other sensitive information, are not securely cleaned after use!
   Technically, the local R process and other processes on the same
   computer, may have access to them. Never use this package on a public
   computer or any system that you don't trust. (Actually, never typing in
   any password on a public computer is good security practice, in general.)

3. Use this package at your own risk!

## Installation

Install the package from CRAN:

```{r, eval = FALSE}
install.packages("secret")
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
# This is optional - only do this if you want to change the default location
Sys.setenv(USER_KEY = "path/to/private/key")
```

Test that the package can read your key. This might fail if you don't have a key at `~/.ssh/id_rsa`, or if your private key has a pass phrase and R in running in non-interactive mode.


```r
library(secret)
try(local_key(), silent = TRUE)
```

```
# Please enter private key passphrase:
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
# [1] "README"  "secrets" "users"
```

Alternatively, you can create a vault in an R package:


```r
pkg_root <- "/path/to/package"
create_package_vault(pkg_root)
```


### Add users to the vault:

To add a user to the vault, you have to know their public key.

The `secret` package contains some public and private keys you can use for demonstration purposes.


```r
key_dir <- file.path(system.file(package = "secret"), "user_keys")
alice_public_key <- file.path(key_dir, "alice.pub")
alice_private_key <- file.path(key_dir, "alice.pem")
openssl::read_pubkey(alice_public_key)
```

```
# [2048-bit rsa public key]
# md5: 1d858d316afb8b7d0efd69ec85dc7174
```

Add the public key of Alice to the vault:


```r
add_user("alice", alice_public_key, vault = vault)
```
    

### Add a secret using your public key.

A secret can be any R object - this object will be serialised and then encrypted to the vault.


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
#      password 
# "my_password"
```


### Note for Windows users

  * If you use windows, you most likely created your keys using PuttyGen. Note that the key created by default from PuttyGen is not in OpenSSH format, so you have to convert your format first. To do this, use the  `/Conversions/Export OpenSSH key` menu item in  PuttyGen.
  
  * Note that the folder `~/.ssh` in Windows usually expands to `C:\\Users\\YOURNAME\\Documents\\.ssh`. You can find the full path by using:

    
    ```r
    normalizePath("~/.ssh", mustWork = FALSE)
    ```
    
    ```
    # [1] "/Users/gaborcsardi/.ssh"
    ```




## License

MIT © Gábor Csárdi, Andrie de Vries
