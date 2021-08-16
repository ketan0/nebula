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

(require 'find-lisp)
(require 'dash)
(require 's)
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
(setq org-roam-directory "/Users/ketanagrawal/garden-simple/org")
(defun collect-backlinks-string (backend)
  (when (org-roam-node-at-point)
    (let* ((source-node (org-roam-node-at-point))
           (source-file (org-roam-node-file source-node))
           ;; Sort the nodes by the point to avoid errors when inserting the
           ;; references
           (nodes-in-file (--sort (< (org-roam-node-point it)
                                     (org-roam-node-point other))
                                  (-filter (lambda (node)
                                             (s-equals?
                                              (org-roam-node-file node)
                                              source-file))
                                           (org-roam-node-list))))
           ;; Nodes don't store the last position so, get the next node position
           ;; and subtract one character
           (nodes-start-position (-map (lambda (node) (org-roam-node-point node))
                                       nodes-in-file))
           (nodes-end-position (-concat (-map (lambda (next-node-position)
                                                (- next-node-position 1))
                                              (-drop 1 nodes-start-position))
                                        (list (point-max))))
           ;; Keep track of the current-node index
           (current-node 0)
           ;; Keep track of the amount of text added
           (character-count 0))
      (dolist (node nodes-in-file)
        (when (org-roam-backlinks-get node)
          ;; Go to the end of the node and don't forget about previously inserted
          ;; text
          (goto-char (+ (nth current-node nodes-end-position) character-count))
          ;; Add the references as a subtree of the node
          (setq heading (format "\n\n%s References\n"
                                (s-repeat (+ (org-roam-node-level node) 1) "*")))
          ;; Count the characters and count the new lines (4)
          (setq character-count (+ 3 character-count (string-width heading)))
          (insert heading)
          ;; Insert properties drawer
          (setq properties-drawer ":PROPERTIES:\n:HTML_CONTAINER_CLASS: references\n:END:\n")
          ;; Count the characters and count the new lines (3)
          (setq character-count (+ 3 character-count (string-width properties-drawer)))
          (insert properties-drawer)
          (dolist (backlink (org-roam-backlinks-get node))
            (let* ((source-node (org-roam-backlink-source-node backlink))
                   (point (org-roam-backlink-point backlink))
                   (text (s-replace "\n" " " (org-roam-preview-get-contents
                                           (org-roam-node-file source-node)
                                           point)))
                   (references (format "- [[./%s][%s]]: %s\n\n"
                                       (file-relative-name (org-roam-node-file source-node))
                                       (org-roam-node-title source-node)
                                       text)))
              ;; Also count the new lines (2)
              (setq character-count (+ 2 character-count (string-width references)))
              (insert references))))
        (setq current-node (+ current-node 1))))))

;; (defun ketan0/org-export-preprocessor (backend)
;;   (let ((links (ketan0/org-roam--backlinks-list (buffer-file-name))))
;;     (unless (string= links "")
;;       (save-excursion
;;         (goto-char (point-max))
;;         (insert (concat "
;; * Links to this note
;; :PROPERTIES:
;; :CUSTOM_ID: backlinks
;; :END:
;; ") links)))))

(add-hook 'org-export-before-processing-hook 'collect-backlinks-string)

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
           :html-preamble-format (("en" "<a style=\"color: inherit; text-decoration: none\" href=\"/\">
<h2>Ketan's Digital Laboratory &#129514;</h2>
</a>"))
           :html-postamble t
           :html-postamble-format (("en" "<p>Made with <span class=\"heart\">♥</span> using
<a href=\"https://orgmode.org/\">org-mode</a>.
Source code is available
<a href=\"https://github.com/ketan0/digital-laboratory\">here</a>.</p>
<script src=\"https://unpkg.com/axios/dist/axios.min.js\"></script>
<script src=\"https://unpkg.com/@popperjs/core@2\"></script>
<script src=\"https://unpkg.com/tippy.js@6\"></script>
<script src=\"tooltips.js\"></script>"))
           :html-link-home ""
           :html-link-up ""
           :html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"syntax.css\" />
<link rel=\"stylesheet\" type=\"text/css\" href=\"styles.css\" />"
           :html-head-extra "<link rel=\"apple-touch-icon\" sizes=\"180x180\" href=\"/apple-touch-icon.png\" />
<link rel=\"icon\" type=\"image/png\" sizes=\"32x32\" href=\"/favicon-32x32.png\" />
<link rel=\"icon\" type=\"image/png\" sizes=\"16x16\" href=\"/favicon-16x16.png\" />
<link rel=\"manifest\" href=\"/site.webmanifest\" />")))

(section! "Publishing files")
(when force
  (warn! "Force flag set"))

(when force
  (mapcar 'delete-file (file-expand-wildcards "./html/*.html")))

;; patch from https://gist.github.com/jethrokuan/d6f80caaec7f49dedffac7c4fe41d132
;; makes links to headlines work properly
(defun org-html--reference (datum info &optional named-only)
    "Return an appropriate reference for DATUM.
DATUM is an element or a `target' type object.  INFO is the
current export state, as a plist.
When NAMED-ONLY is non-nil and DATUM has no NAME keyword, return
nil.  This doesn't apply to headlines, inline tasks, radio
targets and targets."
    (let* ((type (org-element-type datum))
           (user-label
            (org-element-property
             (pcase type
               ((or `headline `inlinetask) :CUSTOM_ID)
               ((or `radio-target `target) :value)
               (_ :name))
             datum))
           (user-label (or user-label
                           (when-let ((path (org-element-property :ID datum)))
                             (concat "ID-" path)))))
      (cond
       ((and user-label
             (or (plist-get info :html-prefer-user-labels)
                 ;; Used CUSTOM_ID property unconditionally.
                 (memq type '(headline inlinetask))))
        user-label)
       ((and named-only
             (not (memq type '(headline inlinetask radio-target target)))
             (not user-label))
        nil)
       (t
        (org-export-get-reference datum info)))))

(let ((org-id-extra-files (find-lisp-find-files org-roam-directory "\.org$")))
  (org-publish "digital laboratory" force))


(let ((css-src (expand-file-name "css/styles.css"))
      (css-dest (expand-file-name "html/styles.css")))
  (when (file-newer-than-file-p css-src css-dest)
    (message "Copying styles.css...")
    (copy-file css-src css-dest t)))

(let ((css-src (expand-file-name "css/syntax.css"))
      (css-dest (expand-file-name "html/syntax.css")))
  (when (file-newer-than-file-p css-src css-dest)
    (message "Copying syntax.css...")
    (copy-file css-src css-dest t)))
