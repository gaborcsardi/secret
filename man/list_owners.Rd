% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/secrets.R
\name{list_owners}
\alias{list_owners}
\title{List users that have access to a secret}
\usage{
list_owners(name, vault = NULL)
}
\arguments{
\item{name}{Name of the secret, a string that can contain alphanumeric
characters, underscores, dashes and dots.}

\item{vault}{Vault location (starting point to find the vault).
To create a vault, use \code{\link[=create_vault]{create_vault()}} or \code{\link[=create_package_vault]{create_package_vault()}}.
If this is \code{NULL}, then \code{secret} tries to find the vault automatically:
\itemize{
\item If the \code{secret.vault} option is set to path, that is used as the
starting point.
\item Otherwise, if the \code{R_SECRET_VAULT} environment variable is set to a
path, that is used as a starting point.
\item Otherwise the current working directory is used as the starting
point.
}

If the starting point is a vault, that is used. Otherwise, if the
starting point is in a package tree, the \code{inst/vault} folder is used
within the package. If no vault can be found, an error is thrown.}
}
\description{
List users that have access to a secret
}
\seealso{
Other secret functions: 
\code{\link{add_secret}()},
\code{\link{delete_secret}()},
\code{\link{get_secret}()},
\code{\link{list_secrets}()},
\code{\link{local_key}()},
\code{\link{share_secret}()},
\code{\link{unshare_secret}()},
\code{\link{update_secret}()}
}
\concept{secret functions}
