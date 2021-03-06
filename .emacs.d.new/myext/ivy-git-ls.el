;; -*- lexical-binding: t -*-

;; Copyright (C) 2017 ayato-p

;; Author: ayato-p <lumia@nandeger.com>
;; Version: 0.0.1
;; Package-Requires: ((ivy "0.9.0") (dash "2.13.0"))
;; Keywords: find-file

;;; Code:
(require 'ivy)
(require 'dash)
(require 'vc)
(require 'vc-git)

(defgroup ivy-git-ls nil
  "An interface of git-ls for ivy"
  :group 'ivy
  :prefix 'convenience)

(defgroup ivy-git-ls/faces nil
  "Font-lock faces for `ivy-git-ls'"
  :group 'ivy-git-ls
  :group 'faces)

(defface ivy-git-ls/modified-face
  '((t :foreground "green"))
  "Modified face"
  :group 'ivy-git-ls)

(defface ivy-git-ls/untracked-face
  '((t :foreground "red"))
  "Untracked face"
  :group 'ivy-git-ls)

(defface ivy-git-ls/added-face
  '((t :foreground "yellow"))
  "Added face"
  :group 'ivy-git-ls)

(defface ivy-git-ls/deleted-face
  '((t :foreground "gray"))
  "Untracked face"
  :group 'ivy-git-ls)

(defcustom ivy-git-ls/git-ls-files-cmd "git ls-files --full-name -- | sort"
  "git ls-files command"
  :type 'string
  :group 'ivy-git-ls)

(defun ivy-git-ls/git-status-transformer* (line)
  (cond ((string-match "^\\( M \\)\\(.*\\)" line)
         (-> (match-string 2 line)
             (propertize 'display (propertize line 'face 'ivy-git-ls/modified-face))))
        ((string-match "^\\(M+ *\\)\\(.*\\)" line)
         (-> (match-string 2 line)
             (propertize 'display (propertize line 'face 'ivy-git-ls/modified-face))))
        ((string-match "^\\([?]\\{2\\} \\)\\(.*\\)" line)
         (-> (match-string 2 line)
             (propertize 'display (propertize line 'face 'ivy-git-ls/untracked-face))))
        ((string-match "^\\([AC] +\\)\\(.*\\)" line)
         (-> (match-string 2 line)
             (propertize 'display (propertize line 'face 'ivy-git-ls/added-face))))
        ((string-match "^\\( [D] \\)\\(.*\\)" line)
         (-> (match-string 2 line)
             (propertize 'display (propertize line 'face 'ivy-git-ls/deleted-face))))
        ((string-match "^\\(RM?\\).* -> \\(.*\\)" line)
         (-> (match-string 2 line)
             (propertize 'display (propertize line 'face 'ivy-git-ls/modified-face))))
        ((string-match "^\\([D] \\)\\(.*\\)" line)
         (-> (match-string 2 line)
             (propertize 'display (propertize line 'face 'ivy-git-ls/deleted-face))))
        ((string-match "^\\(UU \\)\\(.*\\)" line)
         (-> (match-string 2 line)
             (propertize 'display (propertize line 'face 'ivy-git-ls/untracked-face))))
        ((string-match "^\\(AM \\)\\(.*\\)" line)
         (-> (match-string 2 line)
             (propertize 'display (propertize line 'face 'ivy-git-ls/added-face))))
        (t line)))

(defun ivy-git-ls/git-status-transformer (source)
  (-map 'ivy-git-ls/git-status-transformer* source))

(defun ivy-git-ls/git-status (git-root-dir)
  (let ((default-directory git-root-dir))
    (-> (shell-command-to-string "git status --porcelain")
        (split-string "\n" t)
        (ivy-git-ls/git-status-transformer))))

(defun ivy-git-ls/git-ls-files (git-root-dir)
  (let ((default-directory git-root-dir))
    (-> (shell-command-to-string ivy-git-ls/git-ls-files-cmd)
        (split-string "\n" t))))

;;;###autoload
(defun ivy-git-ls ()
  (interactive)
  (let* ((git-root-dir (or (and buffer-file-name (vc-git-root buffer-file-name))
                           (vc-git-root default-directory)))
         (candidates (append (ivy-git-ls/git-status git-root-dir)
                             (ivy-git-ls/git-ls-files git-root-dir))))
    (if (stringp git-root-dir)
        (ivy-read "Find file: " candidates
                  :action (lambda (matched)
                            (->> (expand-file-name matched git-root-dir)
                                 (find-file)))
                  :caller 'ivy-git-ls)
      (message "Not a git repository..."))))

(provide 'ivy-git-ls)
