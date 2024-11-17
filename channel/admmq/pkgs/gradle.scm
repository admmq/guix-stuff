(define-module (admmq pkgs gradle)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (nonguix build-system binary))

;; https://gitlab.com/nonguix/nonguix/-/blob/master/nongnu/packages/cad.scm
(define-public gradle-bin-0.7
  (package
    (name "gradle-bin")
    (version "0.7")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://services.gradle.org/distributions/gradle-"
                                  version
                                  "-bin.zip"))
              (sha256
               (base32
                "1bd6lv990z913i50r2fxys9zknkf8l0fjvndi5vhw2sw1p5lydaf"))))
    (build-system binary-build-system)
    (synopsis  "")
    (supported-systems '("x86_64-linux"))
    (description "")
    (home-page "")
    (license #f)))

