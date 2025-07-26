#!/usr/bin/env sh
":"; exec emacs --quick --script "$0" -- "$@" # -*- mode: emacs-lisp; lexical-binding: t; -*-

;; Inspiration:
;; https://github.com/tecosaur/this-month-in-org/blob/master/publish.el
;; https://gitlab.com/ngm/commonplace/-/blob/master/publish.el

(pop argv) ; $0
(setq force (string= "-f" (pop argv)))

(require 'find-lisp)
(require 'dash)
(require 's)
(require 'rustic)
(require 'elisp-mode)
(require 'htmlize)
(require 'org-roam)
(require 'ox-publish)
(require 'ox-html)
(require 'oc-csl)

(setq org-babel-default-header-args
  (cons '(:exports . "both") ;; export code and results by default
  (cons '(:eval . "no-export") ;; don't evaluate src blocks when exporting
  (assq-delete-all :exports
  (assq-delete-all :eval org-babel-default-header-args)))))

(advice-add 'undo-tree-mode :override #'ignore) ; Undo tree is a pain
;;; Silence uninformative noise

(advice-add 'org-toggle-pretty-entities :around #'doom-shut-up-a)
(advice-add 'indent-region :around #'doom-shut-up-a)
(advice-add 'rng-what-schema :around #'doom-shut-up-a)
(advice-add 'ispell-init-process :around #'doom-shut-up-a)

;;; No recentf please

(recentf-mode -1)
(advice-add 'recentf-mode :override #'ignore)
(advice-add 'recentf-cleanup :override #'ignore)

;; (section! "Initializing")

(setq org-html-htmlize-output-type 'css)
(setq org-roam-directory "~/garden-simple/org/")
(setq org-roam-db-location (concat org-roam-directory "org-roam.db"))

(load-file "~/garden-simple/publish-utils.el")

;; (section! "Publishing files")
(setq force nil)
(when force
  (warn! "Force flag set"))

(when force
  (mapcar 'delete-file (file-expand-wildcards "~/garden-simple/html/*.html")))

(let ((org-id-extra-files (find-lisp-find-files org-roam-directory "\.org$")))
  (org-publish "digital laboratory" force))


(let ((css-src (expand-file-name "~/garden-simple/css/styles.css"))
      (css-dest (expand-file-name "~/garden-simple/html/styles.css")))
  (when (file-newer-than-file-p css-src css-dest)
    (message "Copying styles.css...")
    (copy-file css-src css-dest t)))

(let ((css-src (expand-file-name "~/garden-simple/css/syntax.css"))
      (css-dest (expand-file-name "~/garden-simple/html/syntax.css")))
  (when (file-newer-than-file-p css-src css-dest)
    (message "Copying syntax.css...")
    (copy-file css-src css-dest t)))
