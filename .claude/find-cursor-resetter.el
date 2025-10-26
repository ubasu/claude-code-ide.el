;;; find-cursor-resetter.el --- Find what's resetting cursor-type to nil

;; This adds a variable watcher to cursor-type to catch what's changing it

(defvar claude-cursor-reset-log nil
  "Log of cursor-type changes with backtraces.")

(defun claude-cursor-watch-changes (symbol newval operation where)
  "Watch cursor-type changes and log them."
  (let ((backtrace-str (with-output-to-string
                         (let ((standard-output (current-buffer)))
                           (backtrace)))))
    (push (list :time (current-time-string)
                :symbol symbol
                :new-value newval
                :operation operation
                :where where
                :backtrace backtrace-str)
          claude-cursor-reset-log)
    (message "[CURSOR-WATCH] cursor-type changed to: %s (operation: %s)"
             newval operation)
    (when (null newval)
      (message "[CURSOR-WATCH] ⚠️  RESET TO NIL DETECTED!")
      (message "[CURSOR-WATCH] Backtrace:")
      (message "%s" backtrace-str))))

(defun claude-cursor-start-watching ()
  "Start watching cursor-type changes in current buffer."
  (interactive)
  (setq claude-cursor-reset-log nil)
  (add-variable-watcher 'cursor-type #'claude-cursor-watch-changes)
  (message "[CURSOR-WATCH] Started watching cursor-type changes")
  (message "[CURSOR-WATCH] Current value: %s" cursor-type))

(defun claude-cursor-stop-watching ()
  "Stop watching cursor-type changes."
  (interactive)
  (remove-variable-watcher 'cursor-type #'claude-cursor-watch-changes)
  (message "[CURSOR-WATCH] Stopped watching cursor-type"))

(defun claude-cursor-show-log ()
  "Show the log of cursor-type changes."
  (interactive)
  (if claude-cursor-reset-log
      (with-output-to-temp-buffer "*Cursor-Type Change Log*"
        (princ "=== CURSOR-TYPE CHANGE LOG ===\n\n")
        (dolist (entry (reverse claude-cursor-reset-log))
          (princ (format "Time: %s\n" (plist-get entry :time)))
          (princ (format "New Value: %s\n" (plist-get entry :new-value)))
          (princ (format "Operation: %s\n" (plist-get entry :operation)))
          (princ (format "Backtrace:\n%s\n" (plist-get entry :backtrace)))
          (princ "\n" (make-string 80 ?-) "\n\n")))
    (message "No cursor-type changes logged yet")))

(defun claude-cursor-test-with-watch ()
  "Test cursor setting while watching for resets."
  (interactive)
  (message "")
  (message "=== Testing with watcher enabled ===")
  (claude-cursor-start-watching)
  (message "Initial cursor-type: %s" cursor-type)
  (message "Setting cursor-type to 'box...")
  (setq-local cursor-type 'box)
  (message "After setting: %s" cursor-type)
  (message "Waiting 3 seconds...")
  (run-at-time 3 nil
               (lambda (buf)
                 (when (buffer-live-p buf)
                   (with-current-buffer buf
                     (message "After 3 seconds: cursor-type = %s" cursor-type)
                     (message "")
                     (message "=== Check *Messages* for [CURSOR-WATCH] entries ===")
                     (message "Run M-x claude-cursor-show-log to see full log"))))
               (current-buffer)))

;;; find-cursor-resetter.el ends here
