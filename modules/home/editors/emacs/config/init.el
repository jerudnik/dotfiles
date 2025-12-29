;; -*- lexical-binding: t; -*-
;; init.el - Main Emacs configuration entry point

;; Reset GC threshold after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024))  ; 16MB
            (setq gc-cons-percentage 0.1)))

;; ============================================================================
;; straight.el bootstrap
;; ============================================================================

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
                         (or (bound-and-true-p straight-base-dir)
                             user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Use straight.el for use-package
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;; ============================================================================
;; Load modular configuration
;; ============================================================================

(add-to-list 'load-path (expand-file-name "modules" user-emacs-directory))

;; Core settings, theme, and macOS integration
(require 'defaults)

;; Hybrid macOS/Emacs keybindings
(require 'keybindings)

;; Completion framework (Vertico, Consult, etc.)
(require 'completion)

;; Org-mode and org-supertag configuration
(require 'org-config)

;; ============================================================================
;; Custom file (keep init.el clean)
;; ============================================================================

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file 'noerror 'nomessage))
