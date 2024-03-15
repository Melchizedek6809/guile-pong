;;; Pretty terrible code, but for now I'm just trying to figure out the SDL2
;;; bindings, and then later experiment with nicer ways of structuring
;;; the codebase.

(define-module (pong game)
  #:use-module (sdl2)
  #:use-module (sdl2 events)
  #:use-module (sdl2 render)
  #:use-module (sdl2 input keyboard)
  #:use-module (sdl2 surface)
  #:use-module (sdl2 video))

;;; Globals-galore
(define angle 0)
(define game-running #t)
(define iterations 0)


(define (draw ren texture)
  (clear-renderer ren)
  (render-copy ren texture #:angle angle)
  (present-renderer ren)
  (set! angle (+ angle 0.1)))


(define (handle-events)
  (let ((e (poll-event)))
       (cond ((quit-event? e)
              (set! game-running #f)
              (handle-events))
             (#t #f))))

(define (handle-input)
  (set! iterations (+ 1 iterations))
  (when (> iterations 500) (set! game-running #f))
  (when (key-pressed? 'escape) (set! game-running #f))
  (when (key-pressed? 'return) (set! game-running #f))
  )


(define (game-loop-iter ren surface texture)
  (when game-running
    (handle-events)
    (handle-input)
    (draw ren texture)
    (game-loop-iter ren surface texture)))


(define (game-loop ren)
  (let* ((surface (load-bmp "assets/hello.bmp"))
         (texture (surface->texture ren surface)))
        (game-loop-iter ren surface texture)))


(define-public (pong-start options)
  (set! game-running #t)
  (set! angle 0)
  (set! iterations 0)
  (sdl-init)
  (call-with-window (make-window)
                    (lambda (window)
                      (set-window-title! window "Guile - Pong")
                      (call-with-renderer (make-renderer window) game-loop)))
  (sdl-quit))
