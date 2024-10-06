(define-module (my-local-packages)
  #:use-module (guix)
  #:use-module (nongnu packages linux)
  #:use-module (gnu packages linux)
  #:use-module (guix git-download))

(define-public my-linux-package
  (package
    (inherit linux-lts)
    (name "my-linux-package")
    (version "v6.6")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/torvalds/linux.git")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1n34v4rq551dffd826cvr67p0l6qwyyjmsq6l98inbn4qqycfi49"))))))

(define-public my-linux-libre-6.10
  (make-linux-libre* "6.10.9"
                     "gnu"
                     linux-libre-6.10-source
                     '("x86_64-linux")
                     #:configuration-file ""))

(define-public linux-libre-6.10-source
  (source-with-patches linux-libre-6.10-pristine-source
                       (list %boot-logo-patch
                             %linux-libre-arm-export-__sync_icache_dcache-patch)))

(define (source-with-patches source patches)
  (origin
    (inherit source)
    (patches (append (origin-patches source)
                     patches))))

(define %boot-logo-patch
  ;; Linux-Libre boot logo featuring Freedo and a gnu.
  (origin
    (method url-fetch)
    (uri (string-append "http://www.fsfla.org/svn/fsfla/software/linux-libre/"
                        "lemote/gnewsense/branches/3.16/100gnu+freedo.patch"))
    (sha256
     (base32
      "1hk9swxxc80bmn2zd2qr5ccrjrk28xkypwhl4z0qx4hbivj7qm06"))))

(define %linux-libre-arm-export-__sync_icache_dcache-patch
  (origin
    (method url-fetch)
    (uri (string-append
          "https://salsa.debian.org/kernel-team/linux"
          "/raw/34a7d9011fcfcfa38b68282fd2b1a8797e6834f0"
          "/debian/patches/bugfix/arm/"
          "arm-mm-export-__sync_icache_dcache-for-xen-privcmd.patch"))
    (file-name "linux-libre-arm-export-__sync_icache_dcache.patch")
    (sha256
     (base32 "1ifnfhpakzffn4b8n7x7w5cps9mzjxlkcfz9zqak2vaw8nzvl39f"))))

;; my-linux-package
