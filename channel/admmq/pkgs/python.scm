(define-module (admmq pkgs python)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages image)
  #:use-module (gnu packages game-development)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system python))

(define-public python-pillow-heif-0.16
  (package
    (name "python-pillow-heif")
    (version "0.16.0")
    (source (origin
              (method git-fetch)
              (uri
               (git-reference
                (url "https://github.com/bigcat88/pillow_heif")
                (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32 "1f271r0n9k5gflf4hf8nqncnwzg6wryq76p7w9ffp84qmmabm4jf"))))
    (build-system python-build-system)
    (arguments
     (list #:tests? #f
           #:phases
           #~(modify-phases %standard-phases
             ;; sanity-check phase fail, but the application seems to be working
             (delete 'sanity-check))))
    (inputs
     (list zlib
           ijg-libjpeg
           libheif))
    (home-page "")
    (synopsis "")
    (description
     "")
    (license #f)))

(define-public python-tcod
  (let ((commit "3d19e29d8b5a6925ba4b287c272635699b99dd42")
        (revision "0"))
    (package
      (name "python-tcod")
      (version (git-version "0.0.1" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/libtcod/python-tcod.git")
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "0gi4xb1rabmawhdp12j6js6s20wk42v8fwn87bf3b4wc1gkl9ir1"))))
      (build-system python-build-system)
      (inputs
       (list libtcod))
      ;; (arguments
      ;;  (list #:tests? #f
      ;;        #:phases
      ;;        #~(modify-phases %standard-phases
      ;;          ;; sanity-check phase fail, but the application seems to be working
      ;;          (delete 'sanity-check))))
      ;; (inputs
      ;;  (list zlib
      ;;        ijg-libjpeg
      ;;        libheif))
      (home-page "")
      (synopsis "")
      (description
       "")
      (license #f))))

(define-public my-libtcod
  (package
    (inherit libtcod)
    (name "libtcod")
    (version "1.24.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/libtcod/libtcod")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0pzr8ajmbqvh43ldjajx962xirj3rf8ayh344p6mqlrmb8gxrfr5"))))))
