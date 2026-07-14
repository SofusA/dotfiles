(require "helix/components.scm")
(require "helix/configuration.scm")
(require "helix/misc.scm")
(require "helix/editor.scm")
(require "helix/static.scm")
(require (prefix-in helix. "helix/commands.scm"))

(provide ux-bufferline-enable!
         ux-bufferline-disable!
         ux-bufferline-reset!
         ux-bufferline-next
         ux-bufferline-previous
         ux-bufferline-move-left
         ux-bufferline-move-right
         ux-bufferline-buffers)

;; -----------------------------------------------------------------------------
;; State
;; -----------------------------------------------------------------------------

(define *ux-bufferline-enabled?* #f)
(define *ux-bufferline-component-installed?* #f)
(define *ux-bufferline-hooks-registered?* #f)

;; The plugin's ordered buffer list.
;;
;; Entries are absolute/full document paths. We deliberately do not derive the
;; render order from editor-all-documents after initialization.
(define *ux-bufferline-buffers* '())

(define *ux-bufferline-row* 0)
(define *ux-bufferline-gap* 0)

;; Used for optional mouse interaction.
;; Each entry is: (list path start-column end-column)
(define *ux-bufferline-tabs* '())

;; Stores path -> 1-based cursor line.
(define *ux-bufferline-lines* '())

(define (ux-bufferline-install-component!)
  (unless *ux-bufferline-component-installed?*
    (push-component!
      (new-component!
        "ux-bufferline"
        #f
        ux-render-bufferline
        (hash
          "cursor" ux-bufferline-cursor-handler
          "handle_event" ux-bufferline-handle-event)))

    (set! *ux-bufferline-component-installed?* #t)
    (ux-bufferline-update-clip!)
    (helix.redraw)))

;; -----------------------------------------------------------------------------
;; Small list helpers
;; -----------------------------------------------------------------------------

(define (ux-list-contains? xs value)
  (cond
    [(null? xs) #f]
    [(equal? (car xs) value) #t]
    [else (ux-list-contains? (cdr xs) value)]))

(define (ux-list-remove xs value)
  (cond
    [(null? xs) '()]
    [(equal? (car xs) value)
     (ux-list-remove (cdr xs) value)]
    [else
     (cons (car xs) (ux-list-remove (cdr xs) value))]))

(define (ux-list-last xs)
  (cond
    [(null? xs) #f]
    [(null? (cdr xs)) (car xs)]
    [else (ux-list-last (cdr xs))]))

(define (ux-filter predicate xs)
  (cond
    [(null? xs) '()]
    [(predicate (car xs))
     (cons (car xs) (ux-filter predicate (cdr xs)))]
    [else
     (ux-filter predicate (cdr xs))]))

;; -----------------------------------------------------------------------------
;; Document/path access
;; -----------------------------------------------------------------------------

(define (ux-document-path doc-id)
  (with-handler
    (lambda (_) #f)
    (editor-document->path doc-id)))

(define (ux-current-path)
  (with-handler
    (lambda (_) #f)
    (editor-document->path
      (editor->doc-id (editor-focus)))))

(define (ux-live-paths)
  (with-handler
    (lambda (_) '())
    (ux-filter
      (lambda (path) path)
      (map ux-document-path (editor-all-documents)))))

(define (ux-path-live? path)
  (ux-list-contains? (ux-live-paths) path))

;; Public mostly for debugging:
;;
;;   :eval (ux-bufferline-buffers)
;;
(define (ux-bufferline-buffers)
  *ux-bufferline-buffers*)

;; -----------------------------------------------------------------------------
;; Maintaining the plugin-owned buffer list
;; -----------------------------------------------------------------------------

(define (ux-bufferline-add-path! path)
  (when (and path
             (not (ux-list-contains? *ux-bufferline-buffers* path)))
    (set! *ux-bufferline-buffers*
          (append *ux-bufferline-buffers* (list path)))))

(define (ux-bufferline-remove-path! path)
  (when path
    (set! *ux-bufferline-buffers*
          (ux-list-remove *ux-bufferline-buffers* path))))

;; Reconciliation is intentionally conservative:
;;
;; - Preserve the plugin's current order.
;; - Remove entries that no longer correspond to live documents.
;; - Add newly discovered documents at the end.
;;
;; This is useful because the exact document-closed hook payload may differ
;; between Steel integration revisions.
(define (ux-bufferline-reconcile!)
  (define live-paths (ux-live-paths))

  (define preserved
    (ux-filter
      (lambda (path)
        (ux-list-contains? live-paths path))
      *ux-bufferline-buffers*))

  (define missing
    (ux-filter
      (lambda (path)
        (not (ux-list-contains? preserved path)))
      live-paths))

  (set! *ux-bufferline-buffers*
        (append preserved missing)))

(define (ux-bufferline-reset!)
  (set! *ux-bufferline-buffers* '())
  (for-each ux-bufferline-add-path! (ux-live-paths))
  (ux-bufferline-update-clip!)
  (helix.redraw))

;; -----------------------------------------------------------------------------
;; Hooks
;; -----------------------------------------------------------------------------

(define (ux-bufferline-document-opened! doc-id)
  (ux-bufferline-add-path! (ux-document-path doc-id))

  ;; init.scm may run before the editor's initial document and component stack
  ;; are ready. The first document-opened event is a safe point to install.
  (when *ux-bufferline-enabled?*
    (ux-bufferline-install-component!))

  (ux-bufferline-update-clip!)
  (helix.redraw))

(define (ux-bufferline-document-closed! closed-event)
  ;; Do not depend on the shape of closed-event. By the time this hook runs,
  ;; editor-all-documents should no longer contain the closed document.
  (ux-bufferline-reconcile!)
  (ux-bufferline-update-clip!)
  (helix.redraw))

(define (ux-bufferline-register-hooks!)
  (unless *ux-bufferline-hooks-registered?*
    (register-hook
      'document-opened
      ux-bufferline-document-opened!)

    (register-hook
      'document-closed
      ux-bufferline-document-closed!)

    (set! *ux-bufferline-hooks-registered?* #t)))

;; -----------------------------------------------------------------------------
;; Reordering
;; -----------------------------------------------------------------------------

;; Move target one position toward the start of the list.
(define (ux-move-before xs target)
  (let loop ([rest xs] [reversed-prefix '()])
    (cond
      [(null? rest)
       xs]

      [(equal? (car rest) target)
       (if (null? reversed-prefix)
           xs
           (let ([previous (car reversed-prefix)]
                 [prefix-before-previous (cdr reversed-prefix)])
             (append
               (reverse prefix-before-previous)
               (list target previous)
               (cdr rest))))]

      [else
       (loop (cdr rest)
             (cons (car rest) reversed-prefix))])))

;; Move target one position toward the end of the list.
(define (ux-move-after xs target)
  (cond
    [(null? xs)
     '()]

    [(and (equal? (car xs) target)
          (not (null? (cdr xs))))
     (cons (cadr xs)
           (cons (car xs)
                 (cddr xs)))]

    [else
     (cons (car xs)
           (ux-move-after (cdr xs) target))]))

;;@doc
;; Move the active buffer one position left in the plugin buffer list.
(define (ux-bufferline-move-left)
  (define current (ux-current-path))

  (when (and current
             (ux-list-contains? *ux-bufferline-buffers* current))
    (set! *ux-bufferline-buffers*
          (ux-move-before *ux-bufferline-buffers* current))
    (helix.redraw)))

;;@doc
;; Move the active buffer one position right in the plugin buffer list.
(define (ux-bufferline-move-right)
  (define current (ux-current-path))

  (when (and current
             (ux-list-contains? *ux-bufferline-buffers* current))
    (set! *ux-bufferline-buffers*
          (ux-move-after *ux-bufferline-buffers* current))
    (helix.redraw)))

;; -----------------------------------------------------------------------------
;; Navigation
;; -----------------------------------------------------------------------------

(define (ux-next-path paths current)
  (cond
    [(null? paths)
     #f]

    [(not current)
     (car paths)]

    [else
     (let loop ([rest paths])
       (cond
         ;; Current path was not found, so use the first managed buffer.
         [(null? rest)
          (car paths)]

         ;; Wrap at the end.
         [(and (equal? (car rest) current)
               (null? (cdr rest)))
          (car paths)]

         ;; Normal next item.
         [(equal? (car rest) current)
          (cadr rest)]

         [else
          (loop (cdr rest))]))]))

(define (ux-previous-path paths current)
  (cond
    [(null? paths)
     #f]

    [(not current)
     (ux-list-last paths)]

    [else
     (let loop ([rest paths] [previous #f])
       (cond
         ;; Current path was not found.
         [(null? rest)
          (ux-list-last paths)]

         ;; Wrap from the first item to the last.
         [(and (equal? (car rest) current)
               (not previous))
          (ux-list-last paths)]

         ;; Normal previous item.
         [(equal? (car rest) current)
          previous]

         [else
          (loop (cdr rest) (car rest))]))]))

(define (ux-bufferline-save-line! path line)
  (set! *ux-bufferline-lines*
        (cons (list path line)
              (ux-filter
                (lambda (entry)
                  (not (equal? (car entry) path)))
                *ux-bufferline-lines*))))

(define (ux-bufferline-line-for path)
  (let loop ([entries *ux-bufferline-lines*])
    (cond
      [(null? entries) 1]
      [(equal? (car (car entries)) path)
       (cadr (car entries))]
      [else
       (loop (cdr entries))])))

(define (ux-bufferline-save-current-line!)
  (define path (ux-current-path))
  (when path
    (ux-bufferline-save-line!
      path
      (+ 1 (get-current-line-number)))))

;; Keep this command call isolated because the Steel wrapper signature has
;; changed across experimental Helix revisions.
;;
;; In the current command wrappers, typable command arguments are normally
;; represented as a list of strings.
(define (ux-bufferline-open-path! path)
  (when path
    (ux-bufferline-save-current-line!)

    (apply helix.open
      (list
        (string-append
          path
          ":"
          (number->string
            (ux-bufferline-line-for path)))))

    (helix.redraw)))

;;@doc
;; Open the next buffer in the plugin-owned buffer order.
(define (ux-bufferline-next)
  (ux-bufferline-reconcile!)
  (ux-bufferline-open-path!
    (ux-next-path
      *ux-bufferline-buffers*
      (ux-current-path))))

;;@doc
;; Open the previous buffer in the plugin-owned buffer order.
(define (ux-bufferline-previous)
  (ux-bufferline-reconcile!)
  (ux-bufferline-open-path!
    (ux-previous-path
      *ux-bufferline-buffers*
      (ux-current-path))))

;; -----------------------------------------------------------------------------
;; Rendering
;; -----------------------------------------------------------------------------

(define (ux-bufferline-visible?)
  (not (null? *ux-bufferline-buffers*)))

(define (ux-bufferline-update-clip!)
  (set-editor-clip-top!
    (if (and *ux-bufferline-enabled?*
             (ux-bufferline-visible?))
        (+ *ux-bufferline-row* 1)
        0)))

(define (ux-buffer-name path)
  (with-handler
    (lambda (_) path)
    (file-name path)))

(define (ux-buffer-dirty? path)
  ;; The ordered state remains path-based, but dirty state is read live from
  ;; Helix so that the list does not need to duplicate document metadata.
  (let loop ([docs
              (with-handler
                (lambda (_) '())
                (editor-all-documents))])
    (cond
      [(null? docs)
       #f]

      [(equal? (ux-document-path (car docs)) path)
       (with-handler
         (lambda (_) #f)
         (editor-document-dirty? (car docs)))]

      [else
       (loop (cdr docs))])))

(define (ux-buffer-label path)
  (string-append
    " "
    (ux-buffer-name path)
    (if (ux-buffer-dirty? path) " *" "")
    " "))

(define (ux-bufferline-base-style)
  (theme-scope-ref "ui.background"))

(define (ux-bufferline-active-style)
  (theme-scope-ref "ui.bufferline.active"))

(define (ux-bufferline-inactive-style)
  (theme-scope-ref "ui.bufferline"))

(define (ux-render-bufferline state rect frame)
  (when (ux-bufferline-visible?)
    (define width (area-width rect))
    (define height (area-height rect))
    (define y (max 0 (min (- height 1) *ux-bufferline-row*)))
    (define current (ux-current-path))
    (define base-style (ux-bufferline-base-style))

    (buffer/clear-with frame (area 0 y width 1) base-style)

    (let loop ([paths *ux-bufferline-buffers*]
               [x 0]
               [tabs '()])
      (cond
        [(or (null? paths) (>= x width))
         (set! *ux-bufferline-tabs* (reverse tabs))]

        [else
         (define path (car paths))
         (define label (ux-buffer-label path))
         (define remaining (- width x))
         (define label-width (string-length label))
         (define draw-width (min remaining label-width))

         ;; Avoid drawing past the terminal width.
         (define visible-label
           (substring label 0 draw-width))

         (define style
           (if (equal? path current)
               (ux-bufferline-active-style)
               (ux-bufferline-inactive-style)))

         (frame-set-string! frame x y visible-label style)

         (define end-x (+ x draw-width))
         (define next-x
           (min width (+ end-x *ux-bufferline-gap*)))

         (loop
           (cdr paths)
           next-x
           (cons (list path x end-x) tabs))]))))

(define (ux-bufferline-cursor-handler state rect)
  #f)

;; -----------------------------------------------------------------------------
;; Optional mouse navigation
;; -----------------------------------------------------------------------------

(define (ux-bufferline-path-at column)
  (let loop ([tabs *ux-bufferline-tabs*])
    (cond
      [(null? tabs)
       #f]

      [(and (>= column (cadr (car tabs)))
            (< column (caddr (car tabs))))
       (car (car tabs))]

      [else
       (loop (cdr tabs))])))

(define (ux-bufferline-handle-event state event)
  (if (and (mouse-event? event)
           (equal? (event-mouse-kind event) 0)
           (equal? (event-mouse-row event) *ux-bufferline-row*))
      (let ([path
             (ux-bufferline-path-at
               (event-mouse-col event))])
        (if path
            (begin
              (ux-bufferline-open-path! path)
              event-result/consume)
            event-result/ignore))
      event-result/ignore))

;; -----------------------------------------------------------------------------
;; Lifecycle
;; -----------------------------------------------------------------------------

(define (ux-bufferline-disable-native!)
  (with-handler
    (lambda (_) #f)
    (bufferline "never")))

(define (ux-bufferline-enable!)
  (unless *ux-bufferline-enabled?*
    ;; Mark the plugin as requested/enabled. The component itself may be
    ;; installed immediately or deferred until document-opened.
    (set! *ux-bufferline-enabled?* #t)

    (ux-bufferline-disable-native!)
    (ux-bufferline-register-hooks!)

    ;; Seed from any documents that already exist. This is the path taken when
    ;; enable is invoked later as a typed command.
    (ux-bufferline-reconcile!)

    ;; When called interactively, documents and the component stack already
    ;; exist. When called early from init.scm, installation is deferred to
    ;; document-opened.
    (unless (null? (ux-live-paths))
      (ux-bufferline-install-component!))

    (ux-bufferline-update-clip!)
    (helix.redraw)))

(define (ux-bufferline-disable!)
  (when *ux-bufferline-enabled?*
    (when *ux-bufferline-component-installed?*
      (pop-last-component-by-name! "ux-bufferline"))

    (set-editor-clip-top! 0)

    (set! *ux-bufferline-enabled?* #f)
    (set! *ux-bufferline-component-installed?* #f)
    (set! *ux-bufferline-tabs* '())

    (helix.redraw)))
