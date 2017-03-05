
# secret

> Share Sensitive Information in R Packages

[![Linux Build Status](https://travis-ci.org/gaborcsardi/secret.svg?branch=master)](https://travis-ci.org/gaborcsardi/secret)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/gaborcsardi/secret?svg=true)](https://ci.appveyor.com/project/gaborcsardi/secret)
[![](http://www.r-pkg.org/badges/version/secret)](http://www.r-pkg.org/pkg/secret)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/secret)](http://www.r-pkg.org/pkg/secret)

Allow sharing sensitive information, for example passwords, 'API' keys,
etc., in R packages, using public key cryptography.

## Installation

```r
source("https://install-github.me/gaborcsardi/secret")
```

## Usage

    ```r
    library(secret)
    ```


* Ensure you know the location of your public and private keys. In Linux this is usually the folder `~/.ssh`, so on Windows you may want to choose the same folder.


* Create a `vault` directory.

    Right now, you can only use a vault inside a package

    ```r
    pkg_root <- "/path/to/project"
    create_package_vault(pkg_root)
    ```

    A vault consists of two folders for:
  
        - users
        - secrets

* Add users to the vault:

    ```R
    add_user("email", <public_key_file>, vault = pkg_root)
    ```
    

* Add a secret using your public key. A secret can be any R object - this will be serialised and encrypted.

    ```R
    add_secret("secret_one", secret_to_keep, users = "email", vault = pkg_root)
    ```
  
* Get a secret by providing your private key:

    ```R
    get_secret("secret_one", key = user_1_private_key, vault = pkg_root)
    ```
    

### Note for Windows users

  * If you use windows, you most likely created your keys using PuttyGen. Note that the key created by default from PuttyGen is not in OpenSSH format, so you have to convert your format first. To do this, use the  `/Conversions/Export OpenSSH` key PuttyGen menu.
  
  * Note that the folder `~/.ssh` in Windows usually expands to `C:\\Users\\YOURNAME\\Documents\\.ssh`. You can find the full path by using:

    ```R
    normalizePath("~/.ssh", mustWork = FALSE)
    ```



## License

MIT © Gábor Csárdi
