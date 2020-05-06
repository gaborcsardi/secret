\dontrun{
vault <- file.path(tempdir(), ".vault")
create_vault(vault)

add_github_user("hadley", vault = vault)
list_users(vault = vault)
delete_user("github-hadley", vault = vault)
}
