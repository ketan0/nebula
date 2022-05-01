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
;; Package-Requires: ((emacs "26.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:
(setq org-html-htmlize-output-type 'css)
(setq org-cite-global-bibliography '("/Users/ketanagrawal/zoterocitations.bib"))
(setq org-cite-csl-styles-dir "~/Zotero/styles")
(setq org-cite-export-processors '((t . (csl "ieee.csl"))))
;; use csl for every export backend

;; add the last modified date as a subtitle
(defun add-modified-date (backend)
  (when (equal backend 'html)
    (let ((modified-timestamp-subtitle (->> (buffer-file-name) (file-attributes)
                                            (file-attribute-modification-time)
                                            (format-time-string "%B %d, %Y")
                                            (concat "\n#+subtitle: Last modified on "))))
      (beginning-of-buffer)
      (setq case-fold-search t) ;; makes re-search-forward case-insensitive
      (when (re-search-forward "#\\+title:" nil t)
        (end-of-line)
        (insert modified-timestamp-subtitle)))))
(add-hook 'org-export-before-processing-hook 'add-modified-date)

;; modified from https://org-roam.discourse.group/t/export-backlinks-on-org-export/1756
;; collect backlinks and append them as a subtree at the end of the document
(defun collect-backlinks-string (backend)
  (when (and (equal backend 'html)
             (org-roam-node-at-point))
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
           ;; sort in order of decreasing end position (secondary sort: decreasing start position)
           (nodes-in-file-sorted (->> (-zip nodes-start-position nodes-end-position nodes-in-file)
                                      (--sort (or (> (nth 1 it) (nth 1 other))
                                                  (and (= (nth 1 it) (nth 1 other))
                                                       (> (nth 0 it)) (nth 0 other))))
                                      (--map (cdr it)))))
      (unless (-some->> (org-roam-node-properties source-node)
                (assoc "HTML_CONTAINER_CLASS" ) (cdr)
                (s-contains? "no-backlinks-here"))
        (dolist (end-and-node nodes-in-file-sorted)
          (-when-let* (((end-position node) end-and-node)
                       (backlinks (--filter (->> (org-roam-backlink-source-node it)
                                                 (org-roam-node-file)
                                                 (s-contains? "private/") (not))
                                            (org-roam-backlinks-get node)))
                       (heading (format "\n\n%s Links to \"%s\"\n"
                                        (s-repeat (+ (org-roam-node-level node) 1) "*")
                                        (org-roam-node-title node)))
                       (properties-drawer ":PROPERTIES:\n:HTML_CONTAINER_CLASS: references\n:END:\n"))
            (goto-char end-position)
            (insert heading)
            (insert properties-drawer)
            (dolist (backlink backlinks)
              (let* ((source-node (org-roam-backlink-source-node backlink))
                     (source-file (org-roam-node-file source-node))
                     (properties (org-roam-backlink-properties backlink))
                     (outline (when-let ((outline (plist-get properties :outline)))
                                (when (>= (length outline) 1)
                                  (->> (mapconcat #'org-link-display-format outline " > ")
                                       (format " @@html:<span class=\"backlinks-outline-path\">@@(/%s/)@@html:</span>@@")))))
                     (point (org-roam-backlink-point backlink))
                     (text (if (-some->> (org-roam-node-properties source-node)
                                 (assoc "HTML_CONTAINER_CLASS") (cdr)
                                 (s-contains? "dont-show-content-in-backlinks"))
                               ""
                             ;; (s-replace "\n" " " (org-roam-preview-get-contents source-file point))
                             (org-roam-preview-get-contents source-file point)
                               ))
                     (reference (format "%s [[id:%s][%s]]%s\n%s\n\n"
                                        (s-repeat (+ (org-roam-node-level node) 2) "*")
                                        (org-roam-node-id source-node)
                                        (org-roam-node-title source-node)
                                        (or outline "")
                                        text)))
                (insert reference)))))))))

(add-hook 'org-export-before-processing-hook 'collect-backlinks-string)



;; patch from https://gist.github.com/jethrokuan/d6f80caaec7f49dedffac7c4fe41d132
;; makes ID links to headlines work properly
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

;; Modify org src block export to add the programming language as an attribute of <pre>
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
          (format "<div class=\"org-src-container\" data-language=\"%s\">\n%s%s\n</div>"
                  ;; CHANGED PORTION - so the code block can display the language - ketan0
                  ;; programming language, to be used by :before pseudo-element
                  lang
                  ;; END CHANGED
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
                    (format "<pre class=\"src src-%s\"%s>%s</pre>"
                            lang label code)))))))

;; Modify org quote block export to allow me to use Quotebacks: https://quotebacks.net/
(defun org-html-quote-block (quote-block contents info)
  "Transcode a QUOTE-BLOCK element from Org to HTML.
CONTENTS holds the contents of the block.  INFO is a plist
holding contextual information."

  (let* ((reference (org-html--reference quote-block info t))
         (attributes (org-export-read-attribute :attr_html quote-block))
         (data-author (plist-get attributes :data-author))
         (cite (plist-get attributes :cite))
         (quotebackp (string= (plist-get attributes :class) "quoteback"))
         (a (org-html--make-attribute-string
             (if (or (not reference) (plist-member attributes :id))
                 attributes
               (plist-put attributes :id reference)))))
    (format "<blockquote%s>\n%s%s</blockquote>%s"
            (if (org-string-nw-p a) (concat " " a) "")
            contents
            (if quotebackp (format "<footer>%s<cite><a href=\"%s\">%s</a></cite></footer>"
                                   (or data-author "") (or cite "") (or cite ""))
              "")
            (if quotebackp "<script note=\"\" src=\"https://cdn.jsdelivr.net/gh/Blogger-Peer-Review/quotebacks@1/quoteback.js\"></script>"
              ""))))

(defun file-contents (file)
  (with-temp-buffer
    (insert-file-contents file)
    (buffer-string)))
(setq html-preamble (file-contents "~/garden-simple/assets/header.html")
      html-postamble (file-contents "~/garden-simple/assets/footer.html")
      html-head-extra (file-contents "~/garden-simple/assets/head-extra.html"))
(setq org-publish-project-alist
        `(("digital laboratory"
           :base-directory "~/garden-simple/org"
           :publishing-function org-html-publish-to-html
           :publishing-directory "~/garden-simple/html"
           :auto-sitemap t
           :sitemap-title "sitemap"
           :section-numbers nil
           :with-toc nil
           :preserve-breaks t
           :html-preamble t
           :html-preamble-format (("en" ,html-preamble))
           :html-postamble t
           :html-postamble-format (("en" ,html-postamble))
           :html-link-home ""
           :html-link-up ""
           :html-head-include-default-style nil
           :html-head-extra ,html-head-extra)))

;;; publish-utils.el ends here
