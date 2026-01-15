## Il flusso di lavoro completo
- Modifichi `nvim/flake.nix` (aggiungi un plugin)
- Modifichi `nvim/lua/plugins/qualcosa.lua` (lo configuri)
- Fondamentale: Vai nella cartella nvim e fai `git add .`
- Spostati nella cartella NixOS principale
- Update del flake principale:
    - O si fa il commit della repo e nix lo riconosce automaticamente al prossimo rebuild
    - O si fa l'update manuale dopo una modifica staged (`git add .`)
        `sudo nix flake update nvim-config --flake /etc/nixos`
- Ricompila il sistema
    `sudo nixos-rebuild switch`

- Per verificare velocemene se le impostazioni di nvim sono a posto usare nella cartella .config/nvim: `nix run .` e vedere se va (dopo aver fatto `git add .`)

- Per eliminare i plugin scaricati da lazy: `rm -rf ~/.local/share/nvim/lazy ~/.local/state/nvim ~/.cache/nvim`

- Quando si aggiunge un input al flake della config: `nix flake update` nella dir di config nvim

- per testare nvim: `nix run .` oppure compilarlo in `result/` con `nix build .`
