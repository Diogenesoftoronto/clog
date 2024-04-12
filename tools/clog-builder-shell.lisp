(in-package :clog-tools)

(defun on-shell (obj)
  "Open a shell"
  (let* ((*default-title-class*      *builder-title-class*)
         (*default-border-class*     *builder-border-class*)
         (win (create-gui-window obj :title (format nil "OS Shell - ~A - ~A"
                                                    (uiop:operating-system)
                                                    (uiop:hostname))
                                     :top 40 :left 225
                                     :width 600 :height 400
                                     :client-movement *client-side-movement*)))
    (set-geometry (create-clog-builder-shell (window-content win))
                                            :units "%" :width 100 :height 100)))

(defun shell-on-create (panel target)
  (setf (text-value (package-div panel)) (uiop:getcwd))
  (clog-terminal:prompt target "$ "))

(defun shell-on-commmand (panel target data)
  (handler-case
    (if (and (> (length data) 3)
             (equalp (subseq data 0 3) "cd "))
          (uiop:with-current-directory ((format nil "~A~A"
                                                (subseq data 3 (length data))
                                                (uiop:directory-separator-for-host)))
            (setf (text-value (package-div panel)) (uiop:getcwd)))
          (uiop:with-current-directory ((text-value (package-div panel)))
            (multiple-value-bind (result new-package new-dir)
              (capture-eval (format nil "(uiop:run-program \"~A\" :output *standard-output*)(uiop:getcwd)" data)
                            :clog-obj            panel
                            :eval-form           "~A"
                            :capture-result-form ""
                            :capture-console     t
                            :capture-result      nil)
              (declare (ignore new-package))
              (setf (text-value (package-div panel)) new-dir)
              (clog-terminal:echo target result))))
    (error (c)
      (clog-terminal:echo target (format nil "~A" c)))))
    