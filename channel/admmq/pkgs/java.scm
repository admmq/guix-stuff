(define-module (admmq pkgs java)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages java)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system maven))

(define-public java-telegrambots
  (package
    (name "java-telegrambots")
    (version "7.10.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/rubenlagus/TelegramBots.git")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "17wcr1andd42hx9cln594r76685klx8lyxzf1gn9gc9nqg1kjqdv"))))
    (build-system maven-build-system)
    (native-inputs
     (list java-mockito-1))
    (home-page "")
    (synopsis "")
    (description "")
    (license #f)))

(define-public java-mockito-2
  (package
    (inherit java-mockito-1)
    (version "2.28.2")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://repo1.maven.org/maven2/"
                                  "org/mockito/mockito-core/" version
                                  "/mockito-core-" version "-sources.jar"))
              (sha256
               (base32
                "0vmiwnwpf83g2q7kj1rislmja8fpvqkixjhawh7nxnygx6pq11kc"))))))
