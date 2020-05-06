
\dontrun{
vault <- file.path(tempdir(), ".vault")
create_vault(vault)

add_travis_user("gaborcsardi/secret", vault = vault)
list_users(vault = vault)
delete_user("travis-gaborcsardi-secret", vault = vault)
}
