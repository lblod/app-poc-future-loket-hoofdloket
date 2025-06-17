;;;;;;;;;;;;;;;;;;;
;;; delta messenger
(in-package :delta-messenger)

(add-delta-logger)
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
