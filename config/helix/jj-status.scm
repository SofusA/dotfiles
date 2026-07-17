(require-builtin helix/components)
(require-builtin steel/process)
(require-builtin steel/time)

(require "helix/editor.scm")
(require "steel/result")

(provide jj-status-element setup-jj-status!)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Minimum time between jj invocations for the same directory.
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
;; Path helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Return the parent directory of a path.
;;
;; This supports both Unix "/" and Windows "\" path separators.

(define (path-parent path)
  (define characters
    (string->list path))

  (define (walk remaining index last-separator)
    (cond
      [(null? remaining)
       last-separator]

      [(or (equal? (car remaining) #\/)
           (equal? (car remaining) #\\))
       (walk
         (cdr remaining)
         (+ index 1)
         index)]

      [else
       (walk
         (cdr remaining)
         (+ index 1)
         last-separator)]))

  (define separator-index
    (walk characters 0 #false))

  (if separator-index
      (substring path 0 separator-index)
      "."))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; String helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Remove trailing LF and CR characters from command output.
;;
;; This intentionally doesn't remove spaces because the JJ template may
;; intentionally include them.
(define (trim-line-ending value)
  (define newline-character
    (integer->char 10))

  (define return-character
    (integer->char 13))

  (define (trim-to end)
    (if (= end 0)
        ""
        (let ([last-character
               (string-ref value (- end 1))])
          (if (or
                (equal? last-character newline-character)
                (equal? last-character return-character))
              (trim-to (- end 1))
              (substring value 0 end)))))

  (trim-to (string-length value)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Process execution
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Run a command in the specified directory and capture its standard output.
(define (capture-command program arguments working-directory)
  (define process
    (command program arguments))

  ;; These functions mutate the command builder.
  (set-current-dir! process working-directory)
  (set-piped-stdout! process)

  (~> process
      (spawn-process)
      (Ok->value)
      (wait->stdout)
      (Ok->value)))

;; Query the current JJ revision.
(define (load-jj-status directory)
  (trim-line-ending
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
        jj-template)
      directory)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Status cache
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Each cache entry has this shape:
;;
;;   (directory timestamp status)
;;
;; The cache is keyed by directory so split views and files in different
;; repositories can have independent status values.
(define *jj-status-cache* '())

(define (cache-entry-directory entry)
  (car entry))

(define (cache-entry-timestamp entry)
  (car (cdr entry)))

(define (cache-entry-status entry)
  (car (cdr (cdr entry))))

;; Find the cached entry for a directory.
(define (find-cache-entry directory entries)
  (cond
    [(null? entries)
     #false]

    [(equal?
       directory
       (cache-entry-directory (car entries)))
     (car entries)]

    [else
     (find-cache-entry
       directory
       (cdr entries))]))

;; Remove all existing entries for a directory.
(define (remove-cache-entry directory entries)
  (cond
    [(null? entries)
     '()]

    [(equal?
       directory
       (cache-entry-directory (car entries)))
     (remove-cache-entry
       directory
       (cdr entries))]

    [else
     (cons
       (car entries)
       (remove-cache-entry
         directory
         (cdr entries)))]))

;; Insert or replace a cache entry.
(define (store-cache-entry! directory timestamp status)
  (set! *jj-status-cache*
    (cons
      (list directory timestamp status)
      (remove-cache-entry
        directory
        *jj-status-cache*))))

;; Return true when an existing cache entry is still fresh.
(define (cache-entry-fresh? entry now)
  (and
    entry
    (< (- now (cache-entry-timestamp entry))
       jj-refresh-interval-ms)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Status calculation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (jj-status-for-document document-id)
  (define document-path
    (editor-document->path document-id))

  ;; Scratch buffers and virtual documents may not have a filesystem path.
  (if (not document-path)
      ""
      (let* ([directory
              (path-parent document-path)]

             [now
              (current-milliseconds)]

             [cached
              (find-cache-entry
                directory
                *jj-status-cache*)])

        (if (cache-entry-fresh? cached now)

            ;; Reuse the cached value if it is less than one second old.
            (cache-entry-status cached)

            ;; Otherwise, query JJ and update the cache.
            (let ([status
                   (load-jj-status directory)])

              (store-cache-entry!
                directory
                now
                status)

              status)))))

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
