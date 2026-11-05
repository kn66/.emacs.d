;;; my-ime-tests.el --- Tests for shared IME state handling -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)

(defvar repeat-in-progress)

;; Load only definitions from the minibuffer declaration.  This avoids
;; initializing packages, installing global hooks, or contacting a desktop IME.
(let* ((root (file-name-directory (directory-file-name
                                   (file-name-directory (or load-file-name buffer-file-name)))))
       (file (expand-file-name "init.el" root))
       declaration)
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (condition-case nil
        (while t
          (let ((form (read (current-buffer))))
            (when (and (eq (car-safe form) 'use-package)
                       (eq (cadr form) 'minibuffer))
              (setq declaration form))))
      (end-of-file nil)))
  (unless declaration (error "Could not find minibuffer declaration"))
  (dolist (form (cdr (memq :config declaration)))
    (when (memq (car-safe form) '(defvar defvar-local defun))
      (eval form t))))

(defmacro my-ime-test-with-backend (&rest body)
  "Run BODY with an in-memory IME and fresh shared state."
  (declare (indent 0) (debug t))
  `(let ((my-ime-prefix-state nil)
         (my-ime-last-editable-state nil)
         (my-ime-readonly-state nil)
         (repeat-in-progress nil)
         (ime-status t)
         (ime-writes nil))
     (cl-letf (((symbol-function 'my-ime-available-p) (lambda () t))
               ((symbol-function 'my-ime-get-open-status) (lambda () ime-status))
               ((symbol-function 'my-ime-set-open-status)
                (lambda (status) (push status ime-writes) (setq ime-status status))))
       ,@body)))

(ert-deftest my-ime-prefix-restores-on-and-off ()
  (dolist (initial '(t nil))
    (my-ime-test-with-backend
      (setq ime-status initial)
      (with-temp-buffer
        (let ((translate (my-ime-prefix-translation [24])))
          (should (equal (funcall translate) [24]))
          (should-not ime-status)
          (should (consp my-ime-prefix-state))
          (my-ime-restore-prefix)
          (should (eq ime-status initial))
          (should-not my-ime-prefix-state)
          (should (equal my-ime-last-editable-state (cons t initial))))))))

(ert-deftest my-ime-prefix-minibuffer-handoff-and-cancel ()
  (my-ime-test-with-backend
    (with-temp-buffer
      (funcall (my-ime-prefix-translation [24]))
      (with-temp-buffer
        (cl-letf (((symbol-function 'minibufferp) (lambda (&rest _) t)))
          (my-minibuffer-disable-ime)
          (should-not my-ime-prefix-state)
          (should (equal my-minibuffer-ime-open-status '(t . t)))
          ;; A prefix begun in the minibuffer must be discarded on exit,
          ;; including the exit path used for a cancelled minibuffer.
          (funcall (my-ime-prefix-translation [24]))
          (my-minibuffer-restore-ime)
          (should ime-status)
          (should-not my-ime-prefix-state)
          (should-not my-minibuffer-ime-open-status))))))

(ert-deftest my-ime-recursive-minibuffers-save-independently ()
  (my-ime-test-with-backend
    (with-temp-buffer
      (my-minibuffer-disable-ime)
      (should-not ime-status)
      (with-temp-buffer
        (my-minibuffer-disable-ime)
        (setq ime-status t)
        (my-minibuffer-restore-ime)
        (should-not ime-status))
      (should (equal my-minibuffer-ime-open-status '(t . t)))
      (my-minibuffer-restore-ime)
      (should ime-status))))

(ert-deftest my-ime-readonly-search-and-editable-restore ()
  (my-ime-test-with-backend
    (with-temp-buffer
      (my-ime-before-command)
      (setq buffer-read-only t)
      (my-ime-after-command)
      (should-not ime-status)
      (should (equal my-ime-readonly-state '(t . t)))
      ;; The user can enable the IME during search; ending it turns it off.
      (setq ime-status t)
      (my-ime-after-isearch)
      (should-not ime-status)
      (setq buffer-read-only nil)
      (my-ime-before-command)
      (my-ime-after-command)
      (should ime-status)
      (should-not my-ime-readonly-state))))

(ert-deftest my-ime-repeat-restores-after-exit ()
  (my-ime-test-with-backend
    (with-temp-buffer
      (my-ime-before-command)
      (setq repeat-in-progress t)
      (my-ime-after-command)
      (should-not ime-status)
      (should (consp my-ime-prefix-state))
      (setq repeat-in-progress nil)
      (my-ime-after-repeat-exit)
      (should ime-status)
      (should-not my-ime-prefix-state))))

(ert-deftest my-ime-readonly-to-repeat-restores-after-exit ()
  (my-ime-test-with-backend
    (with-temp-buffer
      (my-ime-before-command)
      (setq buffer-read-only t)
      (my-ime-after-command)
      (setq buffer-read-only nil repeat-in-progress t)
      (my-ime-before-command)
      (my-ime-after-command)
      (should-not ime-status)
      (should-not my-ime-readonly-state)
      (should (equal (cdr my-ime-prefix-state) t))
      (setq repeat-in-progress nil)
      (my-ime-after-repeat-exit)
      (should ime-status))))

(ert-deftest my-ime-unavailable-does-not-change-backend ()
  (my-ime-test-with-backend
    (cl-letf (((symbol-function 'my-ime-available-p) (lambda () nil)))
      (with-temp-buffer
        (funcall (my-ime-prefix-translation [24]))
        (my-ime-before-command)
        (my-ime-after-command)
        (my-minibuffer-disable-ime)
        (my-minibuffer-restore-ime)
        (setq buffer-read-only t)
        (my-ime-after-isearch)
        (should ime-status)
        (should-not ime-writes)
        (should-not my-ime-prefix-state)
        (should-not my-ime-last-editable-state)
        (should-not my-ime-readonly-state)))))

(ert-deftest my-ime-fcitx5-uses-existing-owner-and-bounded-calls ()
  (let (calls)
    (cl-letf (((symbol-function 'dbus-call-method)
               (lambda (&rest args)
                 (push args calls)
                 (if (equal (nth 4 args) "GetNameOwner") ":1.42" 2))))
      (should (= 2 (my-ime-fcitx5-call "State")))
      (setq calls (nreverse calls))
      (should (equal (car calls)
                     '(:session "org.freedesktop.DBus" "/org/freedesktop/DBus"
                       "org.freedesktop.DBus" "GetNameOwner" :timeout 100
                       "org.fcitx.Fcitx5")))
      (should (equal (cadr calls)
                     '(:session ":1.42" "/controller" "org.fcitx.Fcitx.Controller1"
                       "State" :timeout 100))))))

(ert-deftest my-ime-fcitx5-missing-owner-and-errors-are-safe ()
  (let ((calls 0) (system-type 'gnu/linux) (window-system 'x))
    (cl-letf (((symbol-function 'display-graphic-p) (lambda (&rest _) t))
              ((symbol-function 'frame-focus-state) (lambda (&rest _) t))
              ((symbol-function 'getenv) (lambda (name) (and (equal name "GTK_IM_MODULE") "fcitx")))
              ((symbol-function 'dbus-call-method)
               (lambda (&rest _) (cl-incf calls) (error "No owner"))))
      (with-temp-buffer
        (should-not (my-ime-available-p))
        (my-ime-before-command)
        (my-ime-after-command)
        (my-minibuffer-disable-ime)
        (should (> calls 0))))))

(ert-deftest my-ime-linux-eligibility-and-dispatch ()
  (let ((system-type 'gnu/linux) (window-system 'x)
        (graphic t) (focused t) (module "fcitx") (state 2) calls)
    (cl-letf (((symbol-function 'display-graphic-p) (lambda (&rest _) graphic))
              ((symbol-function 'frame-focus-state) (lambda (&rest _) focused))
              ((symbol-function 'getenv) (lambda (name) (and (equal name "GTK_IM_MODULE") module)))
              ((symbol-function 'my-ime-fcitx5-call)
               (lambda (method) (push method calls) (when (equal method "State") state))))
      (should (my-ime-available-p))
      (should (my-ime-get-open-status))
      (my-ime-set-open-status nil)
      (my-ime-set-open-status t)
      (should (member "Deactivate" calls))
      (should (member "Activate" calls))
      (setq state 1)
      (should (my-ime-available-p))
      (should-not (my-ime-get-open-status))
      (setq state 0)
      (should-not (my-ime-available-p))
      (setq state 2 graphic nil)
      (should-not (my-ime-available-p))
      (setq graphic t focused nil calls nil)
      (should-not (my-ime-available-p))
      (my-ime-set-open-status t)
      (should-not calls)
      (setq focused t module "ibus")
      (should-not (my-ime-available-p)))))

(ert-deftest my-ime-windows-dispatch ()
  (let ((system-type 'windows-nt) written)
    (cl-letf (((symbol-function 'display-graphic-p) (lambda (&rest _) t))
              ((symbol-function 'w32-get-ime-open-status) (lambda () t))
              ((symbol-function 'w32-set-ime-open-status) (lambda (status) (setq written status))))
      (should (my-ime-available-p))
      (should (my-ime-get-open-status))
      (my-ime-set-open-status 'enabled)
      (should (eq written 'enabled)))))

;;; my-ime-tests.el ends here
