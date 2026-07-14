(require "helix/configuration.scm")
(define-lsp "steel-language-server" (command "steel-language-server") (args '()))
(define-language "scheme"
                 (language-servers '("steel-language-server")))

(require (only-in "smith.hx/smith.scm"
                  smith-plugin
                  smith-prune
                  smith-init))

(smith-plugin "https://github.com/Ra77a3l3-jar/forest.hx.git"
  (config
   (forest-set-style! 'snacks))
   (bind ("normal" ("space" "e") ":forest-open")))

(smith-plugin "https://github.com/gllms/streal.hx.git"
  (bind ("normal" ("R") ":streal-open")))

(smith-init)

(require (only-in "bufferline.scm" ux-bufferline-enable!))

(ux-bufferline-enable!)

(require "jj-status.scm")
(setup-jj-status! 'center)
