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

(section! "Initialising")

(require 'dash)
(require 'htmlize)
(require 'org-roam)
(require 'ox-publish)
(require 'ox-html)

(setq project-dir "/Users/ketanagrawal/garden-simple/org")
(setq org-roam-directory project-dir)
;; to be able to find id links during publish
(setq org-roam-db-location (concat project-dir "/org-roam.db"))

(defun commonplace/org-roam--backlinks-list (file)
  ;; (message "(org-roam--org-roam-file-p %s): %s" file (org-roam--org-roam-file-p file))
  ;; (message "(org-roam--org-roam-file-p):" (org-roam--org-roam-file-p))
  (if (org-roam--org-roam-file-p file)
      ;; (org-roam-buffer--insert-backlinks)
      (--reduce-from
       (concat acc (format "- [[file:%s][%s]]\n"
                           (file-relative-name (car it) org-roam-directory)
                           (org-roam-db--get-title (car it))))
       "" (org-roam-db-query [:select [source] :from links :where (= dest $s1)] file))
    (progn (message "it's not a file!")
           "")))

(defun commonplace/org-export-preprocessor (backend)
  ;; (message "buffer-file-name is \"%s\"" buffer-file-name)
  (let ((links (commonplace/org-roam--backlinks-list (buffer-file-name))))
    ;; (message "links is \"%s\"" links)
    (unless (string= links "")
      (save-excursion
        (goto-char (point-max))
        (insert (concat "
* Links to this note
:PROPERTIES:
:CUSTOM_ID: backlinks
:END:
") links)))))



(add-hook 'org-export-before-processing-hook 'commonplace/org-export-preprocessor)

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

        :html-postamble-format (("en" "<footer><p>Author: %a</p><p>Last updated: %T<p><footer>"))
        :html-link-home ""
        :html-link-up ""
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
