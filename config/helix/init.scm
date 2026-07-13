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

