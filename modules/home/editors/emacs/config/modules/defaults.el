;; -*- lexical-binding: t; -*-
;; defaults.el - Sensible defaults, theme, and macOS integration

;; ============================================================================
;; macOS: Inherit shell environment
;; ============================================================================

(use-package exec-path-from-shell
  :init
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; ============================================================================
;; Theme: Modus Themes (matches Stylix)
;; ============================================================================

(use-package modus-themes
  :init
  ;; Customizations before loading theme
  (setq modus-themes-italic-constructs t)
  (setq modus-themes-bold-constructs t)
  (setq modus-themes-mixed-fonts t)
  (setq modus-themes-org-blocks 'tinted-background)
  
  ;; Load dark theme by default (modus-vivendi)
  ;; Switch with M-x modus-themes-toggle
  :config
  (load-theme 'modus-vivendi t))

;; ============================================================================
;; macOS-specific settings
;; ============================================================================

(when (eq system-type 'darwin)
  ;; Key modifiers:
  ;; - Command (super) for macOS-style shortcuts (s-s, s-c, s-v, etc.)
  ;; - Option (meta) for Emacs power commands (M-x, M-w, etc.)
  ;; - Control for Emacs standard bindings (C-x, C-c, etc.)
  (setq mac-option-modifier 'meta)
  (setq mac-command-modifier 'super)
  (setq mac-right-option-modifier 'none)  ; Allow special characters
  
  ;; Use macOS native fullscreen
  (setq ns-use-native-fullscreen t)
  
  ;; Smooth scrolling
  (setq ns-use-mwheel-momentum t)
  
  ;; Use system trash
  (setq trash-directory "~/.Trash")
  (setq delete-by-moving-to-trash t))

;; ============================================================================
;; System clipboard integration
;; ============================================================================

(setq select-enable-clipboard t)
(setq select-enable-primary t)

;; ============================================================================
;; UI improvements
;; ============================================================================

;; Line numbers (except in certain modes)
(global-display-line-numbers-mode 1)
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Column number in mode line
(column-number-mode 1)

;; Highlight current line
(global-hl-line-mode 1)

;; Show matching parentheses
(show-paren-mode 1)
(setq show-paren-delay 0)

;; Smooth scrolling
(setq scroll-conservatively 101)
(setq scroll-margin 3)
(setq scroll-preserve-screen-position t)

;; Better frame title
(setq frame-title-format '("%b - Emacs"))

;; ============================================================================
;; Better defaults
;; ============================================================================

;; UTF-8 everywhere
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)

;; Use spaces, not tabs
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

;; Disable bell
(setq ring-bell-function 'ignore)

;; y/n instead of yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; Don't create backup/lock files
(setq make-backup-files nil)
(setq create-lockfiles nil)
(setq auto-save-default nil)

;; Remember recent files
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 100)

;; Remember cursor position
(save-place-mode 1)

;; Auto-revert files when changed on disk
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

;; Delete selection when typing
(delete-selection-mode 1)

;; Better handling of long lines
(setq-default truncate-lines t)
(setq truncate-partial-width-windows nil)

;; ============================================================================
;; Discoverability helpers
;; ============================================================================

;; which-key: Show available keybindings in popup
(use-package which-key
  :diminish
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 0.3)
  (setq which-key-popup-type 'side-window)
  (setq which-key-side-window-location 'bottom))

;; helpful: Better *help* buffers
(use-package helpful
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key)
  ([remap describe-command] . helpful-command))

;; diminish: Hide minor modes from mode line
(use-package diminish)

(provide 'defaults)
