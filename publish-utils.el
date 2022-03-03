;;; publish-utils.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 Ketan Agrawal
;;
;; Author: Ketan Agrawal <https://github.com/ketanagrawal>
;; Maintainer: Ketan Agrawal <ketanjayagrawal@gmail.com>
;; Created: March 02, 2022
;; Modified: March 02, 2022
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/ketanagrawal/publish-utils
;; Package-Requires: ((emacs "25.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:
(setq org-html-htmlize-output-type 'css)
(defun collect-backlinks-string (backend)
  (when (org-roam-node-at-point)
    (let* ((source-node (org-roam-node-at-point))
           (source-file (org-roam-node-file source-node))
           (nodes-in-file (--filter (s-equals? (org-roam-node-file it) source-file)
                                    (org-roam-node-list)))
           (nodes-start-position (-map 'org-roam-node-point nodes-in-file))
           ;; Nodes don't store the last position, so get the next headline position
           ;; and subtract one character (or, if no next headline, get point-max)
           (nodes-end-position (-map (lambda (nodes-start-position)
                                       (goto-char nodes-start-position)
                                       (if (org-before-first-heading-p) ;; file node
                                           (point-max)
                                         (call-interactively
                                          'org-forward-heading-same-level)
                                         (if (> (point) nodes-start-position)
                                             (- (point) 1) ;; successfully found next
                                           (point-max)))) ;; there was no next
                                     nodes-start-position))
           ;; sort in order of decreasing end position
           (nodes-in-file-sorted (->> (-zip nodes-in-file nodes-end-position)
                                      (--sort (> (cdr it) (cdr other))))))
      (unless (-some->> (org-roam-node-properties source-node)
                (assoc "HTML_CONTAINER_CLASS" ) (cdr)
                (s-contains? "no-backlinks-here"))
        (dolist (node-and-end nodes-in-file-sorted)
          (-when-let* (((node . end-position) node-and-end)
                       (backlinks (--filter (->> (org-roam-backlink-source-node it)
                                                 (org-roam-node-file)
                                                 (s-contains? "private/") (not))
                                            (org-roam-backlinks-get node)))
                       (heading (format "\n\n%s Links to this node\n"
                                        (s-repeat (+ (org-roam-node-level node) 1) "*")))
                       (properties-drawer ":PROPERTIES:\n:HTML_CONTAINER_CLASS: references\n:END:\n"))
            (goto-char end-position)
            (insert heading)
            (insert properties-drawer)
            (dolist (backlink backlinks)
              (let* ((source-node (org-roam-backlink-source-node backlink))
                     (source-file (org-roam-node-file source-node))
                     (properties (org-roam-backlink-properties backlink))
                     (outline (when-let ((outline (plist-get properties :outline)))
                                (when (> (length outline) 1)
                                  (mapconcat #'org-link-display-format outline " > "))))
                     (point (org-roam-backlink-point backlink))
                     (text (if (-some->> (org-roam-node-properties source-node)
                                 (assoc "HTML_CONTAINER_CLASS") (cdr)
                                 (s-contains? "dont-show-content-in-backlinks"))
                               ""
                             ;; (s-replace "\n" " " (org-roam-preview-get-contents source-file point))
                             (org-roam-preview-get-contents source-file point)
                               ))
                     (reference (format "%s [[id:%s][%s]]\n%s\n%s\n\n"
                                        (s-repeat (+ (org-roam-node-level node) 2) "*")
                                        (org-roam-node-id source-node)
                                        (org-roam-node-title source-node)
                                        (if outline
                                            (format "%s (/%s/)" (s-repeat (+ (org-roam-node-level node) 3) "*") outline) "")
                                        text)))
                (insert reference)))))))))

(add-hook 'org-export-before-processing-hook 'collect-backlinks-string)

(setq org-publish-project-alist
        '(("digital laboratory"
           :base-directory "~/garden-simple/org"
           :publishing-function org-html-publish-to-html
           :publishing-directory "~/garden-simple/html"
           :auto-sitemap t
           :sitemap-title "sitemap"
           ;; :html-head-include-default-style nil
           :section-numbers nil
           :with-toc nil
           :preserve-breaks t
           :html-preamble t
           :html-preamble-format (("en" "<a style=\"color: inherit; text-decoration: none\" href=\"/\"><h2>Ketan's Nebula</h2></a>"))
           :html-postamble t
           :html-postamble-format (("en" "<p>Made with <span class=\"heart\">♥</span> using
<a href=\"https://orgmode.org/\">org-mode</a>.
Source code is available
<a href=\"https://github.com/ketan0/digital-laboratory\">here</a>.</p>
<script src=\"popper.min.js\"></script>
<script src=\"tippy-bundle.umd.min.js\"></script>
<script src=\"tooltips.js\"></script>"))
           :html-link-home ""
           :html-link-up ""
           :html-head-include-default-style nil
           :html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"syntax.css\" />
<link rel=\"stylesheet\" type=\"text/css\" href=\"styles.css\" />"
           :html-head-extra "<link rel=\"apple-touch-icon\" sizes=\"180x180\" href=\"/apple-touch-icon.png\" />
<link rel=\"icon\" type=\"image/png\" sizes=\"32x32\" href=\"/favicon-32x32.png\" />
<link rel=\"icon\" type=\"image/png\" sizes=\"16x16\" href=\"/favicon-16x16.png\" />
<link rel=\"manifest\" href=\"/site.webmanifest\" />")))

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

(defun org-html-src-block (src-block _contents info)
    "Transcode a SRC-BLOCK element from Org to HTML.
CONTENTS holds the contents of the item.  INFO is a plist holding
contextual information."
    (if (org-export-read-attribute :attr_html src-block :textarea)
        (org-html--textarea-block src-block)
      (let* ((lang (org-element-property :language src-block))
             (code (org-html-format-code src-block info))
             (label (let ((lbl (org-html--reference src-block info t)))
                      (if lbl (format " id=\"%s\"" lbl) "")))
             (klipsify  (and  (plist-get info :html-klipsify-src)
                              (member lang '("javascript" "js"
                                             "ruby" "scheme" "clojure" "php" "html")))))
        (if (not lang) (format "<pre class=\"example\"%s>\n%s</pre>" label code)
          (format "<div class=\"org-src-container\">\n%s%s\n</div>"
                  ;; Build caption.
                  (let ((caption (org-export-get-caption src-block)))
                    (if (not caption) ""
                      (let ((listing-number
                             (format
                              "<span class=\"listing-number\">%s </span>"
                              (format
                               (org-html--translate "Listing %d:" info)
                               (org-export-get-ordinal
                                src-block info nil #'org-html--has-caption-p)))))
                        (format "<label class=\"org-src-name\">%s%s</label>"
                                listing-number
                                (org-trim (org-export-data caption info))))))
                  ;; Contents.
                  (if klipsify
                      (format "<pre><code class=\"src src-%s\"%s%s>%s</code></pre>"
                              lang
                              label
                              (if (string= lang "html")
                                  " data-editor-type=\"html\""
                                "")
                              code)
                    ;; CHANGED LINE - so the code block can display the language - ketan0
                    (format "<pre class=\"src src-%s\" data-language=\"%s\"%s>%s</pre>"
                    ;; END CHANGED LINE
                            lang lang label code)))))))

;;; publish-utils.el ends here
