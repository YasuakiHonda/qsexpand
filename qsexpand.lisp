;; qsexpand.lisp : maxima extension of fast product() expander
;; Copyright (C) 2016  Yasuaki Honda (Yasuaki dot Honda at gmail dot com)
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

;; How to use
;; qsexpand() expands the infinate product formula specified in the
;; first argument up to the maximum degree specified in the second
;; argument. The product formula in the first argument must be an
;; univariate polynomial of a variable 'q'. The index variable of
;; the infinite product must be 'n'. The infinite product may be
;; of the form q*product(..., n,1,inf) or product(..., n,1,inf).
;;
;; There is no checking of syntax of the first argument.
;;
;; Example
;; load("qsexpand.lisp");
;; powerdisp:true;
;; qsexpand(q*product((1-q^n)^24,n,1,inf),10);
;; -> q-24*q^2+252*q^3-1472*q^4+4830*q^5-6048*q^6-16744*q^7+84480*q^8-113643*q^9
;;
;; qsexpand(q*product((1-q^n)*(1-q^(23*n)),n,1,inf),120);
;; -> q-q^2-q^3+q^6+q^8-q^13-q^16+q^23-q^24+q^25+q^26+q^27-q^29-q^31+q^39-q^41
;;     -q^46-q^47+q^48+q^49-q^50-q^54+q^58+2*q^59+q^62+q^64-q^69-q^71-q^73
;;     -q^75-q^78-q^81+q^82+q^87+q^93+q^94-q^98+2*q^101-q^104-2*q^118

(defmvar $qsexpand_coeff_array nil)

;;; matchdeclare(exp1,true);
(mfuncall '$matchdeclare '$exp1 '$true)
;;; defmatch(qsexpand_internal_rule1,'product(exp1,n,1,inf));
(mfuncall '$defmatch '$p1 '((%PRODUCT) $EXP1 $N 1 $INF))
;;; termlist(polyexp):=if op(polyexp)="+" then args(polyexp) else [polyexp];
(defun termlist (polyexp) (if (equal ($op polyexp) "+") ($args polyexp) `((mlist) ,polyexp)))

(defun $qsexpand (prodexp maxdeg)
  (let (startq pat exp1 deglist coeflist pairlist initlist)
    (if (equal ($op prodexp) "*")
        (progn
          (if (equal ($first prodexp) '$Q) 
              (progn (setq startq t) (setq prodexp ($second prodexp)))
            (setq startq nil))
          ))
    (if (equal (setq pat (mfuncall '$p1 prodexp)) nil)
        prodexp
      (progn
        (setq exp1 (termlist ($expand ($second ($first pat)))))
        (setq deglist (mfuncall '$map '((LAMBDA SIMP) ((MLIST) $TERM) (($HIPOW) $TERM $Q)) exp1))
        (setq coeflist (mfuncall '$map '((LAMBDA SIMP) ((MLIST) $TERM $deg) (($coeff) $TERM $Q $deg)) exp1 deglist))
        (setq pairlist (mfuncall '$map '((LAMBDA SIMP) ((MLIST) $deg $coeff) ((MLIST) $deg $coeff)) deglist coeflist))
        (let ((qpoly) (apoly))
          (setq apoly (initAP (make-instance 'arrayPolynomial) maxdeg))
          (if startq (init-to-q apoly) (init-to-one apoly))
          (dotimes (i maxdeg)
            (setq initlist (mapcar #'cdr (cdr (mfuncall '$ev pairlist `((msetq) $n ,(1+ i))))))
            (setq qpoly (make-instance 'qunitPolynomial))
            (setf (coeffs qpoly) initlist)
            (setq apoly (prod apoly qpoly)))
	  (setq $qsexpand_coeff_array (coeffs apoly))
          (to-maxima-poly apoly))))))
        

(defclass arrayPolynomial () ((coeffarray :initform nil :accessor coeffs)
                              (degree :initform 0 :accessor degree)))

(defmethod initAP ((x arrayPolynomial) (n integer))
  (setf (coeffs x) (make-array (list n) :initial-element 0))
  (setf (degree x) 0)
  x)

(defmethod inc-coeff ((x arrayPolynomial) (d integer) (c integer)) ;; degree coeff
  (incf (aref (coeffs x) d) c)
  (if (< (degree x) d) (setf (degree x) d)))

(defmethod sizeof ((x arrayPolynomial)) (length (coeffs x)))

(defmethod init-to-one ((x arrayPolynomial))
  (setf (aref (coeffs x) 0) 1)
  (setf (degree x) 0))

(defmethod init-to-q ((x arrayPolynomial))
  (setf (aref (coeffs x) 1) 1)
  (setf (degree x) 1))

(defmethod to-maxima-poly ((x arrayPolynomial))
  (let ((coeffarray (coeffs x))
        (maxdeg (degree x))
        (respoly 0))
    (dotimes (d (1+ maxdeg))
      (setq respoly (mfuncall "+" respoly `((mtimes) ,(aref coeffarray d) ((mexpt) $q ,d)))))
    respoly))

;;; coefflist is an assoc list of degree and its coeff ((d1 . c1) (d2 . c2))
(defclass qunitPolynomial () ((coefflist :initform nil :accessor coeffs)))

(defmethod sizeof ((x qunitPolynomial)) (length (coeffs x))) 
(defmethod degree ((x qunitPolynomial)) (apply #'max (mapcar #'car (coeffs x))))
(defmethod init-q-poly ((x qunitPolynomial) (initlist list))
  (setf (coeffs x) initlist))

(defmethod prod ((x arrayPolynomial) (y qunitPolynomial))
  ;; respoly = x * y
  (let* ((respoly (initAP (make-instance 'arrayPolynomial) (sizeof x)))
         (rsize (sizeof respoly))
         (xdegmax (degree x))
         (xcoeffs (coeffs x))
         (ycoeffs (coeffs y)))
    (dolist (ycar ycoeffs)
      (let ((ycarcoeff (cadr ycar))
            (ycardeg (car ycar)))
        (dotimes (i (1+ xdegmax))
          (if (>= (+ ycardeg i) rsize) (return)) ;; break dotimes
          (inc-coeff respoly (+ ycardeg i) (* ycarcoeff (aref xcoeffs i))))
        ))
    respoly))

;;; test code
#|
(setq a (initAP (make-instance 'arrayPolynomial) 100))
(init-to-q a)
(setq b (make-instance 'qunitPolynomial))

(defun autoTerm (n) (setf (coeffs b) `((0 1) (,n -1) (,(* 23 n) -1) (,(* 24 n) 1))) b)
(let ((res a)) (dotimes (i 10) (setq res (prod res (autoTerm (1+ i))))) (print (coeffs res)))
|#
;; #(1 0 -9 0 36 0 -84 0 126 0)

