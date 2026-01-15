- Dopo aver aggiunto un pacchetto in flake.nix eseguire l'update:
    `sudo nixos-rebuild switch`

4. Il flusso di lavoro completo

Ecco cosa succede ora quando vuoi aggiornare:

- Modifichi `nvim/flake.nix` (aggiungi un plugin)
- Modifichi `nvim/lua/plugins/qualcosa.lua` (lo configuri)
- Fondamentale: Vai nella cartella nvim e fai `git add .`
- Spostati nella cartella NixOS principale
- Esegui `sudo nixos-rebuild switch --flake .`
