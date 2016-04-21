#lang racket
(provide (all-defined-out))
(require "config.rkt")
(require "list.rkt")

; Integer Integer List -> Integer
; Return the price of the item
(define (get-price subclass ilevel price-list)
  (local ([define ilvlmod (expt ilevel 3)])
  (* (list-ref price-list subclass)
     (cond [(>= ilvlmod 200) (quotient ilvlmod 200)]
           [else ilvlmod]))))

; Final price with 1 gold random
(define (final-price item class subclass quality ilevel stack)
  (local [(define fixed-price?
            (findf (lambda (i) (= item (first i))) fixed-price-list))]
    (* stack
       (+ (random 10000)
          (if (list? fixed-price?)
              (second fixed-price?)
              (get-price subclass
                         ilevel
                         (get-price-list class
                                         quality
                                         items-multiplier-list-of-multiplier)))))))

; A List containing every multiplier
(define price-list
  (list common-trade-goods
        rare-trade-goods
        green-trade-goods
        epic-trade-goods
        epic-armors))

; Integer Integer -> Integer
; If you want to use every subclass, this function will return their number.
(define (get-all-subclasses class quality)
  (length(get-price-list class quality items-multiplier-list-of-multiplier)))

; Integer Integer -> List
; Returns the price list given the class and the quality of the item.
(define (get-price-list class quality struct-field)
  (struct-field
   (first
    (filter (lambda (i) (and (= (items-multiplier-class i) class)
                             (ormap (lambda (j) (= j quality))
                                    (items-multiplier-quality i))))
            price-list))))

; A list containing every item except the forbidden ones.
(define final-list ; sort?
  (remove* forbidden-list total-list))
