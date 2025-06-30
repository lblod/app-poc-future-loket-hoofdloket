(in-package #:handle-update-unit)

(defun filled-in-patterns (patterns bindings)
  "Creates a set of QUADS for the given patterns and bindings.

Any pattern which has no variables will be returned as is.  Any pattern
with bindings will be filled in for each discovered binding.  If any
variables are missing this will not lead to a pattern."
  (flet ((pattern-has-variables (pattern)
           (loop for (place match) on pattern by #'cddr
                 when (and (sparql-parser:match-p match)
                           (sparql-parser:match-term-p match 'ebnf::|VAR1| 'ebnf::|VAR2|))
                   do
                      (progn
                        ;; TODO: this should be integrated with *error-on-unwritten-data*.  If the quad doesn't exist
                        ;; _only_ because the graph is still a variable, then we would want to error on this case.
                        ;; (when (eq place :graph)
                        ;;   (format t "~&WARNING: Quad pattern contains graph variable ~A which is not supported, quad will be dropped ~A~%" match pattern))
                        (return t))))
         (fill-in-pattern (pattern bindings)
           (loop for (place match) on pattern by #'cddr
                 if (and (sparql-parser:match-p match)
                         (sparql-parser:match-term-p match 'ebnf::|VAR1| 'ebnf::|VAR2|)
                         (jsown:keyp bindings (subseq (terminal-match-string match) 1))) ; binding contains key (OPTIONAL in queries)
                   append (list place
                                (let ((solution (jsown:val bindings (subseq (terminal-match-string match) 1))))
                                  (if solution
                                      (binding-as-match solution)
                                      match)))
                 else
                   append (list place match))))
    (let* ((patterns-without-bindings (remove-if #'pattern-has-variables patterns))
           (patterns-with-bindings (set-difference patterns patterns-without-bindings :test #'eq)))
      (concatenate
       'list
       patterns-without-bindings        ; pattern without binding is quad
       (loop for binding in bindings
             append
             (loop for pattern in patterns-with-bindings
                   for filled-in-pattern = (fill-in-pattern pattern binding)
                   unless (pattern-has-variables filled-in-pattern)
               collect filled-in-pattern))))))

;;;;;;;;;;;;;;;;;;;
;;; delta messenger
(in-package :delta-messenger)

;;(add-delta-logger)
(add-delta-messenger "http://delta-notifier/")

;;;;;;;;;;;;;;;;;
;;; configuration
(in-package :client)
(setf *log-sparql-query-roundtrip* nil)
(setf *backend* "http://triplestore:8890/sparql")

(in-package :server)
(setf *log-incoming-requests-p* nil)

;;;;;;;;;;;;;;;;;
;;; access rights

(in-package :acl)

(defparameter *access-specifications* nil
  "All known ACCESS specifications.")

(defparameter *graphs* nil
  "All known GRAPH-SPECIFICATION instances.")

(defparameter *rights* nil
  "All known GRANT instances connecting ACCESS-SPECIFICATION to GRAPH.")

(define-prefixes
  :besluit "http://data.vlaanderen.be/ns/besluit#"
  :cpsv "http://purl.org/vocab/cpsv#"
  :dct "http://purl.org/dc/terms/"
  :eli "http://data.europa.eu/eli/ontology#"
  :ext "http://mu.semte.ch/vocabularies/ext/"
  :foaf "http://xmlns.com/foaf/0.1/"
  :ipdc "https://productencatalogus.data.vlaanderen.be/ns/ipdc-lpdc#"
  :lblodorg "http://lblod.data.gift/vocabularies/organisatie/"
  :locn "http://www.w3.org/ns/locn#"
  :m8g "http://data.europa.eu/m8g/"
  :schema "http://schema.org/"
  :skos "http://www.w3.org/2004/02/skos/core#")

(type-cache::add-type-for-prefix "http://mu.semte.ch/sessions/" "http://mu.semte.ch/vocabularies/session/Session")

(define-graph public ("http://mu.semte.ch/graphs/public")
  ("skos:Concept" -> _)
  ("skos:ConceptScheme" -> _)
  ("besluit:Bestuurseenheid" -> _)
  ("lblodorg:BestuurseenheidClassificatieCode" -> _)
  ("foaf:Person" -> _)
  ("foaf:OnlineAccount" -> _))

(define-graph vocabularies ("http://mu.semte.ch/graphs/vocabularies")
  (_ -> _))

(define-graph ipdc ("http://mu.semte.ch/graphs/ipdc/ldes-data")
  ("ipdc:InstancePublicServiceSnapshot" -> _)
  ("ipdc:FinancialAdvantage" -> _)
  ("schema:WebSite" -> _)
  ("m8g:Requirement" -> _)
  ("m8g:Cost" -> _)
  ("m8g:Evidence" -> _)
  ("schema:ContactPoint" -> _)
  ("locn:Address" -> _)
  ("cpsv:Rule" -> _)
  ("eli:LegalResource" -> _))

(supply-allowed-group "public")

(grant (read)
  :to-graph (public ipdc vocabularies)
  :for-allowed-group "public")
