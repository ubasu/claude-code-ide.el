;;; trace-cursor-config.el --- Trace cursor configuration execution

;; This adds detailed tracing to the cursor configuration function

(defun claude-code-ide--configure-vterm-cursor-traced ()
  "Traced version of configure-vterm-cursor for debugging."
  (message "[TRACE] claude-code-ide--configure-vterm-cursor called")
  (message "[TRACE]   Current buffer: %s" (current-buffer))
  (message "[TRACE]   Buffer name: %s" (buffer-name))
  (message "[TRACE]   Is session buffer: %s" (claude-code-ide--session-buffer-p (current-buffer)))

  (when (claude-code-ide--session-buffer-p (current-buffer))
    (message "[TRACE]   Inside session buffer check")
    (message "[TRACE]   Checking vterm--term...")
    (message "[TRACE]     boundp vterm--term: %s" (boundp 'vterm--term))

    (if (boundp 'vterm--term)
        (progn
          (message "[TRACE]     vterm--term value: %s" vterm--term)
          (message "[TRACE]     Type: %s" (type-of vterm--term)))
      (message "[TRACE]     vterm--term NOT BOUND"))

    (if (and (boundp 'vterm--term) vterm--term)
        ;; vterm is ready, apply cursor settings
        (progn
          (message "[TRACE]   ✓ vterm is READY - applying cursor settings")
          (message "[TRACE]     Before: cursor-type=%s" cursor-type)
          (setq-local cursor-type 'box)
          (setq-local cursor-in-non-selected-windows 'hollow)
          (message "[TRACE]     After: cursor-type=%s" cursor-type)
          (claude-code-ide-debug "Cursor configured after vterm ready"))
      ;; vterm not ready yet, retry
      (message "[TRACE]   ✗ vterm NOT READY - scheduling retry")
      (message "[TRACE]     Checking delay constant...")
      (if (boundp 'claude-code-ide-mcp-selection-delay)
          (message "[TRACE]       Delay constant: %s" claude-code-ide-mcp-selection-delay)
        (message "[TRACE]       ⚠️  Delay constant NOT BOUND!"))

      (claude-code-ide-debug "vterm not ready, retrying cursor config in %sms"
                             (* claude-code-ide-mcp-selection-delay 1000))
      (message "[TRACE]     Scheduling run-at-time with delay %s" claude-code-ide-mcp-selection-delay)
      (run-at-time claude-code-ide-mcp-selection-delay nil
                   (lambda (buf)
                     (message "[TRACE] *** RETRY callback called ***")
                     (message "[TRACE]   Buffer: %s" buf)
                     (message "[TRACE]   Buffer live: %s" (buffer-live-p buf))
                     (when (buffer-live-p buf)
                       (with-current-buffer buf
                         (message "[TRACE]   Calling configure-vterm-cursor again...")
                         (claude-code-ide--configure-vterm-cursor-traced))))
                   (current-buffer))
      (message "[TRACE]   run-at-time scheduled"))))

;; Advice the original function to add tracing
(defun claude-cursor-enable-tracing ()
  "Enable detailed tracing of cursor configuration."
  (interactive)
  (advice-add 'claude-code-ide--configure-vterm-cursor
              :override #'claude-code-ide--configure-vterm-cursor-traced)
  (message "Cursor configuration tracing ENABLED")
  (message "Start a new Claude session to see trace output"))

(defun claude-cursor-disable-tracing ()
  "Disable cursor configuration tracing."
  (interactive)
  (advice-remove 'claude-code-ide--configure-vterm-cursor
                 #'claude-code-ide--configure-vterm-cursor-traced)
  (message "Cursor configuration tracing DISABLED"))

;; Test in current buffer
(defun claude-cursor-test-now ()
  "Test cursor configuration in current buffer immediately."
  (interactive)
  (message "")
  (message "=== Testing cursor config in current buffer ===")
  (claude-code-ide--configure-vterm-cursor-traced)
  (message "=== Test complete - check messages above ==="))

;;; trace-cursor-config.el ends here
