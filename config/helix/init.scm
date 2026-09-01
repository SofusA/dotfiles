(require "helix/configuration.scm")
(define-lsp "steel-language-server" (command "steel-language-server") (args '()))
(define-language "scheme"
                 (language-servers '("steel-language-server")))

(require (only-in "smith.hx/smith.scm" smith-plugin smith-prune smith-init))

(smith-plugin "https://github.com/apothecary103/case.hx.git"
  (config
    (require "case.hx/case.scm")
    (require (only-in "helix/keymaps.scm" add-global-keybinding))


    (define case-mode
      (hash "l" "switch_to_lowercase"
        "u" "switch_to_uppercase"
        "a" "switch_case"
        "c" ":switch-to-camel-case"
        "p" ":switch-to-pascal-case"
        "s" ":switch-to-snake-case"
        "k" ":switch-to-kebab-case"
        "C" ":switch-to-constant-case"
        "t" ":switch-to-title-case"
        "S" ":switch-to-sentence-case"))

    (add-global-keybinding
      (hash "normal" (hash "c" (hash "c" case-mode))))))

(smith-init)

(require (only-in "bufferline.scm" ux-bufferline-enable!))
(ux-bufferline-enable!)

(require "jj-status.scm")
(setup-jj-status! 'center)
