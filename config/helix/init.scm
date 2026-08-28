(require "helix/configuration.scm")
(define-lsp "steel-language-server" (command "steel-language-server") (args '()))
(define-language "scheme"
                 (language-servers '("steel-language-server")))

(require (only-in "bufferline.scm" ux-bufferline-enable!))
(ux-bufferline-enable!)

(require "jj-status.scm")
(setup-jj-status! 'center)
