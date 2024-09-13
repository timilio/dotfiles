.PHONY: switch
switch:
	home-manager switch --flake . --extra-experimental-features nix-command --extra-experimental-features flakes

.PHONY: install
install:
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	nix-channel --update
	nix-shell '<home-manager>' -A install
