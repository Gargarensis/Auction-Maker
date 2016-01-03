#lang racket
(provide (all-defined-out))
(require "queries.rkt")


(define UNUSED 10)
; A Struct made of:
; - Integer (class) the class of the item
; - ListOfInteger (quality) a list of quality, you can choose multiple quality
; - Integer (maxcount) the maximum number of repetition for a single item
; - ListOfInteger (list-of-multiplier) the multiplier for each subclass
(define-struct items-multiplier [class quality maxcount list-of-multiplier])

; Multiplier for Common (quality 1) Trade Goods (class 7)
(define common-trade-goods
  (make-items-multiplier 7
                         (list 1)
                         4
                         (list UNUSED   ; Trade goods 0
                               UNUSED   ; Parts 1
                               UNUSED   ; Explosives 2
                               UNUSED   ; Devices 3
                               UNUSED     ; Jewelcrafting 4
                               7      ; Cloth 5
                               10      ; Leather 6
                               15      ; Metal & Stone 7
                               UNUSED   ; Meat 8
                               5      ; Herb 9
                               10      ; Elemental 10
                               UNUSED   ; Other 11
                               10      ; Enchanting 12
                               10      ; Materials 13
                               UNUSED   ; Armor Ench. 14
                               UNUSED   ; Weapon Ench. 15
                               )))

; Multiplier for Green (quality 2) Trade Goods (class 7)
(define green-trade-goods
  (make-items-multiplier 7
                         (list 2)
                         4
                         (list UNUSED   ; Trade goods 0
                               UNUSED   ; Parts 1
                               UNUSED   ; Explosives 2
                               UNUSED   ; Devices 3
                               UNUSED     ; Jewelcrafting 4
                               60      ; Cloth 5
                               80      ; Leather 6
                               150     ; Metal & Stone 7
                               UNUSED   ; Meat 8
                               60      ; Herb 9
                               160     ; Elemental 10
                               UNUSED   ; Other 11
                               30      ; Enchanting 12
                               40      ; Materials 13
                               UNUSED   ; Armor Ench. 14
                               UNUSED   ; Weapon Ench. 15
                               )))

; Multiplier for Rare (quality 3) Trade Goods (class 7)
(define rare-trade-goods
  (make-items-multiplier 7
                         (list 3)
                         4
                         (list UNUSED   ; Trade goods 0
                               UNUSED   ; Parts 1
                               UNUSED   ; Explosives 2
                               UNUSED   ; Devices 3
                               UNUSED     ; Jewelcrafting 4
                               30      ; Cloth 5
                               180     ; Leather 6 basically arctic fur
                               170     ; Metal & Stone 7
                               UNUSED   ; Meat 8
                               70      ; Herb 9
                               90     ; Elemental 10
                               UNUSED   ; Other 11
                               100     ; Enchanting 12
                               45      ; Materials 13
                               UNUSED   ; Armor Ench. 14
                               UNUSED   ; Weapon Ench. 15
                               )))

; Multiplier for Epic (quality 4) Trade Goods (class 7)
(define epic-trade-goods
  (make-items-multiplier 7
                         (list 4)
                         4
                         (list UNUSED   ; Trade goods 0
                               UNUSED   ; Parts 1
                               UNUSED   ; Explosives 2
                               UNUSED   ; Devices 3
                               UNUSED     ; Jewelcrafting 4
                               30      ; Cloth 5
                               140     ; Leather 6
                               150     ; Metal & Stone 7
                               UNUSED   ; Meat 8
                               100     ; Herb 9
                               120     ; Elemental 10
                               UNUSED   ; Other 11
                               140     ; Enchanting 12
                               45      ; Materials 13
                               UNUSED   ; Armor Ench. 14
                               UNUSED   ; Weapon Ench. 15
                               )))

; Multiplier for Epic (quality 4) Armors (class 4)
(define epic-armors
  (make-items-multiplier
   4 ; The class field, for example Armor is 4
   
   ; The list of qualities that should be taken in account
   ; You can set multiple qualities like (list 1 2 3 4)
   (list 4)
   
   ; The maximum number of the same item for this class
   ; 4 means that every item can have a maximum of
   ; 4 auctions at the same time
   4
   
   ; This list contains a value for every subclass.
   ; This value will be multiplied for the item level
   ; in order to define the final price for an item.
   ; If you won't use a certain subclass, write UNUSED.
   ; You MUST write every subclass.
   (list UNUSED   ; 0 Miscellaneous
         1000    ; 1 Cloth
         1000    ; 2 Leather 
         1000    ; 3 Mail
         1000    ; 4 Plate
         UNUSED   ; 5 Buckler (OBSOLETE)
         1000    ; 6 Shield
         1000    ; 7 Libram
         1000    ; 8 Idol
         1000    ; 9 Totem
         1000    ; 10 Sigil
         )))

; A list of the default quality values in auctions.
(define default-quality
  (list 1 2 3 4))

; A list of lists: the first element is the ID, the second the price.
; You can add pairs to this list in order to create a specific price for a
; single item.
; This will overwrite the modifier above for that item.
(define fixed-price-list
  (append (list)
          (list '(34055 20000)
                '(34056 30000))))

; A list containing every item that should have only one stack.
; You can add items to this list to force their maximum stack to 1.
; You can use get-items to execute a SELECT query using your conditions.
(define single-stack-list
  (append (list "40248" ;Eternal Might
                )
          (get-items "name LIKE \"%Rod%\"")))

; A list containing every item, use list-of-items or add directly the id.
; You can use the data->list function to execute queries and get multiple ids.
; Otherwise, you can add an entry to the list by writing "entry".
(define total-list
  (flatten
   (foldr append (list)
          (list (data->list 7 
                            (list 5 6 7 9 10 12 13)
                            default-quality 70 80)
                (data->list ; How data->list works:
                 4          ; First, we write the class of the items we want
                 (list 2)   ; Then their subclasses (in a list)
                 (list 4)   ; Their qualities (in a list)
                 0          ; The minimum item level (included)
                 300)))))   ; The maximum item level (included)

; A list containing every forbidden item.
; You can add entries to ban that item from the auction.
(define forbidden-list
  (append(list "17203" ;Sulfuron Ingot (should be very rare)
               "46849" ;Titanium Powder (should be very rare)
               "35626" ;Eternal Mana (lol wtf?)
               "49640" ;Essence or Dust (?)
               "49334" ;Scale of Onyxia 2.0!!!
               )
         (get-items "name LIKE \"%zzold%\"")
         (get-items "name LIKE \"%Rod%\"") ; should be made by a blacksmith
         ))