#lang br
(require brag/support)

(define-lex-abbrev digits (:+ (char-set "0123456789")))

(define-lex-abbrev reserved-terms (:or "slide" "with" "background" "color" "text" "footer" "image" "end" "title"
                                       ";" "," "space" "image" "item" "color" "font" "size" "face" "for" "seconds"
                                       "set" "repeat" "times" "-" "p" "¶" "§"))

(define basic-lexer
  (lexer-srcloc
   [(:or "\n" whitespace) (token lexeme #:skip? #t)]
   [(from/stop-before ";" "\n") (token 'COMMENT lexeme)]
   [reserved-terms (token lexeme lexeme)]
   [digits (token 'INTEGER (string->number lexeme))]
   [(:or (:seq (:? digits) "." digits)
         (:seq digits "."))
    (token 'DECIMAL (string->number lexeme))]
   [(:or (from/to "\"" "\"") (from/to "'" "'"))
    (token 'STRING
           (substring lexeme
                      1 (sub1 (string-length lexeme))))]))

(provide basic-lexer)