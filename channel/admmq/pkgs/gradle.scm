(define-module (admmq pkgs gradle)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (nonguix build-system binary))

(define-public gradle
  (package
    (name "gradle")
    (version "0.7")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://services.gradle.org/distributions/gradle-"
                                  version
                                  "-bin.zip"))
              (sha256
               (base32
                "13b5ab4a889vz39d36f45mhv3mlaxb305wsh3plk3dbjcrkkkirb"))))
    (build-system binary-build-system)
    (synopsis  "")
    (supported-systems '("x86_64-linux"))
    (description "")
    (home-page "")
    (license #f)))
