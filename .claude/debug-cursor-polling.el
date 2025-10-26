;;; debug-cursor-polling.el --- Debug cursor polling implementation

;; Run these commands in your Claude Code buffer to debug the cursor issue

;; 1. Check if vterm--term is bound and its value
(defun claude-cursor-debug-vterm-term ()
  "Check vterm--term status."
  (interactive)
  (message "=== vterm--term Debug ===")
  (message "boundp vterm--term: %s" (boundp 'vterm--term))
  (when (boundp 'vterm--term)
    (message "vterm--term value: %s" vterm--term)
    (message "vterm--term type: %s" (type-of vterm--term)))
  (message "cursor-type: %s" cursor-type)
  (message "cursor-in-non-selected-windows: %s" cursor-in-non-selected-windows))

;; 2. Check if the function was ever called
(defun claude-cursor-debug-check-calls ()
  "Check if cursor config function was called."
  (interactive)
  (message "=== Checking Debug Log ===")
  (let ((debug-buffer (get-buffer "*claude-code-debug*")))
    (if debug-buffer
        (with-current-buffer debug-buffer
          (goto-char (point-min))
          (let ((ready-count 0)
                (retry-count 0))
            (while (re-search-forward "Cursor configured after vterm ready" nil t)
              (setq ready-count (1+ ready-count)))
            (goto-char (point-min))
            (while (re-search-forward "vterm not ready, retrying" nil t)
              (setq retry-count (1+ retry-count)))
            (message "Found 'ready' messages: %d" ready-count)
            (message "Found 'retry' messages: %d" retry-count)
            (when (= ready-count 0)
              (message "⚠️  Cursor config never succeeded!"))))
      (message "⚠️  No debug buffer found - enable debug mode first"))))

;; 3. Check the delay constant value
(defun claude-cursor-debug-check-delay ()
  "Check if the delay constant is available."
  (interactive)
  (message "=== Delay Constant Debug ===")
  (if (boundp 'claude-code-ide-mcp-selection-delay)
      (message "claude-code-ide-mcp-selection-delay: %s" claude-code-ide-mcp-selection-delay)
    (message "⚠️  claude-code-ide-mcp-selection-delay is NOT bound!")))

;; 4. Manually try to set cursor
(defun claude-cursor-debug-manual-set ()
  "Manually set cursor and see if it persists."
  (interactive)
  (message "=== Manual Cursor Set ===")
  (message "Before: cursor-type = %s" cursor-type)
  (setq-local cursor-type 'box)
  (setq-local cursor-in-non-selected-windows 'hollow)
  (message "After: cursor-type = %s" cursor-type)
  (message "Wait 2 seconds...")
  (run-at-time 2 nil
               (lambda ()
                 (message "After 2 seconds: cursor-type = %s" cursor-type))))

;; 5. Check if function is in the hook
(defun claude-cursor-debug-check-hook ()
  "Check if cursor config is in vterm-mode-hook."
  (interactive)
  (message "=== vterm-mode-hook Debug ===")
  (if (boundp 'vterm-mode-hook)
      (progn
        (message "vterm-mode-hook value:")
        (dolist (func vterm-mode-hook)
          (message "  - %s" func))
        (if (memq 'claude-code-ide--configure-vterm-cursor vterm-mode-hook)
            (message "✓ claude-code-ide--configure-vterm-cursor IS in hook")
          (message "✗ claude-code-ide--configure-vterm-cursor NOT in hook")))
    (message "⚠️  vterm-mode-hook not bound")))

;; 6. Run all diagnostics
(defun claude-cursor-debug-all ()
  "Run all cursor diagnostics."
  (interactive)
  (claude-cursor-debug-vterm-term)
  (message "")
  (claude-cursor-debug-check-delay)
  (message "")
  (claude-cursor-debug-check-hook)
  (message "")
  (claude-cursor-debug-check-calls)
  (message "")
  (message "=== End of Diagnostics ===")
  (message "Check the *Messages* buffer for full output"))

;;; debug-cursor-polling.el ends here
