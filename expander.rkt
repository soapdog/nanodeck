#lang br/quicklang

(require
  slideshow
  slideshow/slides-to-picts
  json
  pict
  racket/gui/base
  racket/base
  "slide-to-js.rkt")

(define-macro (nd-module-begin PATH (nd-program SLIDE ...))
  
  #'(#%module-begin
     (define original-source PATH)
     (displayln "Compiling nanodeck...")
     (define slides (list SLIDE ...))
     (displayln (format "- number of slides in deck: ~a" (length slides)))
     ;(slides->js original-source slides 1024 768)
     (slides->wasm original-source slides 1024 768)
     ))
(provide (rename-out [nd-module-begin #%module-begin]))

(define-macro (nd-short-slide SLIDE)
  #'(list 'slide SLIDE))
(provide nd-short-slide)

(define-macro (nd-text TEXT)
  #'(list 't TEXT))
(provide nd-text)

(define-macro (nd-para TEXT)
  #'(list 'para TEXT))
(provide nd-para)

(define-macro (nd-long-slide SLIDE ...)
  #'(list 'slide SLIDE ...))
(provide nd-long-slide)

(define-macro (nd-long-slide-with-repetition TIME SLIDE ...)
  #'(make-list TIME (list 'slide SLIDE ...)))
(provide nd-long-slide-with-repetition)

(define-macro (nd-long-slide-with-background-image IMAGE SLIDE ...)
  #'(list (list 'background-image (list 'bitmap IMAGE)) (list 'slide SLIDE ...) (list 'background-image #f)))
(provide nd-long-slide-with-background-image)

(define-macro (nd-footer-text TEXT)
  #'(list 't TEXT))
(provide nd-footer-text)

(define-macro (nd-spacer)
  #'(list 'blank))
(provide nd-spacer)

(define-macro (nd-background-image IMAGE)
  #'(list 't IMAGE))
(provide nd-background-image)

(define-macro (nd-image IMAGE)
  #'(list 'bitmap (list 'build-path IMAGE)))
(provide nd-image)


(define-macro (nd-color COLOR TEXT ...)
  #'(list 'colorize TEXT ... COLOR))
(provide nd-color)


(define-macro (nd-item ITEM ...)
  #'(list 'item ITEM ...))
(provide nd-item)


(define-macro (nd-font-size SIZE)
  #'(list 'current-font-size SIZE))
(provide nd-font-size)


(define-macro (nd-font-name NAME)
  #'(list 'current-main-font NAME))
(provide nd-font-name)
