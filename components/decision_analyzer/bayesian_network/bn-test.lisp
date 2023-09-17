(load "./util.lisp")
(ql:quickload :hems :silent t)

; observation counts - table from slides
'((2 "a" 1 "b" 0 "c" 1) ; 2 observations of a=1,b=0,c=1
  (1 "a" 0 "b" 0 "c" 1)
  (1 "a" 1 "b" 1 "c" 1 d 1)
  (1 "a" 0 "b" 1 "c" 1 d 0))

; observation counts - sprinkler. TODO: work out total observations
'((X "cloudy" 0)
  (X "cloudy" 1)
  (X "sprinkler" 0 "cloudy" 0)
  )
;               F  T
P(W1 | S0 R0) = 0.0
S(W1 | S0 R1) = 0.9
P(W1 | S1 R0) = 0.9
S(W1 | S1 R1) = 0.99

; that should probably be conditioned on rain, but leaving it in place in case
; the later math uses this version
P(S1 | C0) = 0.5
P(S1 | C1) = 0.1

P(R1 | C0 Z0) = 0.2
P(R1 | C0 Z1) = 0.5
P(R1 | C1 Z0) = 0.8
P(R1 | C1 Z1) = 0.9

P(C1) = 0.5
P(Z1) = 0.2 ; zeus angry

; So to map that to observations:
Consider the wet table. P(W|S1 R0) = 0.9, so we must have at least 10 observations
(we get the number of observations by multiplying both P(false) and P(true) by number of observations
until each is within epsilon of being an integer)
Similarly, P(W | S1 R1) requires an extra 100 observations.
The real number can be any multiple of that: k0 * 110 observations where S1.

Now we go up to the sprinkler table.
P(S | C1) = 0.1, so at 10 * k1 observations there, and 9 * k1 of them have S1.
P(S | C0) = 0.5, so at least 2 * k2 observations, and 1 * k2 of them have S1.

So let the total number of observations of S = N (or rather, k4 * N, if S has parents).
N = k0 * 110 = k1 * 9 + k2 * 1
N = LCM(110, (9 + 1)) = 110 satisfies that: k0 = 1, k1 = N * 110 * 9/(9+1) = 99. k2 = 110 * 1/(9+1) = 11

Suppose that instead N = k0 * 110 = k1 * 14 + k2 * 3, to stress test that.
LCM(110, 14+3) = 1870.
k0 = 110, k1 =  1540, k2 = 330

Rain:
P(R1 | C0 Z0) = 0.2, so 5 observations
P(R1 | C1 Z0) = 0.8, so 5 observations
P(R1 | C0 Z1) = 0.5, so 2 observations
P(R1 | C1 Z1) = 0.7, so 10 observations
LCM(110, 5+5+2+10) = 110

Clouds:
P(C1) = 0.5, so 2 observations
LCM(1870, 110, 2) = 1870

Zeus:
P(Z1) = 0.2, so 5 observations
LCM(1870, 110, 5) = 1870

As far as the code goes, we should be able to do the nodes in any order as long as we memoize,
since everything depends only on its children, and it'll call the function on them to either calculate or retrieve, as needed.

TODO: code will sanity check by writing a bunch of random probability tables and seeing that the resulting probability tables are within epsilon everywhere.

Once we know the number of observations, our best bet is probably starting at the leaves and working up.
We know exactly what number of observations are there, and that in turn will send observations up the tree.
Then go up a node, and *that* node takes the observations it has (which also has info about what the child is),
and distributes them among the parent assignments.

(defun fractional-component (x)
    (- x (ffloor x)))

; Parents is an ordered list of symbols
(create-node (parents prob

))

; Clouds
'(nil
   (nil (0.5 0.5)))

; Zeus
'(nil
   (nil (0.8 0.2)))

; Sprinkler(Clouds)
'(('clouds)
    ((0) (0.5 0.5)
     (1) (0.9 0.1)))

; Rain(Clouds, Zeus)
'(('clouds 'zeus)
    ((0 0) (0.8 0.2)
     (0 1) (0.5 0.5)
     (1 0) (0.2 0.8)
     (1 1) (0.1 0.9)))

; Wet(Rain, Sprinkler)
'(('rain 'sprinkler)
  ((0 0) (1.0 0.0)
   (0 1) (0.1 0.9)
   (1 0) (0.1 0.9)
   (1 1) (0.01 0.99)))

; IN: real number
; OUT: real number, no more than k significant figures after decimal point
; TODO: can floating  point precision issues cause the result to exceed that?
(defun round-to-k-places (n k)
  (let (scale (expt 10 k))
    (pipe n
          (* scale)
          round
          (/ scale))))

; TODO: If the observation counts generated by rationalize are too large, we can either:
; 1) Stop specifying things to so many significant figures
; 2) Use this library, which lets us set max denominator: https://github.com/jesseoff/ratmath/blob/master/ratmath.lisp
; 3) Round off to k digits before calling rationalize. 
(defun min-observations-for-row (probs)
  (loop for p in probs
        maximizing (denominator (rationalize p)))

(defun min-observations-for-node (node)
  (apply #'lcd
         (cons (loop for row in (table-of node)
                     sum (min-observations-for-row row))
               (loop for parent in (parents-of node)
                     collect (min-observations-for-node parent)))))
(memoize 'min-observations-for-node)


(defun ex2 ()
  (let ((bn (hems::compile-program
	      c0 = (hems::percept-node node1 :value "603")
	      c1 = (hems::percept-node node2 :value "602")
	      c2 = (hems::percept-node node3 :value "601")
	      c3 = (hems::percept-node node4 :value "600")
	      c1 -> c0
	      c2 -> c0)))
	;(format t "~%bn:~a~%" bn)
	bn))

    ;;(format t "~%bn:~%~S" (aref (car bn) 3))
    ;(setq last-node (aref (car bn) 3))
    ;(setq keep (rule-based-cpd-dependent-id last-node))
    ;(setq remove (remove keep
;		 (hems::hash-keys-to-list (rule-based-cpd-identifiers last-node))
;		 :test #'equal))
    ;(format t "~%keep:~%~S~%remove:~%~S" keep remove)
    ;(hems::factor-operation last-node (list keep) remove #'+)
(defvar bn (ex2))
;(hems::rule-based-cpd-rules (aref (car hems::bn) 0))

; fetches cpd table for each node
(if nil
    (print
        (loop for idx from 0 to (- (length (car bn)) 1)
              collect (print (hems::rule-based-cpd-rules (aref (car bn) idx)))))

    ; fetch conditions element of one of the cpd rules
    (hems::rule-conditions (aref (hems::rule-based-cpd-rules (aref (car bn) 0)) 0))
)
; "The array of cpds in the bn are topologically sorted, such that the parent nodes appear before their respective children"

; OUTPUT: Rules-based CPD struct for `node-id` in `bn`
(defun get-cpd (bn node-id)
  (aref (car bn) node-id))

; INPUT:
; bn is a result of `compile-program`
; node-id is an index into its node array
;
; OUTPUT:
; A list of the index of each parent of `node-id`
(defun get-parent-ids (bn node-id)
    (let* ((cpd (get-cpd bn node-id))
           (name (hems::rule-based-cpd-dependent-id cpd))
           (identifiers (hems::rule-based-cpd-identifiers cpd)))
      (loop for key being the hash-keys of identifiers
            when (not (equal key name))
            collect (gethash key identifiers))))

; OUT: list of values `node-id` can take?
(defun possible-values (bn node-id)
  (pipe bn
        (get-cpd node-id)
        (hems::rule-based-cpd-var-values)
        (gethash 0 placeholder)))

; :DEPENDENT-ID #1="NODE1496"
; :IDENTIFIERS #H((#1# . 0) (#2="NODE2497" . 1) (#3="NODE3498" . 2))
; :VARS #H((0 . #4#) (1 . "NODE2") (2 . "NODE3"))
; :VAR-VALUES #H((0 . (0 1)) (1 . (0 1)) (2 . (0 1)))
; :RULES #(#S(HEMS::RULE
;                :ID "RULE-506"
;                :CONDITIONS #H((#1# . 1) (#2# . 1) (#3# . 1))
;                :PROBABILITY 1
;                :BLOCK #H((0 . 0))
;                :CERTAIN-BLOCK #H((0 . 0))
;                :AVOID-LIST NIL
;                :REDUNDANCIES NIL
;                :COUNT 1)
;             #S(HEMS::RULE
;                :ID "RULE-507"
;                :CONDITIONS #H((#1# . 0) (#2# . 1) (#3# . 1))
;                :PROBABILITY 0
;                :BLOCK #H((1 . 1))
;                :CERTAIN-BLOCK #H((1 . 1))
;                :AVOID-LIST NIL
;                :REDUNDANCIES NIL
;                :COUNT 1))

; TODO: I want:
; * hems::rule -> list of all parent assignments that match it
; * parent assignment -> marginal probability
; * (outer function that calls hems:rule for each rule, and then assigns 0 probability mass to anything that isn't covered by one of the rules.)
; PITFALL: what happens if a rule doesn't have an entry for the current node (indicating a uniform distribution given any matching set of parent assignments)?

;; Exactly like maphash, except
;; 1) it takes the hashtable as its first argument so as to play well with pipe
;; 2) it *actually returns the goddamn result*
;(defun hash-map (hash-table fnc)
;  (loop for key being the hash-keys of hash-table
;        collect (fnc key (gethash hash-table key))))

;; Returns a list of all (k,v) pairs (as cons cells) for which (fnc k v) holds
;(defun hash-filter (hash-table fnc)
;  (loop for key being the hash-keys of hash-table
;        when (fnc key (gethash hash-table key))
;        collect (cons key val)))

; INPUT:
; rule-id indexes (aref bn node-id):RULES
;
; OUTPUT:
; list of hash tables `h` s.t. each h maps all parents to a value
; The list contains all such assignments that are consistent with the rule
;
; psuedocode:
;append_possible_assignments(assignments, remaining-parents) {
;    ; assignments starts out as '()
;    parent = (car remaining-parents)
;    if nil == remaining-parents {
;        (setq assignments (cons result assignments)) ; result lives one scope up
;    }
;    else if (parent assigned to in rule) {
;       (append_possible_assignments
;          (cons (parent . val) assignments)
;          (cdr remaining-parents))
;    }
;    else {
;        for (val in (possible-values parent)) {
;            (append_possible_assignments
;              (append-hash assignments, (parent, val))
;              (cdr remaining-parents))
;        }
;    }
;}

(defun in-hash (hash-table val)
  (nth-value 1 (gethash val hash-table)))

; IN: bayesian net and a node index
; OUT: The NODE12345-style name
(defun node-id-to-name (bn node-id)
  (pipe bn
        (get-cpd node-id)
        hems::rule-based-cpd-dependent-id))

(defun assignments-matching-rule (bn node-id rule-id)
    (let* ((cpd (get-cpd bn node-id))
           (rule (pipe cpd
                       hems::rule-based-cpd-rules
                       (aref rule-id)))
           (conditions (hems::rule-conditions rule))
           (result '()))
      (debug-out "RULE: ~a" rule)
      (labels
        ; Scans through all possible assignments to parents that are consistent
        ; with `rule`. Appends to `result` as list of (parent . val).
        ((aux (assignments remaining-parents)
              ;(debug-out "~%## (aux ~a ~a)" assignments remaining-parents)
              (let* ((parent (car remaining-parents))
                     (parent-name (and parent (node-id-to-name bn parent))))
                ;(debug-out "TEST0: conditions = ~a, parent = ~a" conditions parent)
                (cond
                  ; Leaf. Append to result
                  ((null remaining-parents)
                   ;(debug-out "NEW ENTRY: ~a" assignments)
                   (setf result (cons assignments result)))

                  ; Rule provides assignment for this parent. Single recursion
                  ((in-hash conditions parent-name)
                   ; TODO: using alexandria's ensure-gethash might simplify the line where we set parent-name
                   (aux (cons (cons parent (gethash parent-name conditions))
                              assignments)
                        (cdr remaining-parents)))
                  
                  ; Parent unassigned. Recurse for all possible assignments
                  (t 
                    (loop for val in (possible-values bn parent)
                          do (aux (cons (cons parent val)
                                        assignments)
                                  (cdr remaining-parents))))))))

        (aux nil (get-parent-ids bn node-id)))
        result))

;(debug-out (get-cpd bn 3))
(debug-out "# BN~%~a~%~%" bn)
(debug-out "edges: ~a" (cdr bn))
(debug-out (get-parent-ids bn 3))
(debug-out "possible-values test: ~a" (possible-values bn 3))
(debug-out "RESULTS (node 3, rule 0)")
(defvar result (assignments-matching-rule bn 3 0))
(loop for a in result
      do (debug-out "ENTRY: ~a" a))

(setf result (assignments-matching-rule bn 3 1))
(debug-out "RESULTS (node 3, rule 1)")
; TODO: Only looking at parents when checking if match, but *returns* entries that
; include assignments to the current node, even if non-matching.
(loop for a in result
      do (debug-out "ENTRY: ~a" a))
(exit)

; TODO: Need to have it print the resulting equation when I'm done, in such a way that I
; can write tests

;(print "# FOO")
;(print (get-parent-ids bn 3))

(defun ex1 ()
(let (bn1 bn2 bn3 bn4 bn5 q2)
    ;(setq q1 (compile-program
	;       c1 = (percept-node rank :value "MILITARY" :kb-concept-id "CNPT-4")
	;       c2 = (percept-node sex :value "M" :kb-concept-id "CNPT-3")))
    
    (setq q2 (compile-program
	       c1 = (percept-node rank :value "MILITARY" :kb-concept-id "CNPT-4")
	       c2 = (percept-node hrpmin :value "120" :kb-concept-id "CNPT-5")
	       c3 = (percept-node sex :value "M" :kb-concept-id "CNPT-3")))
    
    (setq bn1 (compile-program
		c1 = (percept-node casualty :value "CASUALTY-A" :kb-concept-id "CNPT-1")
		c2 = (percept-node age :value "22" :kb-concept-id "CNPT-2")
		c3 = (percept-node sex :value "M" :kb-concept-id "CNPT-3")
		c4 = (percept-node rank :value "MILITARY" :kb-concept-id "CNPT-4")
		c5 = (percept-node hrpmin :value "145" :kb-concept-id "CNPT-5")
		c6 = (percept-node mmHG :value "60" :kb-concept-id "CNPT-6")
		c7 = (percept-node Spo2 :value "85" :kb-concept-id "CNPT-7")
		c8 = (percept-node RR :value "40" :kb-concept-id "CNPT-8")
		c9 = (percept-node pain :value "0" :kb-concept-id "CNPT-9")
		c10 = (relation-node IED_injury :value "T" :kb-concept-id "CNPT-10")
		c11 = (relation-node 2nd_degree_burn :value "T" :kb-concept-id "CNPT-11")
		c12 = (relation-node 3rd_degree_burn :value "T" :kb-concept-id "CNPT-12")
		c13 = (relation-node unconscious :value "T" :kb-concept-id "CNPT-13")
		c1 -> c2
		c1 -> c3
		c1 -> c4
		c1 -> c5
		c1 -> c6
		c1 -> c7
		c1 -> c8
		c1 -> c9
		c10 -> c1
		c11 -> c1
		c12 -> c1
		c13 -> c1))

    (setq bn2 (compile-program
		c1 = (percept-node casualty :value "CASUALTY-B" :kb-concept-id "CNPT-1")
		c2 = (percept-node age :value "25" :kb-concept-id "CNPT-2")
		c3 = (percept-node sex :value "M" :kb-concept-id "CNPT-3")
		c4 = (percept-node rank :value "MILITARY" :kb-concept-id "CNPT-4")
		c5 = (percept-node hrpmin :value "120" :kb-concept-id "CNPT-5")
		c6 = (percept-node mmHG :value "80" :kb-concept-id "CNPT-6")
		c7 = (percept-node Spo2 :value "98" :kb-concept-id "CNPT-7")
		c8 = (percept-node RR :value "18" :kb-concept-id "CNPT-8")
		c9 = (percept-node pain :value "6" :kb-concept-id "CNPT-9")
		c10 = (relation-node IED_injury :value "T" :kb-concept-id "CNPT-10")
		c11 = (relation-node 2nd_degree_burn :value "T" :kb-concept-id "CNPT-11")
		c12 = (relation-node 3rd_degree_burn :value "T" :kb-concept-id "CNPT-12")
		c1 -> c2
		c1 -> c3
		c1 -> c4
		c1 -> c5
		c1 -> c6
		c1 -> c7
		c1 -> c8
		c1 -> c9
		c10 -> c1
		c11 -> c1
		c12 -> c1))
    
    (setq bn3 (compile-program
		c1 = (percept-node casualty :value "CASUALTY-D" :kb-concept-id "CNPT-1")
		c2 = (percept-node age :value "40" :kb-concept-id "CNPT-2")
		c3 = (percept-node sex :value "M" :kb-concept-id "CNPT-3")
		c4 = (percept-node rank :value "VIP" :kb-concept-id "CNPT-4")
		c5 = (percept-node hrpmin :value "105" :kb-concept-id "CNPT-5")
		c6 = (percept-node mmHG :value "120" :kb-concept-id "CNPT-6")
		c7 = (percept-node Spo2 :value "99" :kb-concept-id "CNPT-7")
		c8 = (percept-node RR :value "15" :kb-concept-id "CNPT-8")
		c9 = (percept-node pain :value "2" :kb-concept-id "CNPT-9")
		c10 = (relation-node IED_injury :value "T" :kb-concept-id "CNPT-10")
		c11 = (relation-node suborbital_ecchymosis :value "T" :kb-concept-id "CNPT-13")
		c12 = (relation-node traumatic_hyphema :value "T" :kb-concept-id "CNPT-14")
		c1 -> c2
		c1 -> c3
		c1 -> c4
		c1 -> c5
		c1 -> c6
		c1 -> c7
		c1 -> c8
		c1 -> c9
		c10 -> c1
		c11 -> c1
		c12 -> c1))
    
    (setq bn4 (compile-program
		c1 = (percept-node casualty :value "CASUALTY-E" :kb-concept-id "CNPT-1")
		c2 = (percept-node age :value "26" :kb-concept-id "CNPT-2")
		c3 = (percept-node sex :value "M" :kb-concept-id "CNPT-3")
		c4 = (percept-node rank :value "MILITARY" :kb-concept-id "CNPT-4")
		c5 = (percept-node hrpmin :value "120" :kb-concept-id "CNPT-5")
		c6 = (percept-node mmHG :value "100" :kb-concept-id "CNPT-6")
		c7 = (percept-node Spo2 :value "95" :kb-concept-id "CNPT-7")
		c8 = (percept-node RR :value "15" :kb-concept-id "CNPT-8")
		c9 = (percept-node pain :value "10" :kb-concept-id "CNPT-9")
		c10 = (relation-node IED_injury :value "T" :kb-concept-id "CNPT-10")
		c1 -> c2
		c1 -> c3
		c1 -> c4
		c1 -> c5
		c1 -> c6
		c1 -> c7
		c1 -> c8
		c1 -> c9
		c10 -> c1))
    
    (setq bn5 (compile-program
		c1 = (percept-node casualty :value "CASUALTY-F" :kb-concept-id "CNPT-1")
		c2 = (percept-node age :value "12" :kb-concept-id "CNPT-2")
		c3 = (percept-node sex :value "M" :kb-concept-id "CNPT-3")
		c4 = (percept-node rank :value "CIVILIAN" :kb-concept-id "CNPT-4")
		c5 = (percept-node hrpmin :value "120" :kb-concept-id "CNPT-5")
		c6 = (percept-node mmHG :value "30" :kb-concept-id "CNPT-6")
		c7 = (percept-node Spo2 :value "99" :kb-concept-id "CNPT-7")
		c8 = (percept-node RR :value "25" :kb-concept-id "CNPT-8")
		c9 = (percept-node pain :value "3" :kb-concept-id "CNPT-9")
		c10 = (relation-node shrapnel_injury :value "T" :kb-concept-id "CNPT-15")
		c11 = (relation-node difficult_breathing :value "T" :kb-concept-id "CNPT-16")
		c1 -> c2
		c1 -> c3
		c1 -> c4
		c1 -> c5
		c1 -> c6
		c1 -> c7
		c1 -> c8
		c1 -> c9
		c10 -> c1
		c11 -> c1))

    ;; insert into event memory
    (map nil #'(lambda (bn)
		 (push-to-ep-buffer :state bn :insertp t))
	 (list bn1 bn2 bn3 bn4 bn5))

    ;; remember from retrieval cue
    (multiple-value-bind (recollection eme)
	(remember (list (car eltm*)) (list q2) '+  1 t)
      (declare (ignore eme))
      (let (singletons)
	(setq singletons (mapcan #'(lambda (cpd)
				     (when (rule-based-cpd-singleton-p cpd)
				       (list cpd)))
				 recollection))
	(loop
	  with spread
	  for cpd in singletons
	  do
	     (setq spread (- 1 (compute-cpd-concentration cpd)))
	     (format t "~%~%singleton:~%~S~%spread: ~d" cpd spread)
	  collect spread into spreads
	   finally
	     (format t "~%mean spreads: ~d~%stdev: ~d" (mean spreads) (stdev spreads))
	     ;;(return (values singletons (mean spreads) (stdev spreads)))
	  )))
    ;;(eltm-to-pdf)
    )
)

