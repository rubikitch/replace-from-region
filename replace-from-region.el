;;; replace-from-region.el --- Replace commands whose query is from region

;; Filename: replace-from-region.el
;; Description: Replace commands whose query is from region
;; Author: rubikitch <rubikitch@ruby-lang.org>
;; Maintainer: rubikitch <rubikitch@ruby-lang.org>
;; Copyright (C) 2013, rubikitch, all rights reserved.
;; Time-stamp: <2017-02-28 08:12:56 rubikitch>
;; Created: 2013-01-28 14:49:07
;; Version: 0.2
;; URL: http://www.emacswiki.org/emacs/download/replace-from-region.el
;; Keywords: replace, search, region
;; Compatibility: GNU Emacs 24.2.2, 25.1
;;

;;; This file is NOT part of GNU Emacs

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; Replace commands whose query is from region
;; `query-replace' -> `query-replace-from-region'
;; `query-replace-regexp' -> `query-replace-regexp-from-region'

;;; Code:

;;;###autoload
(defun query-replace-from-region (from to &optional delimited start end backward)
  "Perform `query-replace', but getting FROM string from region."
  (interactive
   (let ((from0 (if (region-active-p)
                    (buffer-substring (region-beginning) (region-end))
                  (query-replace-read-from "Query replace" nil))))
     (append (if (consp from0)
                 (list
                  (car from0)
                  (cdr from0))
               (list
                from0
                (query-replace-read-to-with-default from0 "Query replace" nil)))
             (list
              (and current-prefix-arg (not (eq current-prefix-arg '-)))
              nil nil
              (and current-prefix-arg (eq current-prefix-arg '-))))))
  (when (region-active-p) (goto-char (region-beginning)))
  (deactivate-mark)
  (perform-replace from to t nil delimited nil nil start end backward))

;;;###autoload
(defun query-replace-regexp-from-region (from to &optional delimited start end backward)
  "Perform `query-replace-regexp', but getting FROM string from region."
  (interactive
   (let ((from0 (if (region-active-p)
                    (query-replace-regexp-read-from "Query replace regexp")
                  (query-replace-read-from "Query replace regexp" nil))))
     (append (if (consp from0)
                 (list
                  (car from0)
                  (cdr from0))
               (list
                from0
                (query-replace-read-to-with-default from0 "Query replace regexp" nil)))
             (list
              (and current-prefix-arg (not (eq current-prefix-arg '-)))
              nil nil
              (and current-prefix-arg (eq current-prefix-arg '-))))))
  (when (region-active-p) (goto-char (region-beginning)))
  (deactivate-mark)
  (perform-replace from to t t delimited nil nil start end backward nil))

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

(defun query-replace-read-to-with-default (from prompt regexp-flag)
  "Query and return the `to' argument of a query-replace operation WITH DEFAULT."
  (query-replace-compile-replacement
   (save-excursion
     (let* ((history-add-new-input nil)
	    (to (read-from-minibuffer
		 (format "%s %s with: " prompt (query-replace-descr from))
		 from nil nil           ;HERE
		 query-replace-to-history-variable from t)))
       (add-to-history query-replace-to-history-variable to nil t)
       (add-to-history 'query-replace-defaults (cons from to) nil t)
       to))
   regexp-flag))

(provide 'replace-from-region)
;;; replace-from-region.el ends here
