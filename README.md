- Dopo aver aggiunto un pacchetto in flake.nix eseguire l'update:
    `sudo nixos-rebuild switch`

4. Il flusso di lavoro completo

Ecco cosa succede ora quando vuoi aggiornare:

- Modifichi `nvim/flake.nix` (aggiungi un plugin)
- Modifichi `nvim/lua/plugins/qualcosa.lua` (lo configuri)
- Fondamentale: Vai nella cartella nvim e fai `git add .`
- Spostati nella cartella NixOS principale
- Esegui `sudo nixos-rebuild switch --flake .` 
    `sudo nix flake update nvim-config --flake /etc/nixos`
    `sudo nixos-rebuild switch --flake /etc/nixos#nixos`

- Per verificare velocemene se le impostazioni di nvim sono a posto usare nella cartella .config/nvim: `nix run .` e vedere se va (dopo aver fatto `git add .`)

- Per eliminare i plugin scaricati da lazy: `rm -rf ~/.local/share/nvim/lazy ~/.local/state/nvim ~/.cache/nvim`

- Quando si aggiunge un input al flake: `nix flake update`
