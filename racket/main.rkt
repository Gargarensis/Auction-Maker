#lang racket
(require "functions.rkt")
(require "queries.rkt")
(require "lists.rkt")
(require db)

; The output file.
(define out (open-output-file "./output.sql" #:exists 'append))

; Not the scheme way, but i used some variables to avoid repetitions of queries
(define ID -1)
(define GUID -1)

; Given the entry, generate an ID for the item.
(define (make-id item)
  (local [(define maxid
            (select-single-character "SELECT MAX(id) FROM auctionhouse;"))]
    (if (= ID -1)
        (set! ID (if (sql-null? maxid)
                     1
                     (add1 maxid)))
        (set! ID (add1 ID)))
    ID))

; Given the entry, generate a GUID for the item.
(define (make-guid item)
  (local [(define maxguid
            (select-single-character "SELECT MAX(guid) FROM item_instance;"))]
    (if (= GUID -1)
        (set! GUID (if (sql-null? maxguid)
                       1
                       (add1 maxguid)))
        (set! GUID (add1 GUID)))
    GUID))

; Integer Integer item-data -> Integer
; Given the entry, stack and data generate the Price for the item.
(define (make-price item stack itemdata)
  (final-price item
               (item-data-class itemdata)
               (item-data-subclass itemdata)
               (item-data-quality itemdata)
               (item-data-itemlevel itemdata)
               stack))

; Generate the duration of the auction randomly.
(define make-time
  (local [(define time (random 2))]
    (cond [(= time 0) (+ (current-seconds) (* 12 60 60))]
          [(= time 1) (+ (current-seconds) (* 24 60 60))]
          [(= time 2) (+ (current-seconds) (* 48 60 60))])))

; Generate the bid price for the auction.
(define (make-bid-price price)
  (quotient price 2)) ;temp

; Integer -> Integer
; Given the entry, return the maximum number of stack for the item
(define (get-stack-count item)
  (select-single-world
   (string-append "SELECT stackable FROM item_template WHERE entry = "
                  (number->string item) ";")))

; Interger Integer -> Integer
; Given the entry and the maximum number of stacks, generate a random number.
(define (make-stack item stackable)
  (local [(define rnd (random 5))
          (define single-stack-item?
            (string?(findf (lambda (i) (string=? (number->string item) i))
                           single-stack-list)))]
    (if (or single-stack-item?
            (= 1 (get-stack-count item)))
        1
        (cond [(= rnd 0) 1]
              [(= rnd 1) 5]
              [(= rnd 2) 10]
              [(= rnd 3) 15]
              [(= rnd 4) 20]))))
;  (local [(define list-of-divisors (list 1 2))
;          (define rnd-number (random (length list-of-divisors)))]
;  (if (even? stackable)
;      (quotient stackable (list-ref list-of-divisors rnd-number))
;      stackable)))

; Integer -> String (Query)
; Given the entry for an item, generate the query for its auction.
(define (make-query-auction item)
  (local [(define guid (make-guid item))
          (define i-data (get-item-data item))
          (define stack (make-stack item (item-data-stackable i-data)))
          (define price (make-price item stack i-data))]
    (string-append
     "INSERT INTO characters.item_instance
(guid, itemEntry, count, enchantments) VALUES ("
     (number->string guid) ", "
     (number->string item) ", "
     (number->string stack) ", "
     "\"0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0\");"
     "\nINSERT INTO characters.auctionhouse (id, houseid, itemguid, itemowner,
 buyoutprice, time, buyguid, lastbid, startbid, deposit) VALUES ("
     (number->string (make-id item)) ", "
     "7, " ;houseid 7 = neutral gadgetzan
     (number->string guid) ", "
     "0, "
     (number->string price) ", "
     (number->string make-time) ", "
     "0, "
     "0, "
     (number->string (make-bid-price price)) ", "
     "0);\n")))

; Integer -> Strings (Queries)
; Given the entry for the item, generate multiple auction queries.
(define (make-result entry)
  (local [(define i-data (get-item-data entry))
          (define count (random
                         (add1(get-price-list
                               (item-data-class i-data)
                               (item-data-quality i-data)
                               items-multiplier-maxcount))))]
    (for/list ([i count])(make-query-auction entry))))

; output
(for-each
 (lambda (result) (display (foldr string-append "" result) out))
 (map make-result
      (map
       (lambda (i) (string->number i))
       final-list
       )))

(close-output-port out)