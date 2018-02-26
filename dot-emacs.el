;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; James Endres Howell             .emacs (initialization file)
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(message "Evaluating .emacs")
(message "CHECKPOINT 1")

;; Making emacs find latex (so that C-c C-x C-l works on orgmode)
(setenv "PATH" (concat ":/Library/TeX/texbin/" (getenv "PATH")))
(add-to-list 'exec-path "/Library/TeX/texbin/")

;; allow for export=>beamer by placing

;; #+LaTeX_CLASS: beamer in org files
(unless (boundp 'org-export-latex-classes)
  (setq org-export-latex-classes nil))
(add-to-list 'org-export-latex-classes
  ;; beamer class, for presentations
  '("beamer"
     "\\documentclass[11pt]{beamer}\n
      \\mode<{{{beamermode}}}>\n
      \\usetheme{{{{beamertheme}}}}\n
      \\usecolortheme{{{{beamercolortheme}}}}\n
      \\beamertemplateballitem\n
      \\setbeameroption{show notes}
      \\usepackage[utf8]{inputenc}\n
      \\usepackage[T1]{fontenc}\n
      \\usepackage{hyperref}\n
      \\usepackage{color}
      \\usepackage{listings}
      \\lstset{numbers=none,language=[ISO]C++,tabsize=4,
  frame=single,
  basicstyle=\\small,
  showspaces=false,showstringspaces=false,
  showtabs=false,
  keywordstyle=\\color{blue}\\bfseries,
  commentstyle=\\color{red},
  }\n
      \\usepackage{verbatim}\n
      \\institute{{{{beamerinstitute}}}}\n          
       \\subject{{{{beamersubject}}}}\n"

     ("\\section{%s}" . "\\section*{%s}")
     
     ("\\begin{frame}[fragile]\\frametitle{%s}"
       "\\end{frame}"
       "\\begin{frame}[fragile]\\frametitle{%s}"
       "\\end{frame}")))

  ;; letter class, for formal letters

  (add-to-list 'org-export-latex-classes

  '("letter"
     "\\documentclass[11pt]{letter}\n
      \\usepackage[utf8]{inputenc}\n
      \\usepackage[T1]{fontenc}\n
      \\usepackage{color}"
     
     ("\\section{%s}" . "\\section*{%s}")
     ("\\subsection{%s}" . "\\subsection*{%s}")
     ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
     ("\\paragraph{%s}" . "\\paragraph*{%s}")
     ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))


(message "CHECKPOINT 2")




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Set the default "load-path" to my "emacs" directory
;;; KEEP THESE DECLARATIONS AT THE TOP:
;;; Everything below depends on the correct path.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq load-path (cons "~/Emacs/" load-path))
(setq load-path (cons "~/Emacs/elisp" load-path))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; package configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'package)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("melpa-stable" . "https://stable.melpa.org/packages/")))
(package-initialize)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; lorem-ipsum
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'lorem-ipsum)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; darkroom.el
;;; 
;;; "minimalist" editing mode: fewer distractions?
;;; M-x darkroom-mode removes mode-line and increases margins
;;; (Nice for full-screen text editing.)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(require 'darkroom)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; real-auto-save
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'real-auto-save)
(setq real-auto-save-interval 5) ;; in seconds

(message "CHECKPOINT 3")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; org-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'org)

;; I want these keys to work from everywhere
;; (although it must be admitted I RARELY use org-store-link)
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)


(message "CHECKPOINT 3.1")
;; embed youtube videos via org-link
;; stolen from
;; http://endlessparentheses.com/embedding-youtube-videos-with-org-mode-links.html

;; Embed code looks like this:
;; <iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/YMRhXeiANiA?rel=0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

(defvar youtube-iframe-format
  (concat "<iframe width=\"560\" height=\"315\""
          " src=\"https://www.youtube-nocookie.com/embed/%s"
          "?rel=0 frameborder=\"0\" allowfullscreen></iframe>"))

(message "CHECKPOINT 3.2")
(org-add-link-type "youtube-embed"
 (lambda (handle)
   (browse-url (concat "https://www.youtube-nocookie.com/embed/" handle)))
 (lambda (path desc backend)
   (cl-case backend
     (html (format youtube-iframe-format
                   path (or (concat desc " (embedded YouTube video)"  "")))
     (latex (format "\href{%s}{%s}"
                    path (or desc "video")))))))

(message "CHECKPOINT 3.3")

;; Define org-agenda-files list recursively
(load-library "find-lisp")
(setq org-agenda-files (append (find-lisp-find-files "~/Org-files/" "\.org$") (find-lisp-find-files "~/Teaching/" "\.org$")))

(message "CHECKPOINT 3.4")
;; Default to smart quotes for export (eg LaTeX, HTML)
(setq org-export-with-smart-quotes t)

(add-hook 'org-mode-hook 'real-auto-save-mode)
(add-hook 'org-mode-hook 'auto-fill-mode)
(add-hook 'org-mode-hook 'turn-on-font-lock) ; not needed when global-font-lock-mode is on


(message "CHECKPOINT 3.4")
(add-hook 'org-export-first-hook 
	  (setq org-export-creator-string
		(concat "Org-mode " (org-version)
			" (Emacs " (number-to-string emacs-major-version)
			"." (number-to-string emacs-minor-version) ")")))


(message "CHECKPOINT 3.5")
(defun jeh/set-org-mode-keys ()
  ;; I use narrow and widen all the time to focus on one subtree
  (local-set-key (kbd "C-c n") 'org-narrow-to-subtree)
  (local-set-key (kbd "C-c N") 'widen)
  (local-set-key (kbd "C-c C-.") 'org-archive-subtree)

  ;; insert a hyperlink
  (local-set-key (kbd "C-c C-S-l")
		 (lambda () (interactive)
		   (insert "[[][text]]")
		   (backward-char 6)))

  ;; More keybinding customization:
  ;; Generally in emacs, Ctrl-up/down arrows move backward/forward by a
  ;; "paragraph," but this is rarely useful and mostly confusing behavior.
  ;; It makes more sense (to me) for Ctrl-up/down arrows to do
  ;; the same thing as Meta-up/down arrows; and simply give up the default
  ;; jumping behavior of Ctrl-up/down within org-mode
  ;; org-metadown[up] calls `org-move-subtree-down[up]' or `org-table-move-row[up]' or
  ;; `org-move-item-down[up]', depending on context.
  (local-set-key (kbd "<C-up>") 'org-metaup)
  (local-set-key (kbd "<C-down>") 'org-metadown))

(add-hook 'org-mode-hook 'jeh/set-org-mode-keys)
(message "CHECKPOINT 3.6")


; The following makes M-return put the next outline heading on
; the next line, rather than after the intervening text. When I
; type free-form outlines, such insertions tend to be orphaned
; rubbish rather than subordinate content.
(setq org-insert-heading-respect-content nil)

(setq org-hide-leading-stars t)
(setq org-startup-folded t)
(setq org-align-all-tags t)

(message "CHECKPOINT 4")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ibuffer
;;;
;;; A dired-style buffer-based interface for switching buffers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key (kbd "C-x b") 'ibuffer)
(add-hook 'ibuffer-mode-hook 'hl-line-mode) ;;; highlight line at mark

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; dired
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'dired-mode-hook 'hl-line-mode)  ;;; highlight line at mark

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Fix Aquamacs-specific horrors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Just for Aquamacs, supress awful faces
(setq aquamacs-autoface-mode nil)
; Just for Aquamacs, supress new frame for help buffers
(setq special-display-regexps (remove "[ ]?\\*[hH]elp.*" special-display-regexps))
; Just for Aquamacs, custom obnoxious welcome message
(setq inhibit-startup-echo-area-message t)


(message "CHECKPOINT 5")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; basic emacs configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun xah-toggle-line-spacing ()
  "Toggle line spacing between no extra space to extra half line height."
  (interactive)
  (if (eq line-spacing nil)
      (setq line-spacing 0.15) ; add 0.15 height between lines
    (setq line-spacing nil)   ; no extra heigh between lines
    )
  (redraw-frame (selected-frame)))

(global-set-key (kbd "C-S-l") 'xah-toggle-line-spacing)



(add-hook 'text-mode-hook 'auto-fill-mode)
(setq sentence-end-double-space nil)
(setq fill-column 40)
(setq inhibit-startup-message t)
(setq initial-scratch-message "")

;;; For some reason, PATH does not get set correctly, and Emacs
;;; (i.e. "EMacs for OSX," my otherwise preferred version,
;;; or the "GUI version" as Aaron Bieber calls it)
;;; cannot see pdflatex. See https://tex.stackexchange.com/questions/24510/pdflatex-fails-within-emacs-app-but-works-in-terminal
(setenv "PATH"
	(concat "/Library/TeX/texbin/" ":"(getenv "PATH")))

(message "Tool-bar gorp")
;; turn off toolbar
(if window-system
    (tool-bar-mode 0))
(message "Tool-bar DONE")

(menu-bar-mode -1)
(setq line-spacing 0.2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Store emacs "autosave" files (#foo#)
;;;             and backup files (foo~)
;;; hidden away in special directories
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(make-directory "~/Emacs/autosave-files/" t)     ;; create the autosave dir if necessary
(make-directory "~/Emacs/backup-files/" t)       ;; create the backups dir if necessary
(setq auto-save-file-name-transforms (quote ((".*" "~/Emacs/autosave-files//\\1" t))))
(setq backup-directory-alist (quote ((".*" . "~/Emacs/backup-files/"))))





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Keyboard customizations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Ctrl-plus and Ctrl-minus adjust font-size
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

;; Quick shortcut to this edit file, my configuration file,
;; which I am needless to say endlessly tweaking
(global-set-key "\C-xe" (lambda () (interactive) (find-file "~/.emacs")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; AFTER package initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun jeh/after-init-hook ()
  ;; stolen from:
  ;; stackoverflow.com/questions/11127109/emacs-24-package-system-initialization-problems/11140619#11140619
  ;; .emacs is evaluated, then packages are initialized,
  ;; and THEN the following are evaluated:
  ;; (e.g. solarized-theme from marmalade)
  (when window-system 
    (set-frame-size (selected-frame) 88 65)
    (set-frame-position (selected-frame) 0 0)
    ))

(add-hook 'after-init-hook 'jeh/after-init-hook)

(message "Evaluating custom-set-faces")



(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "CMU Typewriter Text" :foundry "unknown" :slant normal :weight normal :height 166 :width normal))))
 '(org-level-1 ((t (:foreground "#0000ff"))))
 '(org-level-2 ((t (:foreground "#6666ff")))))

(message "Finished custom-set-faces")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Open some files and directories
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(find-file "~/")
(find-file "~/Org-files/")
(find-file "~/Org-files/notes.org")


(message "Finished .emacs")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
