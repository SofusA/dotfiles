(require-builtin helix/components)
(require-builtin steel/process)
(require-builtin steel/time)

(require "helix/editor.scm")
(require "steel/result")

(provide jj-status-element setup-jj-status!)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Minimum time between JJ invocations.
(define jj-refresh-interval-ms 10000)

;; Keep the JJ template separate from the command invocation so that quoting
;; does not need to pass through a shell.
(define jj-template
  "surround(
     \" (\",
     \")\",
     separate(
       \" \",
       bookmarks.join(\", \"),
       coalesce(
         if(
           description.first_line().substr(0, 24).starts_with(
             description.first_line()
           ),
           description.first_line().substr(0, 24),
           description.first_line().substr(0, 23) ++ \"…\"
         ),
         label(if(empty, \"empty\"), description_placeholder)
       ),
       if(conflict, label(\"conflict\", \"conflict\")),
       if(empty, label(\"empty\", \"empty\")),
       if(divergent, \"divergent\"),
       if(hidden, \"hidden\")
     )
   )")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Process execution
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Run a command and capture its standard output.
;;
;; The command inherits Helix's current working directory. JJ will discover
;; the workspace by searching upward from that directory.
(define (capture-command program arguments)
  (define process
    (command program arguments))

  (set-piped-stdout! process)

  (~> process
      (spawn-process)
      (Ok->value)
      (wait->stdout)
      (Ok->value)))

;; Query the current JJ revision.
(define (load-jj-status)
  (capture-command
    "jj"
    (list
      "log"
      "--ignore-working-copy"
      "--no-graph"

      ;; Status spans do not necessarily interpret ANSI escape sequences,
      ;; so use plain text here.
      "--color"
      "never"

      "-r"
      "@"
      "-T"
      jj-template)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Status cache
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Since JJ runs relative to Helix's working directory, only one cached value
;; is required.
(define *jj-status-timestamp* #false)
(define *jj-status* "")

;; Return true when the cached value is still fresh.
(define (jj-status-fresh? now)
  (and
    *jj-status-timestamp*
    (< (- now *jj-status-timestamp*)
       jj-refresh-interval-ms)))

;; Return the cached status or refresh it when necessary.
(define (cached-jj-status)
  (define now
    (current-milliseconds))

  (if (jj-status-fresh? now)
      *jj-status*
      (let ([status
             (load-jj-status)])

        (set! *jj-status-timestamp* now)
        (set! *jj-status* status)

        status)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Status calculation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (jj-status-for-document document-id)
  ;; Scratch buffers and virtual documents may not have a filesystem path.
  ;; Keep this check so they do not display the repository status.
  (if (editor-document->path document-id)
      (cached-jj-status)
      ""))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Status element
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define jj-status-element
  (status-element
    (lambda (view-id active?)
      ;; The callback currently receives a ViewId even though some versions
      ;; of the component documentation describe it as a DocumentId.
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
