;;; wisent-rnc.el --- New RNC mode

;; Copyright (C) 2012 Tony Graham
;; Originally slavishly copied from wisent-dot.el
;; Copyright (C) 2003, 2004 Eric M. Ludlam

;; Author: Tony Graham <tkg@menteith.com>
;; Keywords: syntax
;; X-RCS: $Id: wisent-rnc.el,v 1.9 2005/09/30 20:07:07 zappo Exp $

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; Parser for RELAX NG compact syntax.
;;   


;;; Code:
(require 'semantic-wisent)
(require 'semantic)
(require 'wisent-rnc-wy)
(require 'rnc-mode)

(defun flymake-rnc-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
		     'flymake-create-temp-inplace))
     	 (local-file (file-relative-name
		      temp-file
		      (file-name-directory buffer-file-name))))
    (list "jing" (list "-c" local-file))))

(add-to-list 'flymake-allowed-file-name-masks
      '(".+\\.rnc$"
	flymake-rnc-init
	flymake-simple-cleanup
	flymake-get-real-file-name))

(define-mode-overload-implementation semantic-tag-components
  nrnc-mode (tag)
  "Return the children of tag TAG."
  (cond
   ((memq (semantic-tag-class tag)
         '(element attribute))
    (semantic-tag-get-attribute tag :attributes)
    )
   ((memq (semantic-tag-class tag)
         '(start pattern pattern-block))
    (semantic-tag-get-attribute tag :members)
    )))

;;;###autoload
(defun wisent-rnc-setup-parser ()
  "Setup buffer for parse."
  (wisent-rnc-wy--install-parser)

  (setq 
   ;; Lexical Analysis
   semantic-lex-analyzer 'wisent-rnc-lexer
   ;; Parsing
   ;; Environment
   semantic-imenu-summary-function 'semantic-format-tag-name
   imenu-create-index-function 'semantic-create-imenu-index
   ;; Speedbar
   semantic-symbol->name-assoc-list
   '((start . "start")
     (define . "define")
     (element . "element")
     )
   ;; Navigation
   senator-step-at-tag-classes '(start element attribute)
   ))

(defun nrnc-debug-setup ()
  "Turn on debugging stuff."
  (interactive)
  (semantic-show-unmatched-syntax-mode t))

;;;###autoload
(defun nrnc-mode ()
  "Major mode for editing RELAX NG compact syntax."
  (interactive)

  (kill-all-local-variables)
  (use-local-map rnc-mode-map)

  (make-local-variable 'comment-start)
  (make-local-variable 'comment-end)
  (make-local-variable 'comment-start-skip)

  (setq comment-start "#"
	comment-end ""
	comment-start-skip "\\([ \n\t]+\\)##?[ \n\t]+")

  (let ((rnc-syntax-table (copy-syntax-table)))
    (modify-syntax-entry ?# "<   " rnc-syntax-table)
    (modify-syntax-entry ?\n ">   " rnc-syntax-table)
    (modify-syntax-entry ?\^m ">   " rnc-syntax-table)
    (modify-syntax-entry ?\\ "w   " rnc-syntax-table)
    (modify-syntax-entry ?' "\"   " rnc-syntax-table)
    (modify-syntax-entry ?. "w   " rnc-syntax-table)
    (modify-syntax-entry ?- "w   " rnc-syntax-table)
    (modify-syntax-entry ?_ "w   " rnc-syntax-table)
    (set-syntax-table rnc-syntax-table))
  
  (modify-syntax-entry ?= ".")
  (wisent-rnc-setup-parser)
  ;(semantic-show-unmatched-syntax-mode 1)
  (setq mode-name "nRNC"
	major-mode 'nrnc-mode)
  (run-hooks 'nrnc-mode-hook))


(provide 'nrnc-mode)

;;; nrnc-mode.el ends here
