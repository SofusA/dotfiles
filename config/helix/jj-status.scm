(require-builtin helix/components)
(require-builtin steel/process)

(require "helix/editor.scm")
(require "steel/result")

(provide setup-jj-status!)

;; Remove trailing LF/CR characters without relying on string-trim.
(define (trim-line-ending value)
  (define (trim-to end)
    (if (= end 0)
        ""
        (let ([last-character (string-ref value (- end 1))])
          (if (or (equal? last-character #\newline)
                  (equal? last-character #\return))
              (trim-to (- end 1))
              (substring value 0 end)))))

  (trim-to (string-length value)))

;; Keep the template as a separate string so Scheme and shell quoting
;; do not become intertwined.
(define jj-template
    "separate(
            \" \",
            bookmarks.join(\", \"),
            coalesce(
                if(
                    description.first_line().substr(0, 24).starts_with(description.first_line()),
                    description.first_line().substr(0, 24),
                    description.first_line().substr(0, 23) ++ \"…\"
                ),
                description_placeholder
            ),
            if(conflict, label(\"conflict\", \"conflict\")),
            if(divergent, \"divergent\"),
            if(hidden, \"hidden\")
        )
   ")

;; Return the parent directory of a path.
;;
;; This deliberately handles both "/" and "\\" so the plugin does not
;; assume that paths always use Unix separators.
(define (path-parent path)
  (define chars (string->list path))

  (define (walk rest index last-separator)
    (cond
      [(null? rest)
       last-separator]

      [(or (equal? (car rest) #\/)
           (equal? (car rest) #\\))
       (walk (cdr rest) (+ index 1) index)]

      [else
       (walk (cdr rest) (+ index 1) last-separator)]))

  (define separator-index (walk chars 0 #false))

  (if separator-index
      (substring path 0 separator-index)
      "."))

;; Capture standard output from a command.
(define (capture-command program arguments working-directory)
  (define process (command program arguments))

  ;; The process functions mutate the command builder.
  (set-current-dir! process working-directory)
  (set-piped-stdout! process)

  (~> process
      (spawn-process)
      (Ok->value)
      (wait->stdout)
      (Ok->value)))

;; Remove the trailing newline printed by jj.
(define (trim-status-output output)
  (trim-line-ending output))

(define (jj-status-for-document document-id)
  (define document-path
    (editor-document->path document-id))

  ;; Scratch buffers and other virtual documents may not have a path.
  (if (not document-path)
      ""
      (trim-status-output
        (capture-command
          "jj"
          (list
            "log"
            "--no-graph"

            "--color"
            "never"

            "-r"
            "@"
            "-T"
            jj-template)
          (path-parent document-path)))))

(define jj-status-element
  (status-element
    (lambda (view-id active?)
      (define document-id
        (editor->doc-id view-id))

      (define output
        (jj-status-for-document document-id))

      (if (equal? output "")
          '()
          (list
            (span output (style)))))))

(define (setup-jj-status! position)
  (push-status-element! position jj-status-element))
