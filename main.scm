(when (current-filename)
  (add-to-load-path (dirname (current-filename))))

(use-modules (pong game))
(use-modules (ice-9 threads))
#|
When using geiser it's better to run the game in a future
(call-with-new-thread (lambda (pong-start '())))
|#

(if (current-filename)
    (pong-start '())
    (call-with-new-thread (lambda () (pong-start '()))))
