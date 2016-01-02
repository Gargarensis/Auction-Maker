#lang racket
(provide (all-defined-out))
(require "lists.rkt")

; Integer Integer List -> Integer
; Return the price of the item
(define (get-price subclass ilevel price-list)
  (* (list-ref price-list subclass) ilevel))

; Final price with 1 gold random
(define (final-price item class subclass quality ilevel stack)
  (local [(define fixed-price?
            (findf (lambda (i) (= item (first i))) fixed-price-list))]
  (* stack
     (+
      (random 10000)
      (if (list? fixed-price?)
          (* ilevel (second fixed-price?))
          (get-price subclass
                 ilevel
                 (get-price-list class
                                 quality
                                 items-multiplier-list-of-multiplier)))))))


