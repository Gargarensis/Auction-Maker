#lang racket
(require "price.rkt")
(require "queries.rkt")

; final-price class subclass quality ilevel da moltiplicare per le stack

; That's not the scheme way, but here are some variables to avoid repetitions of queries
(define ID -1)
(define GUID -1)

(define make-id
  (if (= ID -1)
      (begin
        (set! ID (add1 (select-single-character "SELECT MAX(id) FROM auctionhouse;")))
        ID)
      (add1 ID)))

(define (make-guid item)
  (if (= GUID -1)
      (begin
        (set! GUID (add1 (select-single-character "SELECT MAX(guid) FROM item_instance;")))
        GUID)
      (add1 GUID)))

(define (make-price item)
  ...)

(define make-time
  (local [(define time (random 2))]
    (cond [(= time 0) (+ (current-seconds) (* 12 60 60))]
          [(= time 0) (+ (current-seconds) (* 24 60 60))]
          [(= time 0) (+ (current-seconds) (* 48 60 60))])))

(define (make-bid-price item)
  ...)

(define (make-stack item)
  ...)

(define (make-query-auction item)
  (local [(define guid (make-guid item))]
  (string-append
   "INSERT INTO characters.item_instance (guid, itemEntry, count) VALUES ("
   guid ", "
   item ", "
   (make-stack item) ";\n"
   "INSERT INTO characters.auctionhouse (id, houseid, itemguid, itemowner, buyoutprice, time, buyguid, lastbid, startbid, deposit) VALUES"
   make-id
   7 ;houseid
   guid
   0
   (make-price item)
   make-time
   0
   0
   (make-bid-price item)
   0)))