#lang at-exp br
(require
  slideshow
  slideshow/slides-to-picts
  json
  pict
  racket/gui/base
  racket/base
  syntax/modresolve
  racket/format)

(define (slides->js nanodeck-file slides-as-list w h)
  
  ; auxiliary definitions ...
  (define build-folder (build-path (path-only nanodeck-file) "build"))
  
  (define intermediate-slide-representation-file
    (path->string (build-path build-folder (file-name-from-path (path-replace-extension nanodeck-file ".rkt")))))
  
  (define (slides-as-picts) (get-slides-as-picts intermediate-slide-representation-file w h #t))
  
  (define (picts-as-argb) (map (lambda (s) (bytes->list (pict->argb-pixels s 'unsmoothed))) (slides-as-picts)))

  (define html-file (build-path build-folder (file-name-from-path (path-replace-extension nanodeck-file ".html"))))
  
  (define (save-pict-as-bitmap i p)
    (send (pict->bitmap p
                        'unsmoothed 
                        #:make-bitmap make-screen-bitmap)
          save-file
          (build-path build-folder (format "slide~a.jpg" i))
          'jpeg
          100
          ))

  ; create folder
  (if (not (directory-exists? build-folder))
      (make-directory* build-folder) (void))

  ; save intermediary representation
  (define preamble @string-append{
 #lang slideshow

 ;; Background parameters
 (define background-image (make-parameter #f))
 (define (background-image-pict)
 (define bg (background-image))
 (inset (scale bg (/ 1024 (pict-width bg)) (/ 768 (pict-height bg)))
 (- margin)))

 ;; Slide assembly
 (set-page-numbers-visible! #f)

 (define (add-slide bg-pct pct)
 (refocus (ct-superimpose bg-pct pct) bg-pct))

  
 (current-slide-assembler
 (let ([orig  (current-slide-assembler)])
 (lambda (title sep body)
 (let* ([pct  (if (background-image)
 (background-image-pict)
 (inset (blank 1024 768) (- margin)))]
 [pct  (add-slide pct (orig title sep body))])
 pct))))

 ;; Your slides below
 

 
 })
  (displayln "- saving intermediary representation...")
  (with-output-to-file intermediate-slide-representation-file  #:exists 'replace
    (lambda ()
      (displayln preamble)
      (for/list ([s slides-as-list])
        (if (list? (car s))
            (for/list ([ss s]) (writeln ss)) ;; AAG: Hack to repeat slides for ignite-style talk
            (writeln s)))
      ))
  
  ; Save JPEGS files for comparison
  ;  (displayln "- saving jpegs...")
  ;  (for ([i (in-naturals 1)]
  ;        [p (slides-as-picts)])
  ;    (save-pict-as-bitmap i p))

 
  
  ; save json slides
  (displayln "- saving JS version...")
  (with-output-to-file (build-path build-folder "slides.json") #:exists 'replace
    (lambda () (write-json (picts-as-argb))))

  ; scaffold
  (define nanodeck-module-folder (path-only (resolve-module-path-index
                                             (module-path-index-join 'nanodeck #f))))
  (copy-file (build-path nanodeck-module-folder "scaffold" "index.html") html-file #t)

  (displayln (format "- JS version: ~a" (path->string html-file))))

(provide slides->js)

(define (slides->wasm nanodeck-file slides-as-list w h)
  
  ; auxiliary definitions ...
  (define build-folder (build-path (path-only nanodeck-file) "build-wasm"))
  
  (define intermediate-slide-representation-file
    (path->string (build-path build-folder (file-name-from-path (path-replace-extension nanodeck-file ".rkt")))))
  
  (define (slides-as-picts) (get-slides-as-picts intermediate-slide-representation-file w h #t))
  
  (define (picts-as-argb) (map (lambda (s) (bytes->list (pict->argb-pixels s 'unsmoothed))) (slides-as-picts)))

  (define html-file (build-path build-folder (file-name-from-path (path-replace-extension nanodeck-file ".html"))))
  
  (define (save-pict-as-bitmap i p)
    (send (pict->bitmap p
                        'unsmoothed 
                        #:make-bitmap make-screen-bitmap)
          save-file
          (build-path build-folder (format "slide~a.jpg" i))
          'jpeg
          100
          ))

  ; create folder
  (if (not (directory-exists? build-folder))
      (make-directory* build-folder) (void))

  ; save intermediary representation
  (define preamble @string-append{
 #lang slideshow

 ;; Background parameters
 (define background-image (make-parameter #f))
 (define (background-image-pict)
 (define bg (background-image))
 (inset (scale bg (/ 1024 (pict-width bg)) (/ 768 (pict-height bg)))
 (- margin)))

 ;; Slide assembly
 (set-page-numbers-visible! #f)

 (define (add-slide bg-pct pct)
 (refocus (ct-superimpose bg-pct pct) bg-pct))

  
 (current-slide-assembler
 (let ([orig  (current-slide-assembler)])
 (lambda (title sep body)
 (let* ([pct  (if (background-image)
 (background-image-pict)
 (inset (blank 1024 768) (- margin)))]
 [pct  (add-slide pct (orig title sep body))])
 pct))))

 ;; Your slides below
 

 
 })
  (displayln "- saving intermediary representation...")
  (with-output-to-file intermediate-slide-representation-file  #:exists 'replace
    (lambda ()
      (displayln preamble)
      (for/list ([s slides-as-list])
        (if (list? (car s))
            (for/list ([ss s]) (writeln ss)) ;; AAG: Hack to repeat slides for ignite-style talk
            (writeln s)))
      ))
  
  ; Save JPEGS files for comparison
  ;    (displayln "- saving jpegs...")
  ;    (for ([i (in-naturals 1)]
  ;          [p (slides-as-picts)])
  ;      (save-pict-as-bitmap i p))

 
  
  ; save wat slides
  (displayln "- saving WAT version (takes forever, go make tea)...")
  (define slides-wat (build-path build-folder "slides.wat"))
  (define slides-wasm (build-path build-folder "slides.wasm"))
  (define nanodeck-module-folder (path-only (resolve-module-path-index
                                             (module-path-index-join 'nanodeck #f))))
  (define wat2wasm-path (build-path nanodeck-module-folder "wabt" "wat2wasm.exe"))
  (define total-number-of-memory-pages (/ (* (length slides-as-list) (* 4 (* 1024 768))) (* 64 1024)))
  
  (define slides-as-byte-list
    (map
     (lambda (s) (bytes->list (pict->argb-pixels s 'unsmoothed)))
     (slides-as-picts)))
  
  (define (dump-slides s i)
    (if (not (empty? s))
        (begin
          (displayln (format ";; slide: ~a" i) )
          (displayln
           (format "(data (i32.const ~a) \"~a\")"
                   (* i (length (first s)))
                   (string-join (map 
                                 (lambda (i) (format "\\~a" (~r i #:base 16 #:min-width 2 #:pad-string "0"))) 
                                 (first s)) "")))
          (dump-slides (cdr s) (+ 1 i)))
        (displayln ";; end of slides")))

 
  (with-output-to-file slides-wat #:exists 'replace
    (lambda ()
      (displayln ";; Slides WAT")
      (displayln "(module")
      (displayln (format "(memory (export \"memory\") ~a)" total-number-of-memory-pages))
      (displayln (format "(global (export \"length\") i32 (i32.const ~a))" (length slides-as-list)))
      (dump-slides slides-as-byte-list 0)
      (displayln ")")            
      ))
  
  (define wat2wasm-cmd (format "~a ~a -o ~a" wat2wasm-path slides-wat slides-wasm))
  ;(writeln wat2wasm-cmd)
  (define res (system wat2wasm-cmd))
  (if res
      (displayln "- WASM generation OK")
      (displayln "- WASM generation FAILED"))
  ; scaffold
 
  (copy-file (build-path nanodeck-module-folder "scaffold" "index-wasm.html") html-file #t)

  (displayln (format "Open: ~a" (path->string html-file))))
(provide slides->wasm)
  
  

