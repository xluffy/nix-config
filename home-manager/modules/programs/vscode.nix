{
  pkgs,
  vscode-marketplace,
  hasGUI ? true,
  ...
}: {
  programs.vscode = pkgs.lib.mkIf hasGUI {
    enable = true;
    package = pkgs.vscode;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions =
        (with pkgs.vscode-extensions; [
          # Core UX
          vscodevim.vim
          dracula-theme.theme-dracula
          arcticicestudio.nord-visual-studio-code
          catppuccin.catppuccin-vsc
          enkia.tokyo-night
          vscode-icons-team.vscode-icons
          eamodio.gitlens

          # Go
          golang.go

          # Python
          ms-python.python
          ms-python.vscode-pylance

          # PHP / Laravel
          bmewburn.vscode-intelephense-client

          # TypeScript / Web
          vue.volar
          esbenp.prettier-vscode
          dbaeumer.vscode-eslint

          # Rust
          rust-lang.rust-analyzer
          tamasfe.even-better-toml

          # Nix, Terraform, Bash (matches AstroVim community packs)
          jnoortheen.nix-ide
          hashicorp.terraform
          mads-hartmann.bash-ide-vscode
        ])
        ++ (with vscode-marketplace; [
          # Laravel extras
          amiralizadeh9480.laravel-extra-intellisense
          onecentlin.laravel-blade
          shufo.vscode-blade-formatter

          # Python lint + format
          charliermarsh.ruff

          # Tree-sitter based syntax highlighting
          georgewfraser.vscode-tree-sitter

          # Neovide-like smear cursor (port of sphamba/smear-cursor.nvim)
          yesitsfebreeze.smearcursor
        ]);

      userSettings = {
        # ------------------------------------------------------------------
        # Editor (AstroVim-like minimal UI)
        # ------------------------------------------------------------------
        "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Maple Mono NF', Menlo, Monaco, monospace";
        "editor.fontLigatures" = true;
        "editor.fontSize" = 14;
        "editor.lineNumbers" = "relative";
        "editor.cursorSurroundingLines" = 8;
        "editor.scrollBeyondLastLine" = false;
        "editor.minimap.enabled" = false;
        "editor.smoothScrolling" = true;
        "workbench.list.smoothScrolling" = true;
        "terminal.integrated.smoothScrolling" = true;
        "editor.autoClosingBrackets" = "always";
        "editor.autoClosingQuotes" = "always";
        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = true;
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave".source.organizeImports = "explicit";

        # ------------------------------------------------------------------
        # Workbench
        # ------------------------------------------------------------------
        "workbench.colorTheme" = "Catppuccin Latte";
        "workbench.iconTheme" = "vscode-icons";
        "workbench.startupEditor" = "none";
        "workbench.editor.enablePreview" = false;
        "workbench.editor.labelFormat" = "short";

        # ------------------------------------------------------------------
        # Files
        # ------------------------------------------------------------------
        "files.associations" = {
          "*.tmpl" = "gotmpl";
        };
        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;

        # ------------------------------------------------------------------
        # Terminal
        # ------------------------------------------------------------------
        "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";

        # ------------------------------------------------------------------
        # Git
        # ------------------------------------------------------------------
        "git.enableSmartCommit" = true;
        "git.autofetch" = true;
        "git.confirmSync" = false;

        # ------------------------------------------------------------------
        # Privacy: updates, telemetry, experiments, tracking (all off)
        # ------------------------------------------------------------------
        # Nix manages updates; VSCode must not check or notify
        "extensions.autoUpdate" = false;
        "extensions.autoCheckUpdates" = false;
        "extensions.ignoreRecommendations" = true;
        "update.mode" = "none";
        "update.showReleaseNotes" = false;

        # Core telemetry and experiments
        "telemetry.telemetryLevel" = "off";
        "telemetry.enableTelemetry" = false;
        "telemetry.enableCrashReporter" = false;
        "workbench.enableExperiments" = false;
        "workbench.settings.enableNaturalLanguageSearch" = false;

        # MCP: no server discovery, no auto-start of workspace servers
        "chat.mcp.discovery.enabled" = false;

        # AI agent chat: disabled
        "chat.agent.enabled" = false;
        "chat.commandCenter.enabled" = false;

        # Welcome and onboarding fetch nothing
        "workbench.welcomePage.walkthroughs.openOnInstall" = false;

        # Extension-level telemetry
        "gitlens.telemetry.enabled" = false;
        "intelephense.telemetry.enabled" = false;
        "python.experiments.enabled" = false;
        "typescript.surveys.enabled" = false;
        "npm.fetchOnlinePackageInfo" = false;
        "go.toolsEnvVars" = {
          "GOTELEMETRY" = "off";
        };

        # ------------------------------------------------------------------
        # Go
        # ------------------------------------------------------------------
        "go.useLanguageServer" = true;
        "go.toolsManagement.autoUpdate" = true;
        "[go]" = {
          "editor.defaultFormatter" = "golang.go";
          "editor.formatOnSave" = true;
        };

        # ------------------------------------------------------------------
        # Python
        # ------------------------------------------------------------------
        "python.analysis.typeCheckingMode" = "basic";
        "python.analysis.autoImportCompletions" = true;
        "[python]" = {
          "editor.defaultFormatter" = "charliermarsh.ruff";
          "editor.codeActionsOnSave"."source.organizeImports" = "explicit";
        };

        # ------------------------------------------------------------------
        # PHP / Laravel
        # ------------------------------------------------------------------
        "intelephense.files.associations" = ["*.php" "*.phtml" "*.blade.php"];
        "intelephense.files.maxSize" = 5000000;
        "[php]" = {
          "editor.defaultFormatter" = "bmewburn.vscode-intelephense-client";
        };
        "[blade]" = {
          "editor.defaultFormatter" = "shufo.vscode-blade-formatter";
        };
        "emmet.includeLanguages".blade = "html";

        # ------------------------------------------------------------------
        # TypeScript / JavaScript / Web
        # ------------------------------------------------------------------
        "typescript.updateImportsOnFileMove.enabled" = "always";
        "javascript.updateImportsOnFileMove.enabled" = "always";
        "[typescript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[typescriptreact]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[javascript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[javascriptreact]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[vue]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[json]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[jsonc]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[html]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[css]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[scss]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[markdown]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "prettier.tabWidth" = 2;
        "prettier.useTabs" = false;

        # ------------------------------------------------------------------
        # Rust
        # ------------------------------------------------------------------
        "rust-analyzer.check.command" = "clippy";
        "[rust]" = {
          "editor.defaultFormatter" = "rust-lang.rust-analyzer";
        };
        "[toml]" = {
          "editor.defaultFormatter" = "tamasfe.even-better-toml";
        };

        # ------------------------------------------------------------------
        # Nix
        # ------------------------------------------------------------------
        "nix.enableLanguageServer" = true;
        "nix.formatterPath" = "alejandra";

        # ------------------------------------------------------------------
        # Terraform
        # ------------------------------------------------------------------
        "terraform.languageServer.enable" = true;

        # ------------------------------------------------------------------
        # Vim mode (AstroVim-like)
        # ------------------------------------------------------------------
        # Smear cursor: Neovide-style trailing cursor (sphamba/smear-cursor.nvim)
        # Short animation keeps held h/j/k/l movement responsive.
        "smearcursor.animation_time" = 100;
        "smearcursor.animation_easing" = "circ";
        "smearcursor.blink_enabled" = true;

        "vim.leader" = "<Space>";
        "vim.useSystemClipboard" = true;
        "vim.hlsearch" = true;
        "vim.ignorecase" = true;
        "vim.smartcase" = true;
        "vim.incsearch" = true;
        "vim.visualstar" = true;
        "vim.foldfix" = true;
        "vim.showcmd" = true;
        "vim.timeout" = 300;
        "vim.statusBarColorControl" = true;
        "vim.statusBarColors" = {
          normal = "#1e66f5";
          insert = "#40a02b";
          visual = "#8839ef";
          visualline = "#8839ef";
          visualblock = "#8839ef";
          replace = "#d20f39";
        };
        "vim.cursorStylePerMode" = {
          normal = "block";
          insert = "line";
          visual = "underline";
          replace = "block";
        };

        # Normal mode: AstroVim-style Space leader mappings
        "vim.normalModeKeyBindingsNonRecursive" = [
          # Window navigation
          {
            before = ["<C-h>"];
            commands = ["workbench.action.navigateLeft"];
          }
          {
            before = ["<C-l>"];
            commands = ["workbench.action.navigateRight"];
          }
          {
            before = ["<C-k>"];
            commands = ["workbench.action.navigateUp"];
          }
          {
            before = ["<C-j>"];
            commands = ["workbench.action.navigateDown"];
          }

          # Buffer tabs
          {
            before = ["]b"];
            commands = ["workbench.action.nextEditor"];
          }
          {
            before = ["[b"];
            commands = ["workbench.action.previousEditor"];
          }
          {
            before = ["<leader>" "b" "d"];
            commands = ["workbench.action.closeActiveEditor"];
          }
          {
            before = ["<leader>" "b" "o"];
            commands = ["workbench.action.closeOtherEditors"];
          }

          # File explorer: focus (space-e in the explorer closes it and returns to editor)
          {
            before = ["<leader>" "e"];
            commands = ["workbench.files.action.focusFilesExplorer"];
          }
          {
            before = ["<C-w>"];
            commands = ["workbench.files.action.focusFilesExplorer"];
          }

          # Finders (telescope-like)
          {
            before = ["<leader>" "f" "f"];
            commands = ["workbench.action.quickOpen"];
          }
          {
            before = ["<leader>" "f" "w"];
            commands = ["workbench.action.findInFiles"];
          }
          {
            before = ["<leader>" "f" "b"];
            commands = ["workbench.action.showAllEditors"];
          }
          {
            before = ["<leader>" "f" "r"];
            commands = ["workbench.action.openRecent"];
          }

          # Splits
          {
            before = ["<leader>" "|"];
            commands = ["workbench.action.splitEditor"];
          }
          {
            before = ["<leader>" "-"];
            commands = ["workbench.action.splitEditorDown"];
          }

          # Terminal
          {
            before = ["<leader>" "t" "f"];
            commands = ["workbench.action.terminal.toggleTerminal"];
          }
          {
            before = ["<leader>" "t" "n"];
            commands = ["workbench.action.terminal.new"];
          }

          # Quit
          {
            before = ["<leader>" "q"];
            commands = ["workbench.action.closeWindow"];
          }

          # LSP: g-prefix
          {
            before = ["g" "d"];
            commands = ["editor.action.revealDefinition"];
          }
          {
            before = ["g" "D"];
            commands = ["editor.action.revealDeclaration"];
          }
          {
            before = ["g" "r"];
            commands = ["editor.action.referenceSearch.trigger"];
          }
          {
            before = ["g" "i"];
            commands = ["editor.action.goToImplementation"];
          }
          {
            before = ["g" "y"];
            commands = ["editor.action.goToTypeDefinition"];
          }
          {
            before = ["K"];
            commands = ["editor.action.showHover"];
          }

          # LSP: leader l-prefix
          {
            before = ["<leader>" "l" "r"];
            commands = ["editor.action.rename"];
          }
          {
            before = ["<leader>" "l" "a"];
            commands = ["editor.action.quickFix"];
          }
          {
            before = ["<leader>" "l" "f"];
            commands = ["editor.action.formatDocument"];
          }
          {
            before = ["<leader>" "l" "o"];
            commands = ["editor.action.organizeImports"];
          }
          {
            before = ["<leader>" "l" "d"];
            commands = ["workbench.actions.view.problems"];
          }

          # Diagnostics navigation
          {
            before = ["[d"];
            commands = ["editor.action.marker.prev"];
          }
          {
            before = ["]d"];
            commands = ["editor.action.marker.next"];
          }

          # Git
          {
            before = ["<leader>" "g" "b"];
            commands = ["gitlens.toggleLineBlame"];
          }
          {
            before = ["<leader>" "g" "B"];
            commands = ["gitlens.toggleFileBlame"];
          }
          {
            before = ["<leader>" "g" "s"];
            commands = ["workbench.view.scm"];
          }

          # UI toggles
          {
            before = ["<leader>" "u" "w"];
            commands = ["editor.action.toggleWordWrap"];
          }

          # Markdown preview
          {
            before = ["<leader>" "m" "p"];
            commands = ["markdown.showPreviewToSide"];
          }
        ];

        # Insert mode: better-escape (jk, jj) like AstroVim
        "vim.insertModeKeyBindingsNonRecursive" = [
          {
            before = ["j" "j"];
            after = ["<Esc>"];
          }
          {
            before = ["j" "k"];
            after = ["<Esc>"];
          }
        ];
      };

      # Neo-tree-like keys inside the file explorer.
      # VSCodeVim does not handle these views, so we use native keybindings.
      keybindings = [
        # Return to editor / close explorer
        {
          key = "space e";
          command = "workbench.action.toggleSidebarVisibility";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "ctrl+w";
          command = "workbench.action.focusActiveEditorGroup";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "escape";
          command = "workbench.action.toggleSidebarVisibility";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "q";
          command = "workbench.action.toggleSidebarVisibility";
          when = "filesExplorerFocus && !inputFocus";
        }

        # Movement
        {
          key = "enter";
          command = "list.select";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "j";
          command = "list.focusDown";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "k";
          command = "list.focusUp";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "l";
          command = "list.select";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "o";
          command = "list.select";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "h";
          command = "list.collapse";
          when = "filesExplorerFocus && !inputFocus";
        }

        # File operations
        {
          key = "a";
          command = "explorer.newFile";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "shift+a";
          command = "explorer.newFolder";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "r";
          command = "renameFile";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "d";
          command = "deleteFile";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "c";
          command = "filesExplorer.copy";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "m";
          command = "filesExplorer.cut";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "x";
          command = "filesExplorer.cut";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "p";
          command = "filesExplorer.paste";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "y";
          command = "copyFilePath";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "f";
          command = "filesExplorer.findInFolder";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "s";
          command = "explorer.openToSide";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "shift+r";
          command = "workbench.files.action.refreshFilesExplorer";
          when = "filesExplorerFocus && !inputFocus";
        }
      ];
    };
  };

  # Launch-level kill switches, read by VSCode at startup.
  # argv.json accepts only a small allow-list of keys (it is schema-validated).
  # Telemetry is disabled via settings instead; only the crash reporter
  # is controllable at launch level.
  home.file.".vscode/argv.json" = pkgs.lib.mkIf hasGUI {
    force = true;
    text = builtins.toJSON {
      "enable-crash-reporter" = false;
    };
  };

  # Fast key repeat for VSCode so holding h/j/k/l moves continuously.
  # macOS reads these per-app defaults when VSCode starts.
  # KeyRepeat 1 is the fastest value; InitialKeyRepeat 15 is the shortest delay.
  launchd.agents.vscode-fast-keyrepeat = pkgs.lib.mkIf (hasGUI && pkgs.stdenv.isDarwin) {
    enable = true;
    config = {
      Label = "vscode-fast-keyrepeat";
      RunAtLoad = true;
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''
          defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
          defaults write com.microsoft.VSCode KeyRepeat -int 1
          defaults write com.microsoft.VSCode InitialKeyRepeat -int 15
        ''
      ];
    };
  };
}
