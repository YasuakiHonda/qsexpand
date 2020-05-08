;; maxima-asdf support file for qsexpand package
;; written by Yasuaki Honda
;; Licensed under GPL 2.0 .
;; See LICENSE file for the terms of the license

;; Visit https://github.com/robert-dodier/maxima-asdf for installing maxima-asdf in your environment.
;; Then you can load the package from github directly:

;; install_github("YasuakiHonda","qsexpand","master");
;; asdf_load("qsexpand");

;; Then you can play with functions in qsexpand package.


(defsystem qsexpand
  :name "q series fast expand program"
  :author "Yasuaki Honda"
  :license "GNU General Public License, version 2"
  :description "Maxima package for q series fast expand program"

  :components
    ((:file "qsexpand")))
