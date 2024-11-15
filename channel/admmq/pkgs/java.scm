(define-module (admmq pkgs java)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
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
                "0i7fa7l3gdqkkgz5ddayp6m46dgbj9rqlz35xffrcbyiz3gpljy0"))))
    (build-system maven-build-system)
    (home-page "")
    (synopsis "")
    (description "")
    (license #f)))
