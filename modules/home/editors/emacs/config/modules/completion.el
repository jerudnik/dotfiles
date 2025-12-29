;; -*- lexical-binding: t; -*-
;; completion.el - Modern completion framework (Vertico stack)

;; ============================================================================
;; Vertico - Vertical interactive completion
;; ============================================================================

(use-package vertico
  :init
  (vertico-mode 1)
  :config
  (setq vertico-cycle t)
  (setq vertico-count 15))

;; vertico-directory - Directory navigation extensions
(use-package vertico-directory
  :straight nil
  :after vertico
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

;; ============================================================================
;; Orderless - Flexible completion matching
;; ============================================================================

(use-package orderless
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrides '((file (styles partial-completion)))))

;; ============================================================================
;; Marginalia - Rich annotations in minibuffer
;; ============================================================================

(use-package marginalia
  :init
  (marginalia-mode 1)
  :config
  (setq marginalia-annotators '(marginalia-annotators-heavy
                                marginalia-annotators-light
                                nil)))

;; ============================================================================
;; Consult - Enhanced search and navigation commands
;; ============================================================================

(use-package consult
  :bind
  (;; C-c bindings (mode-specific-map)
   ("C-c h" . consult-history)
   ("C-c m" . consult-mode-command)
   
   ;; C-x bindings (ctl-x-map)
   ("C-x b" . consult-buffer)
   ("C-x 4 b" . consult-buffer-other-window)
   ("C-x 5 b" . consult-buffer-other-frame)
   ("C-x r b" . consult-bookmark)
   ("C-x p b" . consult-project-buffer)
   
   ;; M-g bindings (goto-map)
   ("M-g e" . consult-compile-error)
   ("M-g f" . consult-flymake)
   ("M-g g" . consult-goto-line)
   ("M-g M-g" . consult-goto-line)
   ("M-g o" . consult-outline)
   ("M-g m" . consult-mark)
   ("M-g k" . consult-global-mark)
   ("M-g i" . consult-imenu)
   ("M-g I" . consult-imenu-multi)
   
   ;; M-s bindings (search-map)
   ("M-s d" . consult-find)
   ("M-s D" . consult-locate)
   ("M-s g" . consult-grep)
   ("M-s G" . consult-git-grep)
   ("M-s r" . consult-ripgrep)
   ("M-s l" . consult-line)
   ("M-s L" . consult-line-multi)
   ("M-s k" . consult-keep-lines)
   ("M-s u" . consult-focus-lines)
   
   ;; Isearch integration
   ("M-s e" . consult-isearch-history)
   :map isearch-mode-map
   ("M-e" . consult-isearch-history)
   ("M-s e" . consult-isearch-history)
   ("M-s l" . consult-line)
   ("M-s L" . consult-line-multi)
   
   ;; Minibuffer history
   :map minibuffer-local-map
   ("M-s" . consult-history)
   ("M-r" . consult-history))
  
  :init
  ;; Use Consult for completion-at-point
  (setq xref-show-xrefs-function #'consult-xref)
  (setq xref-show-definitions-function #'consult-xref)
  
  :config
  ;; Preview settings
  (setq consult-preview-key "M-.")
  
  ;; Configure ripgrep
  (setq consult-ripgrep-args
        "rg --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --no-heading --with-filename --line-number --search-zip"))

;; Override macOS find shortcuts with Consult
(with-eval-after-load 'keybindings
  (global-set-key (kbd "s-f") 'consult-line)           ; Cmd+F = Find in buffer
  (global-set-key (kbd "s-F") 'consult-ripgrep))       ; Cmd+Shift+F = Find in project

;; ============================================================================
;; Embark - Contextual actions
;; ============================================================================

(use-package embark
  :bind
  (("C-." . embark-act)         ; Pick action on target
   ("C-;" . embark-dwim)        ; Do What I Mean
   ("C-h B" . embark-bindings)) ; Show bindings for prefix
  
  :init
  ;; Use Embark to show bindings in a key prefix with `C-h`
  (setq prefix-help-command #'embark-prefix-help-command)
  
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Embark-Consult integration
(use-package embark-consult
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; ============================================================================
;; Corfu - In-buffer completion popup
;; ============================================================================

(use-package corfu
  :init
  (global-corfu-mode 1)
  :config
  (setq corfu-auto t)           ; Enable auto-completion
  (setq corfu-auto-delay 0.2)   ; Delay before popup
  (setq corfu-auto-prefix 2)    ; Min chars before popup
  (setq corfu-cycle t)          ; Enable cycling
  (setq corfu-quit-no-match t)) ; Quit if no match

;; Cape - Corfu completion extensions
(use-package cape
  :init
  ;; Add useful completions
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block))

;; ============================================================================
;; Savehist - Persist minibuffer history
;; ============================================================================

(use-package savehist
  :straight nil
  :init
  (savehist-mode 1)
  :config
  (setq savehist-additional-variables
        '(search-ring regexp-search-ring)))

(provide 'completion)
