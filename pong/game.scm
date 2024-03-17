;;; Pretty terrible code, but for now I'm just trying to figure out the SDL2
;;; bindings, and then later experiment with nicer ways of structuring
;;; the codebase.

(define-module (pong game)
  #:export (pong-start)
  #:use-module (ice-9 threads)
  #:use-module (sdl2)
  #:use-module (sdl2 image)
  #:use-module (sdl2 events)
  #:use-module (sdl2 rect)
  #:use-module (sdl2 render)
  #:use-module (sdl2 input keyboard)
  #:use-module (sdl2 surface)
  #:use-module (sdl2 video))

;;; Globals-galore
(define game-running #t)
(define iterations 0)

(define win-width 640)
(define win-height 480)

(define player-height 128)
(define player-width 24)
(define left-player (- (/ win-height 2) (/ player-height 2)))
(define right-player left-player)

(define ren #f)
(define tex-bg #f)
(define tex-ball #f)
(define tex-player-a #f)
(define tex-player-b #f)

(define (clamp v vmin vmax)
  (min (max v vmin) vmax))

(define (draw-player x y tex)
  (render-copy ren tex #:dstrect (list x y player-width player-height)))

(define (draw)
  (set-renderer-draw-color! ren 0 0 0 255)
  (clear-renderer ren)
  (render-copy ren tex-bg)
  (draw-player 16 left-player tex-player-a)
  (draw-player (- win-width (+ player-width 16)) right-player tex-player-b)
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


(define (game-loop)
  (when game-running
    (handle-events)
    (handle-input)
    (draw)
    (yield) ; Necessary so Emacs doesn't block waiting on geiser
    (game-loop)))

(define (load-assets)
  (set! tex-bg (surface->texture ren (load-image "assets/bg.png")))
  (set! tex-ball (surface->texture ren (load-image "assets/ball.png")))
  (set! tex-player-a (surface->texture ren (load-image "assets/player_a.png")))
  (set! tex-player-b (surface->texture ren (load-image "assets/player_b.png")))
  #f)

(define (pong-start options)
  (set! game-running #t)
  (set! angle 0)
  (set! iterations 0)
  (set! left-player (- (/ win-height 2) (/ player-height 2)))
  (set! right-player left-player)
  (sdl-init)
  (image-init)
  (call-with-window (make-window)
                    (lambda (window)
                      (set-window-title! window "Guile - Pong")
                      (call-with-renderer (make-renderer window) (lambda (r)
                                                                   (set! ren r)
                                                                   (load-assets)
                                                                   (game-loop)))))
  (image-quit)
  (sdl-quit))
