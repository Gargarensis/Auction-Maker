#lang racket
(require db)
(provide (all-defined-out))

(require "config.rkt")

; Create a list of item's entry given some conditions.
(define (list-of-items class subclass quality ilevelmin ilevelmax)
  (map vector->list
       (query-rows
        world
        (string-append "SELECT CAST(entry AS CHAR(20))"
                       " FROM item_template WHERE " 
                       "class = " (number->string class) " AND "
                       "subclass = " (number->string subclass) " AND "
                       "quality = " (number->string quality) " AND "
                       "itemlevel >= " (number->string ilevelmin) " AND "
                       "itemlevel <= " (number->string ilevelmax) " AND "
                       "(NOT bonding IN (1, 4, 5));"))))

; A Struct made of:
; - Integer (class)
; - Integer (subclass)
; - Integer (quality)
; - Integer (itemlevel)
; - Integer (stackable)
(define-struct item-data [class subclass quality itemlevel stackable])

; Integer ->  item-data struct
; Given an entry, return the item data.
(define (get-item-data entry)
  (local [(define data
            (vector->list
             (query-row
              world
              (string-append
               "SELECT class, subclass, quality, itemlevel, stackable "
               "FROM item_template WHERE entry = "
               (number->string entry) ";"))))]
    (make-item-data (first data)
                    (second data)
                    (third data)
                    (fourth data)
                    (fifth data))))

; Integers -> List
; Create a big list of items given some conditions
(define (data->list class subclass quality ilvlmin ilvlmax)
  (cond [(list? subclass)
         (map (lambda (q)
                (map (lambda (s)
                       (list-of-items class s q ilvlmin ilvlmax)) subclass))
              quality)]
        [(number? subclass)
         (for/list
             ([i subclass])
           (map (lambda (q)
                  (list-of-items class i q ilvlmin ilvlmax)) quality))]))

; Create a list using the result of the query.
(define (get-items conditions)
  (flatten(map vector->list
               (query-rows
                world
                (string-append "SELECT CAST(entry AS CHAR(20))"
                               " FROM item_template WHERE " conditions ";")))))

; Execute a query on the 'world' database.
(define (select-single-world query)
  (query-maybe-value world query))

; Execute a query on the 'characters' database.
(define (select-single-character query)
  (query-maybe-value character query))

