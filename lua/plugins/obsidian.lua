return {
  'epwalsh/obsidian.nvim',

  lazy = true,

  ft = "markdown",

  dependencies = { "nvim-lua/plenary.nvim" },

  config = function()

    -- Open overrides
    vim.ui.open = (function(overridden)
      return function(uri, opt)
        -- Gestione Link Web (Apre in Brave)
        local is_uri = uri:match("^%a+://") -- controlla se è http:// ecc
        if is_uri then
          opt = { cmd = { "brave" } }
        -- Gestione PDF (Zathura)
        elseif vim.endswith(uri, ".pdf") then
          opt = { cmd = { "zathura" } }
        -- Gestione Immagini e Video (imv / mpv)
        elseif vim.endswith(uri, ".png") or vim.endswith(uri, ".jpg") or vim.endswith(uri, ".jpeg") or vim.endswith(uri, ".gif") then
          opt = { cmd = { "imv" } }
        elseif vim.endswith(uri, ".mp4") or vim.endswith(uri, ".mkv") then
          opt = { cmd = { "mpv" } }
        -- Gestione Cartelle (Yazi - apre in nuovo terminale se sei su GUI, o prova ad aprire)
        -- NOTE: Integrare yazi dentro nvim richiede plugin specifici, qui lo apriamo come app esterna
        elseif vim.fn.isdirectory(uri) == 1 then
           opt = { cmd = { "alacritty", "-e", "yazi" } }
        end

        return overridden(uri, opt)
      end
    end)(vim.ui.open)

    require('obsidian').setup({
      -- Disable legacy commands
      legacy_commands = false,
      opts = { legacy_commands = false, };

      -- Disable UI, use render-markdown
      ui = {
        enable = false,
      },

      workspaces = {
        {
          name = "Omnis",
          path = "~/00_Omnis",
          overrides = {
            notes_subdir = "04_atomic_notes",  -- have to use 'vim.NIL' instead of 'nil'
            new_notes_location = "notes_subdir",
            templates = {
              folder = "04_atomic_notes/obsidian_templates",
              date_format = "%Y-%m-%d", -- Come sostituire {{date}}
              time_format = "%H:%M",    -- Come sostituire {{time}}
              substitutions = {
                -- Qui puoi creare variabili magiche.
                -- Esempio: se nel template scrivi {{giorno_settimana}}
                giorno_settimana = function()
                  return os.date("%A") 
                end
              },
            },
            daily_notes = {
              -- Optional, if you keep daily notes in a separate directory.
              folder = "02_planning/01_daily",
              --Nome File (Su disco): Sarà determinato da date_format (es. 2026-01-26.md).
              -- Alias (Titolo visibile): Sarà alias_format (es. "January 26, 2026").
              -- Cosa vedi in Telescope: Vedrai il nome del file (2026-01-26), ma se cerchi "January" lo troverà grazie all'alias nel frontmatter.
              -- Optional, if you want to change the date format for the ID of daily notes.
              date_format = "%Y-%m-%d",
              -- Optional, if you want to change the date format of the default alias of daily notes.
              alias_format = "%B %-d, %Y", -- Che formato vengono viste? che titolo hanno?
              default_tags = { "daily-notes" },
              -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
              template = "daily_note_template.md"
            },
            -- NOTE: Sono definiti o devono essere definiti qui, per cosa?
            -- Specify how to handle attachments.
            attachments = {
              -- The default folder to place images in via `:ObsidianPasteImg`.
              -- If this is a relative path it will be interpreted as relative to the vault root.
              -- You can always override this per image by passing a full path to the command instead of just a filename.
              folder = "05_resources/03_pictures",  -- This is the default

              -- Optional, customize the default name or prefix when pasting images via `:ObsidianPasteImg`.
              ---@return string
              img_name_func = function() return string.format("%s-", os.time()) end,
              img_text_func = function(client, path)
                path = client:vault_relative_path(path) or path
                return string.format("![%s](%s)", tostring(path.name), tostring(path))
              end,

              -- A function that determines the text to insert in the note when pasting an image.
              -- It takes two arguments, the `obsidian.Client` and an `obsidian.Path` to the image file.
              -- This is the default implementation.
              ---@param client obsidian.Client
              ---@param path obsidian.Path the absolute path to the image file
              ---@return string
--              img_text_func = function(client, path)
--                path = client:vault_relative_path(path) or path
--                return string.format("![%s](%s)", path.name, path)
--              end,
            },

            -- Optional, customize how note file names are generated given the ID, target directory, and title.
            ---@param spec { id: string, dir: obsidian.Path, title: string|? }
            ---@return string|obsidian.Path The full path to the new note.
            note_path_func = function(spec)
              local path
              -- CASO 1: "." (Current Dir / Oil)
              if spec.title and spec.title:sub(1,1) == "." then
                local current_buffer_dir = vim.fn.expand("%:p:h")
                if current_buffer_dir:match("^oil://") then
                  current_buffer_dir = current_buffer_dir:gsub("^oil://", "")
                end
                if current_buffer_dir == "" then current_buffer_dir = vim.fn.getcwd() end
                path = current_buffer_dir .. "/" .. tostring(spec.id)

                -- CASO 2: "/" (Sottocartella esplicita)
              elseif spec.title and spec.title:match("/") then
                local parent_dir = vim.fn.fnamemodify(spec.title, ":h")
                path = vim.fn.expand("~/00_Omnis/") .. parent_dir .. "/" .. tostring(spec.id)

                -- CASO 3: "MOC"
              elseif spec.title and spec.title:upper():match("MOC$") then
                path = vim.fn.expand("~/00_Omnis/00_MOCs/") .. tostring(spec.id)

                -- CASO 4: Default
              else
                path = tostring(spec.dir / tostring(spec.id))
              end

              -- Assicuriamoci che path sia una stringa prima di passarlo a normalize
              return vim.fs.normalize(tostring(path)) .. ".md"
            end,

          },
        },
      },

      -- Set the log level for obsidian.nvim. This is an integer corresponding to one of the log
      -- levels defined by "vim.log.levels.*".
      log_level = vim.log.levels.INFO,

      -- Completion of wiki links, local markdown links, and tags using nvim-cmp.
      completion = {
        -- Set to false to disable completion.
        nvim_cmp = true,
        -- Trigger completion at 2 chars.
        min_chars = 2,
      },

      -- Where to put new notes. Valid options are
      --  * "current_dir" - put new notes in same directory as the current buffer.
      --  * "notes_subdir" - put new notes in the default notes subdirectory.
      new_notes_location = "notes_subdir",

      -- Prende il titolo (es. "Il Mio Progetto").
      -- gsub(" ", "_"): Cambia spazi in underscore -> "Il_Mio_Progetto".
      -- lower(): Tutto minuscolo -> "il_mio_progetto".
      -- Aggiunge timestamp -> 1737912345_il_mio_progetto. È ottimo per evitare problemi con i percorsi su Linux.
      -- Optional, customize how note IDs are generated given an optional title.
      ---@param title string|?
      ---@return string
      note_id_func = function(title)
        -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
        -- In this case a note with the title 'My new note' will be given an ID that looks
        -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
        local suffix = ""
        if title ~= nil then
          -- If title is given, transform it into valid file name.
          suffix = title:gsub(" ", "_"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          -- If title is nil, just add 4 random uppercase letters to the suffix.
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.time()) .. "_" .. suffix
      end,

      -- Optional, customize how wiki links are formatted. You can set this to one of:
      --  * "use_alias_only", e.g. '[[Foo Bar]]'
      --  * "prepend_note_id", e.g. '[[foo-bar|Foo Bar]]'
      --  * "prepend_note_path", e.g. '[[foo-bar.md|Foo Bar]]'
      --  * "use_path_only", e.g. '[[foo-bar.md]]'
      -- Or you can set it to a function that takes a table of options and returns a string, like this:
      wiki_link_func = function(opts)
        return require("obsidian.util").wiki_link_id_prefix(opts)
      end,
      -- Optional, customize how markdown links are formatted.
      markdown_link_func = function(opts)
        return require("obsidian.util").markdown_link(opts)
      end,
      -- Markdown: [Alias](ID_Nota.md), wiki: [[ID_Nota|Alias]]
      -- Either 'wiki' or 'markdown'.
      preferred_link_style = "markdown", --"wiki",

      -- NOTE: sui template si possono usare le variabili di obsidian:
      -- ---
      -- id: {{id}}
      -- aliases:
      --   - {{date:DD-MM-YYYY}}
      --   - {{date:MM-DD}}
      --   - {{date:dddd}}
      -- tags: [daily]
      -- ---
      -- # Note del giorno
      -- Link, tag, metadati a inizio file. Utile.
      -- NOTE: se il template ha già i metadati, esso non li sovrascriverà, ma aggiunge id e alias se mancano
      frontmatter = {
        -- Optional, boolean or a function that takes a filename and returns a boolean.
        -- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
        enabled = true,
        -- Optional, alternatively you can customize the frontmatter data.
        ---@return table
        func = function(note)
          -- 1. Se c'è un titolo (quasi sempre), aggiungilo come Alias. 
          -- FONDAMENTALE se usi ID numerici/timestamp nel nome file.
          if note.title then
            note:add_alias(note.title)
          end
          -- 2. Crea la tabella base
          local out = { id = note.id, aliases = note.aliases, tags = note.tags }
          -- 3. Se ci sono metadati extra (dal template o scritti a mano), preservali
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end

          return out
        end
      },

      -- NOTE: cosa è questo?
      --  local out = { id = note.id, aliases = note.aliases, tags = note.tags }

      --  -- `note.metadata` contains any manually added fields in the frontmatter.
      --  -- So here we just make sure those fields are kept in the frontmatter.
      --  if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
      --    for k, v in pairs(note.metadata) do
      --      out[k] = v
      --    end
      --  end

      --  return out
      --end,

      -- Optional, set to true to force ':ObsidianOpen' to bring the app to the foreground.
      open = {
        -- Advanced URI è un plugin specifico di Obsidian (App). 
        -- Permette di fare cose tipo "obsidian://open?vault=Omnis&file=Nota&line=10".
        -- Se non lo hai installato dentro l'app Obsidian, lascialo false.
        -- Optional, set to true if you use the Obsidian Advanced URI plugin.
        -- https://github.com/Vinzent03/obsidian-advanced-uri -- NOTE: ???
        use_advanced_uri = false,
        -- Questa funzione definisce cosa succede quando dai il comando :ObsidianOpen
        -- Di base tenta di aprire l'App Obsidian desktop alla nota corrente.
        func = function(uri)
          vim.ui.open(uri, { cmd = { "open", "-a", "/Applications/Obsidian.app" } })
        end
      },

      -- NOTE: ci sono altre impostazioni da mettere qui?
      picker = {
        -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
        name = "telescope.nvim",
        -- Optional, configure key mappings for the picker. These are the defaults.
        -- Not all pickers support all mappings.
        note_mappings = {
          -- Create a new note from your query.
          new = "<C-x>",
          -- Insert a link to the selected note.
          insert_link = "<C-l>",
        },
        tag_mappings = {
          -- Add tag(s) to current note.
          tag_note = "<C-x>",
          -- Insert a tag at the current location.
          insert_tag = "<C-l>",
        },
      },

      search = {
        -- Set the maximum number of lines to read from notes on disk when performing certain searches.
        max_lines = 1000,

        -- Optional, sort search results by "path", "modified", "accessed", or "created".
        -- The recommend value is "modified" and `true` for `sort_reversed`, which means, for example,
        -- that `:ObsidianQuickSwitch` will show the notes sorted by latest modified time
        sort_by = "modified",
        sort_reversed = true,
      },

      -- Optional, determines how certain commands open notes. The valid options are:
      -- 1. "current" (the default) - to always open in the current window
      -- 2. "vsplit" - to open in a vertical split if there's not already a vertical split
      -- 3. "hsplit" - to open in a horizontal split if there's not already a horizontal split
      open_notes_in = "current",

      -- Define your own callbacks to further customize behavior.
      callbacks = {
        -- Runs at the end of `require("obsidian").setup()`.
        ---@param client obsidian.Client
        post_setup = function()
        --  -- 1 = nasconde parzialmente, 2 = nasconde tutto il markup (consigliato)
        --  vim.opt.conceallevel = 2
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "markdown",
            callback = function() vim.opt_local.conceallevel = 2 end,
          })
        end,

        -- Runs anytime you enter the buffer for a note.
        ---@param client obsidian.Client
        ---@param note obsidian.Note
        enter_note = function(client, note) end,

        -- Runs anytime you leave the buffer for a note.
        ---@param client obsidian.Client
        ---@param note obsidian.Note
        leave_note = function(client, note) end,

        -- Runs right before writing the buffer for a note.
        ---@param client obsidian.Client
        ---@param note obsidian.Note
        pre_write_note = function(client, note) end,

        -- Runs anytime the workspace is set/changed.
        ---@param client obsidian.Client
        ---@param workspace obsidian.Workspace
        post_set_workspace = function(client, workspace) end,
      },


    })

    -- ======================================
    -- KEYMAPPING
    -- ======================================
    local opts = { noremap = true, silent = true }
    -- Cerca note (usa Telescope come hai impostato nel picker)
    vim.keymap.set("n", "<leader>os", "<cmd>Obsidian search<cr>", { desc = "[O]bsidian [S]earch",  })
    vim.keymap.set("n", "<leader>oo", "<cmd>Obsidian quick_switch<cr>", { desc = "[O]bsidian [O]pen Note" })
    vim.keymap.set("n", "<leader>on", "<cmd>Obsidian new<cr>", { desc = "[O]bsidian [N]ew Note" })
    vim.keymap.set("n", "<leader>ot", "<cmd>Obsidian template<cr>", { desc = "[O]bsidian [T]emplate" })
    -- Gestione Link e Struttura
    vim.keymap.set("n", "<leader>ob", "<cmd>Obsidian backlinks<cr>", { desc = "[O]bsidian [B]acklinks" })
    vim.keymap.set("n", "<leader>ol", "<cmd>Obsidian links<cr>", { desc = "[O]bsidian [L]inks" })
    -- Ricerca Tag
    vim.keymap.set("n", "<leader>otg", "<cmd>Obsidian tags<cr>", { desc = "[O]bsidian [T]a[G]s" })
    -- Gestione Checkbox (molto utile nelle dailies)
    vim.keymap.set("n", "<leader>och", "<cmd>Obsidian toggle_checkbox<cr>", { desc = "[O]bsidian [C]heckbox Toggle" })
    -- Utility Avanzate
    vim.keymap.set("n", "<leader>orn", "<cmd>Obsidian rename<cr>", { desc = "[O]bsidian [R]ename note and links" })
    vim.keymap.set("n", "<leader>opi", "<cmd>Obsidian paste_img<cr>", { desc = "[O]bsidian [P]aste [I]mage" })
    vim.keymap.set("n", "<leader>og", "<cmd>Obsidian open<cr>", { desc = "[O]bsidian [G]ui open" })
    -- Workspace (Se ne hai più di uno)
    vim.keymap.set("n", "<leader>ow", "<cmd>Obsidian workspace<cr>", { desc = "[O]bsidian [W]orkspace Switch" })
    -- Apri il link in un nuovo Tab
    vim.keymap.set("n", "<leader>otb", function()
      if require("obsidian").util.cursor_on_markdown_link() then
            vim.cmd("tabnew") 
            vim.cmd("ObsidianFollowLink")
        end
    end, { desc = "[O]bsidian open in [T][B]ab" })
    -- Apri il link in uno split verticale
    vim.keymap.set("n", "<leader>ovs", function()
      if require("obsidian").util.cursor_on_markdown_link() then
            vim.cmd("vsplit") 
            vim.cmd("ObsidianFollowLink")
        end
    end, { desc = "[O]bsidian open in [V][S]plit" })
    -- Apri il link in uno split orizzontale
    vim.keymap.set("n", "<leader>ohs", function()
      if require("obsidian").util.cursor_on_markdown_link() then
            vim.cmd("split") 
            vim.cmd("ObsidianFollowLink")
        end
    end, { desc = "[O]bsidian open in [H][S]plit" })

    -- Follow Link
    vim.keymap.set("n", "gf", function()
      if require('obsidian').util.cursor_on_markdown_link() then
        return "<cmd>Obsidian follow_link<cr>"
      else
        return "gf"
      end
    end, { noremap = false, expr = true, desc = "Follow Anchor Link" })

    -- Smart Action (Invio per checkbox o seguire link)
    vim.keymap.set("n", "<cr>", function()
      if require('obsidian').util.smart_action() then
        return
      else
        -- Questo permette di mantenere il comportamento di Invio standard se non sei su un link/checkbox
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<cr>", true, false, true), "n", true)
      end
    end, { desc = "Obsidian Smart Action", noremap = false, expr = true, buffer = true })

    -- Visual Mode: Crea link da selezione
    vim.keymap.set("v", "<leader>ol", "<cmd>Obsidian link<cr>", { desc = "Link selection" })
    vim.keymap.set("v", "<leader>onl", "<cmd>Obsidian link_new<cr>", { desc = "New note from selection" })

  end,
}
