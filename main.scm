(when (current-filename)
  (add-to-load-path (dirname (current-filename))))

(use-modules (pong game))
(use-modules (ice-9 threads))

(if (current-filename)
    (pong-start '())
    (call-with-new-thread (lambda () (pong-start '()))))
