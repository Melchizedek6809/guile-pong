(define-module (pong game)
  #:use-module (sdl2)
  #:use-module (sdl2 render)
  #:use-module (sdl2 surface)
  #:use-module (sdl2 video))

(define angle 0)

(define (draw ren texture)
    (clear-renderer ren)
    (render-copy ren texture #:angle angle)
    (present-renderer ren)
    (set! angle (+ angle 0.1)))

(define (game-loop-iter ren surface texture i)
  (if (> i 1000)
      #f
      (begin (draw ren texture)
             (game-loop-iter ren surface texture (+ 1 i)))))

(define (game-loop ren)
  (let* ((surface (load-bmp "assets/hello.bmp"))
         (texture (surface->texture ren surface)))
        (game-loop-iter ren surface texture 0)))

(define-public (pong-start options)
  (sdl-init)
  (call-with-window (make-window)
                    (lambda (window)
                      (set-window-title! window "Guile - Pong")
                      (call-with-renderer (make-renderer window) game-loop)))
  (sdl-quit))
