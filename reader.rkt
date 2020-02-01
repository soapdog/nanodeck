#lang br/quicklang
(require "parser.rkt")

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port)))
  (define module-datum `(module nanodeck-mod nanodeck/expander
                          (set-slideshow-path path)
                          ,parse-tree))
  (datum->syntax #f module-datum))
(provide read-syntax)

(require brag/support)
(define (make-tokenizer port)
  (define (next-token)
    (define bf-lexer
      (lexer
       [(char-set "><-.,+[]") lexeme]
       [any-char (next-token)]))
    (bf-lexer port))
  next-token) 