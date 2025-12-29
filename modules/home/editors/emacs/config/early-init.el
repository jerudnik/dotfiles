;; -*- lexical-binding: t; -*-
;; early-init.el - Loaded before init.el, before package and UI initialization

;; Increase GC threshold during startup for faster loading
(setq gc-cons-threshold most-positive-fixnum)
(setq gc-cons-percentage 0.6)

;; Disable package.el in favor of straight.el
(setq package-enable-at-startup nil)

;; Prevent the glimpse of un-styled Emacs by disabling UI elements early
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; Disable menu bar, tool bar, and scroll bar
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Prevent resizing frame when font changes
(setq frame-inhibit-implied-resize t)

;; Disable startup screen
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)

;; Native compilation settings
(when (featurep 'native-compile)
  ;; Silence compiler warnings
  (setq native-comp-async-report-warnings-errors nil)
  ;; Enable deferred compilation
  (setq native-comp-deferred-compilation t)
  ;; Set the directory for native compilation cache
  (when (boundp 'native-comp-eln-load-path)
    (add-to-list 'native-comp-eln-load-path
                 (expand-file-name "eln-cache/" user-emacs-directory))))

;; Prevent unwanted runtime builds; packages are compiled ahead-of-time
(setq comp-deferred-compilation nil)
