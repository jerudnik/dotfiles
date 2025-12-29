;; -*- lexical-binding: t; -*-
;; keybindings.el - Hybrid macOS/Emacs keybinding configuration

;; ============================================================================
;; Philosophy:
;; - Super (Command) for macOS-familiar shortcuts (save, copy, paste, etc.)
;; - Control for Emacs power commands (C-x, C-c prefix maps)
;; - Meta (Option) for Emacs editing commands (M-x, M-w, etc.)
;; ============================================================================

;; ============================================================================
;; macOS-style bindings (Super/Command key)
;; ============================================================================

;; File operations
(global-set-key (kbd "s-s") 'save-buffer)              ; Cmd+S = Save
(global-set-key (kbd "s-S") 'write-file)               ; Cmd+Shift+S = Save As
(global-set-key (kbd "s-o") 'find-file)                ; Cmd+O = Open
(global-set-key (kbd "s-w") 'delete-window)            ; Cmd+W = Close window
(global-set-key (kbd "s-W") 'delete-frame)             ; Cmd+Shift+W = Close frame
(global-set-key (kbd "s-q") 'save-buffers-kill-emacs)  ; Cmd+Q = Quit
(global-set-key (kbd "s-n") 'make-frame)               ; Cmd+N = New window

;; Edit operations
(global-set-key (kbd "s-z") 'undo)                     ; Cmd+Z = Undo
(global-set-key (kbd "s-Z") 'undo-redo)                ; Cmd+Shift+Z = Redo
(global-set-key (kbd "s-x") 'kill-region)              ; Cmd+X = Cut
(global-set-key (kbd "s-c") 'kill-ring-save)           ; Cmd+C = Copy
(global-set-key (kbd "s-v") 'yank)                     ; Cmd+V = Paste
(global-set-key (kbd "s-a") 'mark-whole-buffer)        ; Cmd+A = Select All

;; Search - will be enhanced by Consult in completion.el
(global-set-key (kbd "s-f") 'isearch-forward)          ; Cmd+F = Find (overridden by consult-line)
(global-set-key (kbd "s-F") 'isearch-forward-regexp)   ; Cmd+Shift+F = Find regex
(global-set-key (kbd "s-g") 'isearch-repeat-forward)   ; Cmd+G = Find next
(global-set-key (kbd "s-G") 'isearch-repeat-backward)  ; Cmd+Shift+G = Find previous
(global-set-key (kbd "s-r") 'query-replace)            ; Cmd+R = Replace
(global-set-key (kbd "s-R") 'query-replace-regexp)     ; Cmd+Shift+R = Replace regex

;; Navigation
(global-set-key (kbd "s-l") 'goto-line)                ; Cmd+L = Go to line
(global-set-key (kbd "s-<left>") 'beginning-of-line)   ; Cmd+Left = Line start
(global-set-key (kbd "s-<right>") 'end-of-line)        ; Cmd+Right = Line end
(global-set-key (kbd "s-<up>") 'beginning-of-buffer)   ; Cmd+Up = Buffer start
(global-set-key (kbd "s-<down>") 'end-of-buffer)       ; Cmd+Down = Buffer end

;; Word navigation (Option/Meta + arrows)
(global-set-key (kbd "M-<left>") 'backward-word)
(global-set-key (kbd "M-<right>") 'forward-word)

;; Buffer navigation
(global-set-key (kbd "s-{") 'previous-buffer)          ; Cmd+{ = Previous buffer
(global-set-key (kbd "s-}") 'next-buffer)              ; Cmd+} = Next buffer
(global-set-key (kbd "s-`") 'other-frame)              ; Cmd+` = Next frame

;; Window management
(global-set-key (kbd "s-1") 'delete-other-windows)     ; Cmd+1 = Single window
(global-set-key (kbd "s-2") 'split-window-below)       ; Cmd+2 = Split horizontal
(global-set-key (kbd "s-3") 'split-window-right)       ; Cmd+3 = Split vertical
(global-set-key (kbd "s-0") 'delete-window)            ; Cmd+0 = Close window

;; Text sizing
(global-set-key (kbd "s-+") 'text-scale-increase)      ; Cmd++ = Zoom in
(global-set-key (kbd "s-=") 'text-scale-increase)      ; Cmd+= = Zoom in
(global-set-key (kbd "s--") 'text-scale-decrease)      ; Cmd+- = Zoom out

;; Command palette style (M-x)
(global-set-key (kbd "s-P") 'execute-extended-command) ; Cmd+Shift+P = Command palette

;; ============================================================================
;; Disable annoying macOS defaults
;; ============================================================================

(global-unset-key (kbd "s-t"))   ; Disable font panel
(global-unset-key (kbd "s-p"))   ; Disable print dialog (use C-x C-p if needed)
(global-unset-key (kbd "s-m"))   ; Disable minimize
(global-unset-key (kbd "s-h"))   ; Disable hide

;; ============================================================================
;; Enhanced Emacs bindings
;; ============================================================================

;; Better buffer switching (will be overridden by Consult)
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; Easier window navigation
(global-set-key (kbd "M-o") 'other-window)

;; Kill current buffer without confirmation
(global-set-key (kbd "C-x k") 'kill-current-buffer)

;; Comment/uncomment
(global-set-key (kbd "s-/") 'comment-dwim)             ; Cmd+/ = Toggle comment

;; ============================================================================
;; Avy - Jump to visible text
;; ============================================================================

(use-package avy
  :bind
  (("C-'" . avy-goto-char-timer)    ; Jump to char
   ("M-g w" . avy-goto-word-1)       ; Jump to word
   ("M-g l" . avy-goto-line)))       ; Jump to line

(provide 'keybindings)
