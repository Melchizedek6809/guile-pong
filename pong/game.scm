;;; Pretty terrible code, but for now I'm just trying to figure out the SDL2
;;; bindings, and then later experiment with nicer ways of structuring
;;; the codebase.

(define-module (pong game)
  #:use-module (ice-9 threads)
  #:use-module (sdl2)
  #:use-module (sdl2 events)
  #:use-module (sdl2 rect)
  #:use-module (sdl2 render)
  #:use-module (sdl2 input keyboard)
  #:use-module (sdl2 surface)
  #:use-module (sdl2 video))

;;; Globals-galore
(define angle 0)
(define game-running #t)
(define iterations 0)

(define win-width 640)
(define win-height 480)

(define player-height 128)
(define player-width 24)
(define left-player (- (/ win-height 2) (/ player-height 2)))
(define right-player left-player)

(define (clamp v vmin vmax)
  (min (max v vmin) vmax))

(define (draw-player ren x y)
  (set-renderer-draw-color! ren 255 0 0 255)
  ((@ (sdl2 render) fill-rect) ren (make-rect x y player-width player-height)))

(define (draw ren texture)
  (set-renderer-draw-color! ren 0 0 0 255)
  (clear-renderer ren)
  (render-copy ren texture #:angle angle)
  (draw-player ren 16 left-player)
  (draw-player ren (- win-width (+ player-width 16)) right-player)
  (present-renderer ren)
  (set! angle (+ angle 0.1)))


(define (handle-events)
  (let ((e (poll-event)))
       (cond [(quit-event? e)
              (set! game-running #f)
              (handle-events)]
             [(eq? e #f) #f]
             (#t (handle-events)))))

(define (handle-input)
  (when (key-pressed? 'escape) (set! game-running #f))
  (when (key-pressed? 'w) (set! left-player (- left-player 1)))
  (when (key-pressed? 's) (set! left-player (+ left-player 1)))
  (when (key-pressed? 'up) (set! right-player (- right-player 1)))
  (when (key-pressed? 'down) (set! right-player (+ right-player 1)))
  (set! left-player (clamp left-player 0 (- win-height player-height)))
  (set! right-player (clamp right-player 0 (- win-height player-height)))
  (set! iterations (+ 1 iterations)))


(define (game-loop-iter ren surface texture)
  (when game-running
    (handle-events)
    (handle-input)
    (draw ren texture)
    (yield) ; Necessary so Emacs doesn't block waiting on geiser
    (game-loop-iter ren surface texture)))


(define (game-loop ren)
  (let* ((surface (load-bmp "assets/bg.bmp"))
         (texture (surface->texture ren surface)))
        (game-loop-iter ren surface texture)))


(define-public (pong-start options)
  (set! game-running #t)
  (set! angle 0)
  (set! iterations 0)
  (set! left-player (- (/ win-height 2) (/ player-height 2)))
  (set! right-player left-player)
  (sdl-init)
  (call-with-window (make-window)
                    (lambda (window)
                      (set-window-title! window "Guile - Pong")
                      (call-with-renderer (make-renderer window) game-loop)))
  (sdl-quit))
