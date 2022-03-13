{ config, lib, pkgs, flakeInputs, ... }:
with lib;

let
  cfg = config.queezle.emacs;

  customHunspell = pkgs.hunspellWithDicts [
    pkgs.hunspellDicts.de_DE
    pkgs.hunspellDicts.en_US-large
  ];

  extraEmacsPackages = final: prev: {
    emacsPackagesFor = emacs: (prev.emacsPackagesFor emacs).overrideScope' (
      efinal: eprev: {
        term-cursor = efinal.trivialBuild ({
          pname = "term-cursor";
          src = flakeInputs.emacs-term-cursor;
        });

        tsc-dyn = pkgs.callPackage (
          { lib , rustPlatform , llvmPackages }:
          rustPlatform.buildRustPackage {
            version = efinal.tsc.version;
            src = efinal.tsc.src;

            pname = "tsc-dyn";
            commit = efinal.tsc.version;

            nativeBuildInputs = [ llvmPackages.clang ];
            sourceRoot = "source/core";

            configurePhase = ''
              export LIBCLANG_PATH="${llvmPackages.libclang.lib}/lib"
            '';

            postInstall = ''
              LIB=($out/lib/libtsc_dyn.*)
              TSC_PATH=$out/share/emacs/site-lisp/elpa/tsc-${version}
              install -d $TSC_PATH
              install -m444 $out/lib/libtsc_dyn.* $TSC_PATH/''${LIB/*libtsc_/tsc-}
              echo -n $version > $TSC_PATH/DYN-VERSION
              rm -r $out/lib
            '';

            cargoSha256 = "sha256-JHBIOVNRjOpFcUSzLlMrO4dmOdAY9RecglXrF9c3tRg=";
        }) {};
      }
    );
  };

  emacsWithPackages = (pkgs.emacsPackagesFor pkgs.emacsPgtkGcc).withPackages;

  emacs-queezle = emacsWithPackages (epkgs: [(config-queezle epkgs)]);

  config-queezle = epkgs: (epkgs.trivialBuild ({
    pname = "config-queezle";
    src = defaultFile;
    packageRequires = [
      epkgs.term-cursor
      #epkgs.tsc-dyn
      #pkgs.notmuch   # From main packages set
    ] ++
    (with epkgs.melpaStablePackages; [
      magit
      helm-projectile
      which-key
      smart-mode-line
    ]) ++ (with epkgs.melpaPackages; [
      solaire-mode
      doom-themes
      gruvbox-theme
      evil
      evil-collection
      evil-surround
      evil-commentary
      evil-easymotion
      evil-visualstar
      helm
      projectile

      treemacs
      treemacs-evil
      treemacs-projectile
      treemacs-magit

      flycheck
      lsp-mode
      lsp-ui
      company

      #epkgs.tree-sitter
      # Build system is a mess
      #epkgs.tree-sitter-langs

      lsp-haskell
      nix-mode
      #zoom-frm       # ; increase/decrease font size for all buffers %lt;C-x C-+>
    ]) ++ (with epkgs.elpaPackages; [
      # <C-x u> to show the undo tree
      undo-tree
      #auctex         # ; LaTeX mode
      #beacon         # ; highlight my cursor when scrolling
      #nameless       # ; hide current package name everywhere in elisp code
    ]);
  }));




  defaultFile = pkgs.writeText "default.el" init;
  initFile = pkgs.writeText "init.el" init;

  early-init = pkgs.writeText "early-init.el" ''
    ;;; early-init: loaded before the package system and gui are initialized

    ;; Makes impure packages archives unavailable
    (setq package-archives nil)

    ;; Turn off UI elements before the window is shown
    (menu-bar-mode -1)
    (tool-bar-mode -1)
    (scroll-bar-mode -1)

    ;; Font size (in pt*10)
    (set-face-attribute 'default nil :height 105)
  '';

  init = ''
    ;;; general settings

    ;; Inhibit startup screen (ignored by emacs if put directly in default.el)
    (add-hook 'after-init-hook (lambda () (setq inhibit-startup-screen t)))

    ;; Inhibit startup message. Emacs _really_ wants you to personalize this variable by putting in your username manually. This is not practical for me since I use the same config across multiple users (personal, work, development sandboxes).
    (put 'inhibit-startup-echo-area-message 'saved-value
      (setq inhibit-startup-echo-area-message (user-login-name)))

    ;; Show init time on startup
    (add-hook 'emacs-startup-hook (lambda () (message "Initialized in %s" (emacs-init-time))))

    (setq mouse-wheel-progressive-speed nil)
    (pixel-scroll-precision-mode)

    (xterm-mouse-mode)

    ;; 100mb GC threshold since lsp generates a lot of garbage
    (setq gc-cons-threshold 100000000)

    ;; Read 1Mb from processes since some lsp responses are multiple megabytes large
    (setq read-process-output-max (* 1024 1024))

    ;; Don't write customizations to `.emacs`
    (setq custom-file "~/.emacs.d/custom.el")

    ;; Backup files
    (setq backup-path "~/.emacs.d/backup")
    (if
      (not (file-exists-p (directory-file-name backup-path)))
      (make-directory (directory-file-name backup-path))
    )

    (setq
      backup-directory-alist `((".*" . ,(directory-file-name backup-path)))
      auto-save-file-name-transforms `((".*" ,(directory-file-name backup-path) t))
      auto-save-list-file-prefix (directory-file-name backup-path)
    )


    (global-display-line-numbers-mode)
    (column-number-mode)

    (setq-default show-trailing-whitespace t)
    (add-hook 'before-save-hook 'delete-trailing-whitespace)

    (global-hl-line-mode)


    ;;; evil/editing

    ;; has to be initialized early so evil isn't loaded as a dependency before setting up variables

    (setq
      evil-want-keybinding nil ; handled by evil-collection
      evil-want-C-u-scroll t
      evil-undo-system 'undo-tree
      evil-want-C-u-delete t
      evil-collection-setup-minibuffer t
    )

    (evil-collection-init)
    (evil-mode 1)

    (evil-set-leader 'normal (kbd "SPC"))

    ;; C-SPC (set-mark) is not required with evil and could be reused
    ;(keymap-global-unset "C-SPC")

    (global-evil-surround-mode 1)
    (evil-commentary-mode)
    (global-evil-visualstar-mode)

    (keymap-set evil-normal-state-map "C-s" #'save-buffer)

    (global-undo-tree-mode)

    ;; easymotion
    (evilem-default-keybindings "<leader> SPC")

    ;; easymotion change word-based commands to seek across lines
    (with-eval-after-load 'evil-easymotion
      (eval-when-compile (require 'evil-easymotion))
      (evilem-make-motion evilem-motion-forward-word-begin #'evil-forward-word-begin)
      (evilem-make-motion evilem-motion-forward-WORD-begin #'evil-forward-WORD-begin)
      (evilem-make-motion evilem-motion-forward-word-end #'evil-forward-word-end)
      (evilem-make-motion evilem-motion-forward-WORD-end #'evil-forward-WORD-end)
      (evilem-make-motion evilem-motion-backward-word-begin #'evil-backward-word-begin)
      (evilem-make-motion evilem-motion-backward-WORD-begin #'evil-backward-WORD-begin)
      (evilem-make-motion evilem-motion-backward-word-end #'evil-backward-word-end)
      (evilem-make-motion evilem-motion-backward-WORD-end #'evil-backward-WORD-end))


    ;; TODO Move C-p functionality to C-b
    ;; TODO Maybe use C-a and C-y (or C-ö/C-ä) for evil-numbers
    ;; in/out across files

    ;;; indentation

    (setq-default
      indent-tabs-mode nil
      tab-width 2
      evil-shift-width 2
    )


    ;;; theme

    ;; Darker background for utility buffers
    (solaire-global-mode +1)

    (setq doom-themes-enable-bold t
          doom-themes-enable-italic t)
    (load-theme 'doom-gruvbox t)

    ;; smart-mode-line + don't ask when loading themes
    (setq
      sml/no-confirm-load-theme t
      sml/name-width '(1 . 44))
    (sml/setup)


    ;;; terminal

    (require 'term-cursor)
    ;; breaks lsp-ui
    ;(global-term-cursor-mode)

    ;; foot is an xterm-compatible terminal
    ;; 24bit-colors require COLORTERM=truecolor (not sent by SSH by default)
    (add-to-list 'term-file-aliases '("foot" . "xterm"))


    ;;; ide

    (global-flycheck-mode)
    (setq lsp-keymap-prefix "<leader> l")
    (setq lsp-ui-sideline-show-code-actions t)
    (setq lsp-haskell-plugin-import-lens-code-lens-on nil)
    (add-hook 'haskell-mode-hook #'lsp)
    (keymap-global-set "<leader> h" #'lsp-ui-doc-show)


    ;;; helm

    (setq helm-command-prefix-key "<leader> c")
    (keymap-global-set "M-x" #'helm-M-x)
    (keymap-global-set "C-x r b" #'helm-filtered-bookmarks)
    (keymap-global-set "C-x C-f" #'helm-find-files)
    (helm-mode 1)


    ;;; project management

    (require 'projectile)
    (keymap-set projectile-mode-map "<leader> p" #'projectile-command-map)
    (projectile-mode +1)

    (keymap-unset evil-normal-state-map "C-p" t)
    (keymap-set projectile-mode-map "C-p" #'helm-projectile)


    ;;; treemacs

    (setq treemacs-no-png-images t)
    (require 'treemacs-evil)

    (set-face-attribute 'treemacs-root-face nil :height 1.0)

    ;; I'm unhappy with this keybinding
    (keymap-global-set "<leader> t" #'treemacs)


    ;;; which-key

    (setq which-key-idle-delay 0.8
      which-key-idle-secondary-delay 0.05)
    (which-key-mode)
    (with-eval-after-load 'lsp-mode
      (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))
  '';

  #tree-sitter-init = ''
  #  ;;; tree-sitter

  #  ;; Use nix-provided tree-sitter
  #  (setq tsc-dyn-get-from nil)

  #  (setq tree-sitter-load-path '("${tree-sitter-grammars}"))
  #'';

  tree-sitter-grammars = pkgs.runCommand "tree-sitter-grammars" {} ''
      mkdir -p $out/bin
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: src: "name=${name}; ln -s ${src}/parser $out/bin/\${name#tree-sitter-}.so") pkgs.tree-sitter.builtGrammars)};
    '';

in {
  options.queezle.emacs = {
    enable = mkEnableOption "queezles emacs configuration";

    user = mkOption {
      type = types.str;
      default = "jens";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ extraEmacsPackages ];

    environment.systemPackages = [
      emacs-queezle
      customHunspell
      pkgs.tree-sitter
    ];

    home-manager.users."${cfg.user}".home.file = {
      ".emacs.d/early-init.el" = {
        source = early-init;
      };
      #".emacs.d/init.el" = {
      #  source = initFile;
      #};
    };
  };
}
