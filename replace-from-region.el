(defun query-replace-from-region (from to)
  "Perform `query-replace', but getting FROM string from region."
  (interactive
   (let ((from0 (buffer-substring (region-beginning) (region-end))))
     (list from0
           (query-replace-read-to from0 "Query replace" nil))))
  (deactivate-mark)
  (goto-char (region-beginning))
  (perform-replace from to t nil nil))

(defun query-replace-regexp-from-region (from to)
  "Perform `query-replace-regexp', but getting FROM string from region."
  (interactive
   (let ((from0 (query-replace-regexp-read-from "Query replace regexp")))
     (list from0
           (query-replace-read-to from0 "Query replace regexp" nil))))
  (deactivate-mark)
  (goto-char (region-beginning))
  (perform-replace from to t t nil))

;;; borrowed from replace.el
(defun query-replace-regexp-read-from (prompt)
  "Query and return the `from' argument of a query-replace\\(-replace\\)?-from-region operation."
  (let* ((history-add-new-input nil)
         (from
          ;; The save-excursion here is in case the user marks and copies
          ;; a region in order to specify the minibuffer input.
          ;; That should not clobber the region for the query-replace itself.
          (save-excursion
            (read-from-minibuffer
             (format "%s: " prompt)
             (buffer-substring (region-beginning) (region-end))
             nil nil query-replace-from-history-variable nil t))))
    (add-to-history query-replace-from-history-variable from nil t)
    ;; Warn if user types \n or \t, but don't reject the input.
    (and (string-match "\\(\\`\\|[^\\]\\)\\(\\\\\\\\\\)*\\(\\\\[nt]\\)" from)
         (let ((match (match-string 3 from)))
           (cond
            ((string= match "\\n")
             (message "Note: `\\n' here doesn't match a newline; to do that, type C-q C-j instead"))
            ((string= match "\\t")
             (message "Note: `\\t' here doesn't match a tab; to do that, just type TAB")))
           (sit-for 2)))
    from))

(provide 'replace-from-region)
