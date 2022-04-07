#building:

Run `nix build`

#CI:
There is none lol. But you can copy pre-commit to .git/hooks/ so you can run a nix build before attempting to commit. I don't really want to bother setting up a hydra for something I expect to be the only contributor to, so we are running "CI" on the honor policy.
