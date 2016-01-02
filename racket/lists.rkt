#lang racket
(provide (all-defined-out))
(require "queries.rkt")

; A Struct made of:
; - Integer (class) the class of the item
; - Integer (maxcount) the maximum number of repetition for a single item
; - ListOfInteger (quality) a list of quality, you can choose multiple quality
; - ListOfInteger (list-of-multiplier) the multiplier for each subclass
(define-struct items-multiplier [class quality maxcount list-of-multiplier])

; Multiplier for Common (quality 1) Trade Goods (class 7)
(define common-trade-goods
  (make-items-multiplier 7 (list 1) 4
                         (list 20   ; Trade goods 0
                               20   ; Parts 1
                               20   ; Explosives 2
                               20   ; Devices 3
                               1000 ; Jewelcrafting 4
                               150  ; Cloth 5
                               450  ; Leather 6
                               800  ; Metal & Stone 7
                               20   ; Meat 8
                               350  ; Herb 9
                               400  ; Elemental 10
                               20   ; Other 11
                               300  ; Enchanting 12
                               300  ; Materials 13
                               20   ; Armor Ench. 14
                               20   ; Weapon Ench. 15
                               )))

; Multiplier for Green (quality 2) Trade Goods (class 7)
(define green-trade-goods
  (make-items-multiplier 7 (list 2) 4
                         (list 20   ; Trade goods 0
                               20   ; Parts 1
                               20   ; Explosives 2
                               20   ; Devices 3
                               2000 ; Jewelcrafting 4
                               600  ; Cloth 5
                               800  ; Leather 6
                               1500  ; Metal & Stone 7
                               20   ; Meat 8
                               600  ; Herb 9
                               1600  ; Elemental 10
                               20   ; Other 11
                               300  ; Enchanting 12
                               400  ; Materials 13
                               20   ; Armor Ench. 14
                               20   ; Weapon Ench. 15
                               )))

; Multiplier for Rare (quality 3) Trade Goods (class 7)
(define rare-trade-goods
  (make-items-multiplier 7 (list 3) 4
                         (list 20   ; Trade goods 0
                               20   ; Parts 1
                               20   ; Explosives 2
                               20   ; Devices 3
                               3000 ; Jewelcrafting 4
                               300  ; Cloth 5
                               1800  ; Leather 6 basically arctic fur
                               1700  ; Metal & Stone 7
                               20   ; Meat 8
                               700  ; Herb 9
                               900  ; Elemental 10
                               20   ; Other 11
                               1000  ; Enchanting 12
                               450  ; Materials 13
                               20   ; Armor Ench. 14
                               20   ; Weapon Ench. 15
                               )))

; Multiplier for Epic (quality 4) Trade Goods (class 7)
(define epic-trade-goods
  (make-items-multiplier 7 (list 4) 4
                         (list 20   ; Trade goods 0
                               20   ; Parts 1
                               20   ; Explosives 2
                               20   ; Devices 3
                               4000 ; Jewelcrafting 4
                               300  ; Cloth 5
                               1400  ; Leather 6
                               1500  ; Metal & Stone 7
                               20   ; Meat 8
                               1000  ; Herb 9
                               1400  ; Elemental 10
                               20   ; Other 11
                               2000  ; Enchanting 12
                               450  ; Materials 13
                               20   ; Armor Ench. 14
                               20   ; Weapon Ench. 15
                               )))

; A List containing every multiplier
(define price-list
  (list common-trade-goods
        rare-trade-goods
        green-trade-goods
        epic-trade-goods))

; A list of the default quality values in auctions.
(define standard-quality-common-epic
  (list 1 2 3 4))

; Integer Integer -> List
; Returns the price list given the class and the quality of the item.
(define (get-price-list class quality struct-field)
  (struct-field
   (first
    (filter (lambda (i) (and (= (items-multiplier-class i) class)
                             (ormap (lambda (j) (= j quality))
                                    (items-multiplier-quality i))))
            price-list))))

; Integer Integer -> Integer
; If you want to use every subclass, this function will return their number.
(define (get-all-subclasses class quality)
  (length(get-price-list class quality items-multiplier-list-of-multiplier)))

; A list of lists: the first element is the ID, the second the multiplier.
(define fixed-price-list
  (append (list)
   (list '(34055 200)
        '(34056 300))))

; A list containing every item that should have only one stack.
(define single-stack-list
  (append (list "40248" ;Eternal Might
                )
          (get-items "name LIKE \"%Rod%\"")))
          
  

; A list containing every item, use list-of-items or add directly the id.
(define total-list
  (flatten
   (foldr append '()
          (list (data->list 7 ;(get-all-subclasses 7 1)
                            (list 4 5 6 7 9 10 12 13)
                            standard-quality-common-epic 70 80)))))

(define forbidden-list
  (append(list "17203" ;Sulfuron Ingot
               "46849" ;Titanium Powder
               "35626" ;Eternal Mana (lol wtf?)
               "49640" ;Essence or Dust (?)
               "49334" ;Scale of Onyxia 2.0!!!
               )
         (get-items "name LIKE \"%zzold%\"")))

; A list containing every item except the forbidden ones.
(define final-list ; sort?
  (remove* forbidden-list total-list))