;;extend load path!
(add-to-list 'load-path "~/.emacs.d/")

;; kill toolbar and menubar etc...
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(menu-bar-mode nil)
 '(mouse-wheel-mode t)
 '(scroll-conservatively 1)
 '(tool-bar-mode nil)
 '(xterm-mouse-mode t))
(scroll-bar-mode -1)

;;modeline & modeline font color
(set-face-background 'modeline "#444444")
(set-face-foreground 'modeline "#dddddd")
(set-face-foreground 'scroll-bar "#444444")
(set-face-background 'scroll-bar "#444444")
;(set-face-font 'default "-windows-proggysquare-medium-r-normal--0-0-96-96-c-0-iso8859-1")

;;TABS ARE EVIL!
(setq-default indent-tabs-mode nil)
(define-key text-mode-map (kbd "<tab>") 'tab-to-tab-stop)
(setq c-basic-offset 4)
(setq tab-width 4)
(setq tab-stop-list '(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60
    64 68 72 76 80 84 88 92 96 100 104 108 112 116 120))

;;window settings
(setq default-frame-alist (append (list
  '(width  . 101)  ; Width set to # characters
  '(height . 50)) ; Height set to # lines
  default-frame-alist))

;;misc preferences
(setq x-stretch-cursor nil)
(setq scroll-step 1)
(line-number-mode 1)
(font-lock-mode 1)
(setq inhibit-startup-message t)
(setq inhibit-splash-screen t)
(defun yes-or-no-p (PROMPT)
  (y-or-n-p PROMPT))
(setq global-font-lock-mode t)
(setq transient-mark-mode t)
(setq tramp-default-method "ssh")
; share x clipboard
(setq x-select-enable-clipboard t)
(setq show-ws-style 'mark)

;;autoload added packages
(autoload 'python-mode "python-mode" "Python editing mode." t)
(autoload 'javascript-mode "javascript.elc" t)
(autoload 'show-whitespace-mode "show-whitespace-mode.elc" "see space itself!" t)

;;display file path instead of just filename
(setq-default mode-line-buffer-identification
              (cons "%b | %12f"
                    (cdr mode-line-buffer-identification)))

;;automode configs
(defun switch-to-other-buffer (i)  "switch to the default other buffer"
  (interactive "i") 
  (switch-to-buffer (other-buffer)))

;;key bindings
(global-set-key "\C-o" 'switch-to-other-buffer)
(global-set-key "\C-j" 'goto-line)
(global-set-key [mouse-5] 'next-line)
(global-set-key [mouse-4] 'previous-line)
;(global-set-key [mouse-5] 'scroll-up)
;(global-set-key [mouse-4] 'scroll-down)

;;set editing modes

(setq auto-mode-alist (cons '("\\.py$" . python-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.perl$" . perl-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.plx$" . perl-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.pl$" . perl-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.C$" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.cc$" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.c$" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.h$" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.cpp$" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.cxx$" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.sh$" . shell-script-mode) auto-mode-alist))
(cond
 ((string-match "22" (emacs-version))
  (setq auto-mode-alist (cons '("\\.xml$" . xml-mode) auto-mode-alist))
 )
)
(cond
 ((string-match "21" (emacs-version))
  (setq auto-mode-alist (cons '("\\.xml$" . sgml-mode) auto-mode-alist))
 )
)
(setq auto-mode-alist (cons '("\\.css$" . css-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.html$" . html-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.htm$" . html-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.tmpl$" . html-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.spec$" . rpm-spec-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.spec.in$" . rpm-spec-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.pro$" . idl-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.sh$" . sh-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.tex$" . latex-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.js$" . javascript-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.sql$" . sql-mode) auto-mode-alist))

(setq python-mode-hook '(lambda () (font-lock-mode 1))
      c++-mode-hook '(lambda () (font-lock-mode 1))
      c-mode-hook '(lambda () (font-lock-mode 1))
      lisp-mode-hook '(lambda () (font-lock-mode 1))
      shell-script-mode-hook '(lambda () (font-lock-mode 1))
      perl-mode-hook '(lambda () (font-lock-mode 1))
      shell-mode-hook '(lambda () (font-lock-mode 1))
      tex-mode-hook '(lambda () (font-lock-mode 1))
      xml-mode-hook '(lambda () (font-lock-mode 1))
      sgml-mode-hook '(lambda () (font-lock-mode 1))
      html-mode-hook '(lambda () (font-lock-mode 1))
      css-mode-hook '(lambda () (font-lock-mode 1))
      rpm-spec-mode-hook '(lambda () (font-lock-mode 1))
      idl-mode-hook '(lambda () (font-lock-mode 1))
      sh-mode-hook '(lambda () (font-lock-mode 1))
      latex-mode-hook '(lambda () (font-lock-mode 1))
      javascript-mode-hook '(lambda () (font-lock-mode 1))
      sql-mode-hook '(lambda () (font-lock-mode 1)))
 
;;functions!
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(region ((t (:background "blue")))))
