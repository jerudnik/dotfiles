;; -*- lexical-binding: t; -*-
;; org-config.el - Org-mode and org-supertag configuration

;; ============================================================================
;; Core Org-mode settings
;; ============================================================================

(use-package org
  :straight nil  ; Built-in
  :config
  ;; Directories
  (setq org-directory "~/Notes/org")
  (setq org-default-notes-file (concat org-directory "/inbox.org"))
  (setq org-agenda-files (list org-directory))
  
  ;; Visual settings
  (setq org-hide-emphasis-markers t)
  (setq org-startup-indented t)
  (setq org-startup-folded 'content)
  (setq org-ellipsis " ...")
  (setq org-pretty-entities t)
  
  ;; Behavior
  (setq org-return-follows-link t)
  (setq org-mouse-1-follows-link t)
  (setq org-link-descriptive t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  
  ;; Source blocks
  (setq org-src-fontify-natively t)
  (setq org-src-tab-acts-natively t)
  (setq org-src-preserve-indentation t)
  (setq org-edit-src-content-indentation 0)
  
  ;; Todo keywords
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))
  
  ;; Capture templates
  (setq org-capture-templates
        '(("t" "Todo" entry (file+headline org-default-notes-file "Tasks")
           "* TODO %?\n  %i\n  %a")
          ("n" "Note" entry (file+headline org-default-notes-file "Notes")
           "* %? :note:\n  %i\n  %a")
          ("j" "Journal" entry (file+datetree (concat org-directory "/journal.org"))
           "* %?\n  Entered on %U\n  %i")))
  
  :bind
  (("C-c a" . org-agenda)
   ("C-c c" . org-capture)
   ("C-c l" . org-store-link)))

;; ============================================================================
;; org-modern - Beautiful, modern Org styling
;; ============================================================================

(use-package org-modern
  :after org
  :hook
  ((org-mode . org-modern-mode)
   (org-agenda-finalize . org-modern-agenda))
  :config
  (setq org-modern-star '("" "" "" "" "" ""))
  (setq org-modern-hide-stars nil)
  (setq org-modern-table t)
  (setq org-modern-list '((?+ . "")
                          (?- . "")
                          (?* . "")))
  (setq org-modern-checkbox '((?X . "")
                              (?- . "")
                              (?\s . "")))
  (setq org-modern-tag t)
  (setq org-modern-priority t)
  (setq org-modern-todo t)
  (setq org-modern-block-fringe nil))

;; ============================================================================
;; org-appear - Show markup when cursor is on element
;; ============================================================================

(use-package org-appear
  :after org
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis t)
  (setq org-appear-autolinks t)
  (setq org-appear-autosubmarkers t)
  (setq org-appear-autoentities t)
  (setq org-appear-autokeywords t)
  (setq org-appear-inside-latex t))

;; ============================================================================
;; org-supertag - Tana-inspired programmable tags
;; ============================================================================

;; Install from GitHub via straight.el (not in MELPA/nixpkgs)
(use-package org-supertag
  :straight (org-supertag :type git
                          :host github
                          :repo "yibie/org-supertag")
  :after org
  :config
  ;; Set supertag data directory
  (setq org-supertag-directory (expand-file-name ".supertag" org-directory))
  
  ;; Initialize org-supertag
  (org-supertag-setup))

;; ============================================================================
;; Visual enhancements for Org
;; ============================================================================

;; Variable pitch font in Org (optional - looks nicer for prose)
(use-package mixed-pitch
  :hook (org-mode . mixed-pitch-mode)
  :config
  (setq mixed-pitch-set-height t))

;; Visual fill column for better reading
(use-package visual-fill-column
  :hook (org-mode . visual-fill-column-mode)
  :config
  (setq visual-fill-column-width 100)
  (setq visual-fill-column-center-text t))

(provide 'org-config)
