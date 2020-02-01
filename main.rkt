#lang br/quicklang
(require "parser.rkt" "tokenizer.rkt")

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port path)))
 
  (strip-bindings
   #`(module nanodeck-mod nanodeck/expander
       #,path #,parse-tree)))


(module+ reader
  (provide read-syntax))
