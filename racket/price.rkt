#lang racket
(provide (all-defined-out))
; A Struct made of:
; - Integer (class)
; - Integer (quality)
; - ListOfInteger (list-of-multiplier)
(define-struct items-multiplier [class quality list-of-multiplier])

; Multiplier for Common (quality 1) Trade Goods (class 7)
(define common-trade-goods
  (make-items-multiplier 7 1
                         (list 20   ; Trade goods 0
                               20   ; Parts 1
                               20   ; Explosives 2
                               20   ; Devices 3
                               1000 ; Jewelcrafting 4
                               100  ; Cloth 5
                               150  ; Leather 6
                               200  ; Metal & Stone 7
                               20   ; Meat 8
                               150  ; Herb 9
                               250  ; Elemental 10
                               20   ; Other 11
                               300  ; Enchanting 12
                               300  ; Materials 13
                               20   ; Armor Ench. 14
                               20   ; Weapon Ench. 15
                               )))

; A List containing every multiplier
(define price-list
  (list common-trade-goods))

; Integer Integer -> List
; Returns the price list given the class and the quality of the item.
(define (get-price-list class quality)
  (items-multiplier-list-of-multiplier
   (first
    (filter (lambda (i) (and (= (items-multiplier-class i) class)
                           (= (items-multiplier-quality i) quality)))
                           price-list))))

; Integer Integer List -> Integer
; Return the price of the item
(define (get-price subclass ilevel price-list)
  (* (list-ref price-list subclass) ilevel))

; Final price with 1 gold random
(define (final-price class subclass quality ilevel stack)
  (* (+ (random 10000) (get-price subclass ilevel (get-price-list class quality))) stack))