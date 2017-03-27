#' Reads local secret key.
#' 
#' Reads a local secret key from disk. The location of this file is specified in the environment variable called `USER_KEY` (See details).  If this environment variable does not exist, then attempts to read the key at:
#' * `~/.ssh/id_rsa`
#' * `~/.ssh/id_rsa.pem`.
#' 
#' The location of the key is defined by:
#' 
#' `Sys.getenv("USER_KEY")`
#' 
#' To use a local in a different location, set an environment variable:
#' 
#' `Sys.setenv(USER_KEY = "path/to/private/key")`
#' 
#' @family secret functions
#' @export
local_key <- function() {
  path <- Sys.getenv("USER_KEY", "~/.ssh/id_rsa")
  if (file.exists(path)) return(openssl::read_key(path))

  path <- Sys.getenv("USER_KEY", "~/.ssh/id_rsa.pem")
  if (file.exists(path)) return(openssl::read_key(path))
  
  stop("No suitable user key found.")
}
