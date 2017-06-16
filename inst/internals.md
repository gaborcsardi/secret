
# Internals of the `secret` package

## Vaults

A vault stores users and secrets. Each secret is shared among a subset
of the users. The `users` subdirectory of the vault stores the users, and
the `secrets` subdirectory stores the secrets.

The vault directories and subdirectories may contain additional files,
e.g. `README` files are added by `secret`, these are ignored.

## Users

The `users` subdirectory of a vault contains its users. Each user has an
id. We suggest to use the user's email address as id. Each user's public
key is stored in the `<id>.pem` file, in PEM format.

`secret` can add user's via their id and public key, and can also add
users from GitHub and Travis CI.

### Adding a user

Simply creates the user's PEM file in the `users` directory.

### Deleting a user

Removes the user's PEM file from the `users` directory, and also all
`<userid>.enc` files from the subdirectories under `secrets`. A warning is
given if removing the user created orphaned secrets. These are secrets
that no user has access to after the deletion.

Note that, after deleting a user, the secrets she had access to, are *not*
re-encrypted, so with her private key, she still has access to them.
(Not through the `secret` package, because the `.enc` files were removed,
but the deleted user can manually decrypt the secret, with her private key.)

This is deliberate, and not a security flaw, since the deleted user was
already in the possession of these secrets, anyway.

As soon as a secret is updated, it gets a new AES key, and the deleted user
will have no access to its new value.

## Secrets

The `secrets` subdirectory of a vault contains the secrets. Each secret has
a name that serves as an id, and each secret is stored in its own
subdirectory within `secrets`, named according to its name. Each secret has
its own AES key, and is stored in the `secret.raw` file, encrypted with this
key.

For each user that has access to a secret, another file is stored right
next to `secret.raw`. This file is named `<userid>.enc`, and it contains
the AES key of the secret, encrypted with the user's public key.

### Adding a secret

1. A new AES key is generated for the secret.
2. The secret is stored, encrypted with this AES key.
3. Then the secret is shared among the specified users (see below).

### Querying a secret

The input is a private key, and we try to decrypt all encrypted AES keys
of the secret, with this AES key. If we fail, the private key has no access
to the secret. Otherwise we use the decrypted AES key to decrypt the
secret itself.

### Deleting a secret

Simply removes the directory of the secret. Note that even users that have
no access to a secret, can delete it. This is normal, if the user has
access to the encrypted secret's files, she can delete them, anyway,
without using the `secret` package.

### Changing a secret

Changing a secret is equivalent to adding a new secret, except that we
share the new secret with the exact users as the old one. It is necessary
that we create a new AES key for the secret, whenever we change it, to
ensure that users that have their access revoked cannot decrypt the new
value of the secret.

Note that anyone with access to the secret's files can change the contents
of a secret. They can even share the new secret with the same exact users,
using the users' public keys, stored in `users`.

### Sharing a secret

Only a user that has access to a secret, can share it with other users.
To share a secret, the sharing user must be able to decrypt it first, with
her private key, and then encrypt it with the public keys of the newly
added users.

### Unsharing a secret

Note that after unsharing a secret among some users, they'll still have
access to the current value of the secret. (Not through the `secret`
package, but via accessing the files in the vault directly.) They will
have no access to future values of the secret, however.

## Interruptions

Operations on secrets and users are not neceassarily atomic. If an
operation is interrupted, the vault might be in an inconsistent state.
Our assumption is that the vault is under source code control, and rolling
back to a consistent state is easy.
