#!/usr/bin/env sh
":"; exec emacs --quick --script "$0" -- "$@" # -*- mode: emacs-lisp; lexical-binding: t; -*-

; Inspiration: https://github.com/tecosaur/this-month-in-org/blob/master/publish.el

(pop argv) ; $0
(setq force (string= "-f" (pop argv)))

(unless (bound-and-true-p doom-init-p)
  (setq gc-cons-threshold 16777216
        gcmh-high-cons-threshold 16777216)
  ;; (setq org-src-fontify-natively t)
  ;; (setq doom-disabled-packages '(doom-themes))
  (load (expand-file-name "core/core.el" user-emacs-directory) nil t)
  (require 'core-cli)
  (doom-initialize)
  (load-theme 'doom-opera t))

(require 'dash)
(require 'htmlize)
(require 'org-roam)
(require 'ox-publish)
(require 'ox-html)

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

(section! "Initializing")

(setq org-html-htmlize-output-type 'css)

(setq project-dir "/Users/ketanagrawal/garden-simple/org")
(setq org-roam-directory project-dir)
;; to be able to find id links during publish
(setq org-roam-db-location (concat project-dir "/org-roam.db"))
;; https://gitlab.com/ngm/commonplace/-/blob/master/publish.el
(defun ketan0/org-roam--backlinks-list (file)
  (if (org-roam--org-roam-file-p file)
      (--reduce-from
       (let (
             (note-title (org-roam-db--get-title (car it))))
         (message "Got backlink \"%s\"" note-title)
         (concat acc (if (or (string= note-title "sitemap") ;; exclude from backlinks
                             (string= note-title "Hello"))
                         ""
                       (format "- [[file:%s][%s]]\n"
                               (file-relative-name (car it) org-roam-directory)
                               note-title))))
       "" (org-roam-db-query [:select [source] :from links :where (= dest $s1)] file))
    (progn (message "it's not a file!") "")))

(defun ketan0/org-export-preprocessor (backend)
  (let ((links (ketan0/org-roam--backlinks-list (buffer-file-name))))
    (unless (string= links "")
      (save-excursion
        (goto-char (point-max))
        (insert (concat "
* Links to this note
:PROPERTIES:
:CUSTOM_ID: backlinks
:END:
") links)))))

(add-hook 'org-export-before-processing-hook 'ketan0/org-export-preprocessor)

(setq org-publish-project-alist
'(("digital laboratory"
        :base-directory "./org"
        :publishing-function org-html-publish-to-html
        :publishing-directory "./html"
        :auto-sitemap t
        :sitemap-title "sitemap"
        ;; :html-head-include-default-style nil
        :section-numbers nil
        :with-toc nil
        :preserve-breaks t
        :html-preamble t
        :html-preamble-format (("en" "<a style=\"color: inherit; text-decoration: none\" href=\"/\"><h2>Ketan's Digital Laboratory &#129514;</h2></a>"))
        :html-postamble t

        :html-postamble-format (("en" "<p class=\"date\">Last updated: %T</p>"))
        :html-link-home ""
        :html-link-up ""
        :html-head-extra "<link rel=\"stylesheet\" type=\"text/css\" href=\"syntax.css\" />"
        :html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"styles.css\" />")))

(section! "Publishing files")
(when force
  (warn! "Force flag set"))

(when force
  (delete-directory "./html" t))


(org-publish "digital laboratory" force)

(let ((css-src (expand-file-name "css/styles.css"))
      (css-dest (expand-file-name "html/styles.css")))
  (when (file-newer-than-file-p css-src css-dest)
    (copy-file css-src css-dest t)))

(let ((css-src (expand-file-name "css/syntax.css"))
      (css-dest (expand-file-name "html/syntax.css")))
  (when (file-newer-than-file-p css-src css-dest)
    (copy-file css-src css-dest t)))
