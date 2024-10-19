backup with rustic
==================

Configuration goes in `~/.config/rustic/`, edit as necessary. If using
`libsecret`, you can store the passwords with (edit the key/values as
necessary):

```sh
secret-tool store --label="Rustic repository password" rustic-backup manwe-hdd
secret-tool store --label="Rustic repository password" rustic-backup gdrive
```

`systemd` service files go in `~/.config/systemd/user/`, enable the timer.
