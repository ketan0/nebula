((nil . ((org-roam-directory . ".")
         (org-roam-db-location . "./org-roam.db")))
 ;; TODO: move these to a publishing script with org-publish
 (org-mode . ((org-html-link-home . "https://garden.ketan.me/")
              (org-html-preamble . "<h2>Ketan's Digital Laboratory</h2>")
              (org-export-with-toc . nil)
              (org-export-with-section-numbers . nil)
              (org-export-preserve-breaks . t)
              (org-html-head . ;;"<link href=\"tailwind.css\" type=\"text/css\" rel=\"stylesheet\">")
"<link rel=\"stylesheet\" type=\"text/css\" href=\"styles.css\" />")
              (eval . (ketan0/org-html-auto-export-mode)))))
<link rel="preconnect" href="https://fonts.gstatic.com">
<link href="https://fonts.googleapis.com/css2?family=Tenor+Sans&display=swap" rel="stylesheet">
