#lang racket
(require "price.rkt")
(require "queries.rkt")
(require 2htdp/batch-io)

; final-price class subclass quality ilevel stack

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

(define (get-stack-count item)
  (select-single-world "SELECT stackable FROM item_template WHERE entry = $1;" item))

(define (make-stack item stackable)
  (local [(define list-of-divisors (list 1 2 4))
          (define rnd-number (random (length list-of-divisors)))]
  (if (even? stackable)
      (list-ref list-of-divisors rnd-number)
      stackable)))

(define (make-query-auction item)
  (local [(define guid (make-guid item))
          (define stackable (get-stack-count item))]
    (write-file
     "output.txt"
     (string-append
      "INSERT INTO characters.item_instance (guid, itemEntry, count) VALUES ("
      guid ", "
      item ", "
      (make-stack item stackable) ";\n"
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
      0))))