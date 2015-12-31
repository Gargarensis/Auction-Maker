#lang racket
(require db)
(provide (all-defined-out))

; SQL connection
(define world
  (mysql-connect #:server "2.38.37.207"
                 #:database "world"
                 #:user "root"
                 #:password "mangos"))

(define character
  (mysql-connect #:server "192.168.1.3"
                 #:database "characters"
                 #:user "root"
                 #:password "mangos"))


(define (list-of-items field class subclass quality ilevelmin ilevelmax)
  (map vector->list
       (query-rows
        world
        (string-append "SELECT" field "FROM `item_template` WHERE " 
                       "class = " (number->string class) " AND "
                       "subclass = " (number->string subclass) " AND "
                       "quality = " (number->string quality) " AND "
                       "itemlevel >= " (number->string ilevelmin) " AND "
                       "itemlevel >= " (number->string ilevelmax) ";"))))

(define (select-single-item field cond)
  (query-maybe-value
   world (string-append "SELECT" field "FROM `item_template` WHERE " cond ";")))

(define (select-single-world query)
  (query-maybe-value world query))

(define (select-single-character query)
  (query-maybe-value character query))