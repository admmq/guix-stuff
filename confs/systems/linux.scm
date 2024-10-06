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
  (my-make-linux-libre* "6.10.9"
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

(define* (my-make-linux-libre* version gnu-revision source supported-systems
                            #:key
                            (extra-version #f)
                            ;; A function that takes an arch and a variant.
                            ;; See kernel-config for an example.
                            (configuration-file #f)
                            (defconfig "defconfig")
                            (extra-options (default-extra-linux-options version)))
  (package
    (name (if extra-version
              (string-append "haha-linux-libre-" extra-version)
              "linux-libre"))
    (version version)
    (source source)
    (supported-systems supported-systems)
    (build-system gnu-build-system)
    (arguments
     (list
      #:modules '((guix build gnu-build-system)
                  (guix build utils)
                  (srfi srfi-1)
                  (srfi srfi-26)
                  (ice-9 ftw)
                  (ice-9 match))
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'patch-/bin/pwd
            (lambda _
              (substitute* (find-files
                            "." "^Makefile(\\.include)?$")
                (("/bin/pwd") "pwd"))))
          (add-before 'configure 'set-environment
            (lambda* (#:key target #:allow-other-keys)
              ;; Avoid introducing timestamps.
              (setenv "KCONFIG_NOTIMESTAMP" "1")
              (setenv "KBUILD_BUILD_TIMESTAMP" (getenv "SOURCE_DATE_EPOCH"))

              ;; Other variables useful for reproducibility.
              (setenv "KBUILD_BUILD_VERSION" "1")
              (setenv "KBUILD_BUILD_USER" "guix")
              (setenv "KBUILD_BUILD_HOST" "guix")

              ;; Set ARCH and CROSS_COMPILE.
              (let ((arch #$(platform-linux-architecture
                             (lookup-platform-by-target-or-system
                              (or (%current-target-system)
                                  (%current-system))))))
                (setenv "ARCH" arch)
                (format #t "`ARCH' set to `~a'~%" (getenv "ARCH"))
                (when target
                  (setenv "CROSS_COMPILE" (string-append target "-"))
                  (format #t "`CROSS_COMPILE' set to `~a'~%"
                          (getenv "CROSS_COMPILE"))))

              ;; Allow EXTRAVERSION to be set via the environment.
              (substitute* "Makefile"
                (("^ *EXTRAVERSION[[:blank:]]*=")
                 "EXTRAVERSION ?="))
              (setenv "EXTRAVERSION"
                      #$(and extra-version
                             (string-append "-" extra-version)))
              ;; Use the maximum compression available for Zstd-compressed
              ;; modules.
              (setenv "ZSTD_CLEVEL" "19")))
          (replace 'configure
            (lambda _
              (let ((config
                     #$(match (let ((arch (platform-linux-architecture
                                           (lookup-platform-by-target-or-system
                                            (or (%current-target-system)
                                                (%current-system))))))
                                (and configuration-file arch
                                     (configuration-file
                                      arch
                                      #:variant (version-major+minor version))))
                         (#f            ;no config for this platform
                          #f)
                         ((? file-like? config)
                          config))))
                ;; Use a custom kernel configuration file or a default
                ;; configuration file.
                (if config
                    (begin
                      (copy-file config ".config")
                      (chmod ".config" #o666))
                    (invoke "make" #$defconfig))
                ;; Appending works even when the option wasn't in the file.
                ;; The last one prevails if duplicated.
                (let ((port (open-file ".config" "a"))
                      (extra-configuration #$(config->string extra-options)))
                  (display extra-configuration port)
                  (close-port port))
                (invoke "make" "oldconfig"))))
          (replace 'install
            (lambda* (#:key make-flags parallel-build? #:allow-other-keys)
              (let ((moddir (string-append #$output "/lib/modules"))
                    (dtbdir (string-append #$output "/lib/dtbs"))
                    (make-flags
                     (append make-flags
                             (list "-j"
                                   (if parallel-build?
                                       (number->string (parallel-job-count))
                                       "1")))))
                ;; Install kernel image, kernel configuration and link map.
                (for-each (lambda (file) (install-file file #$output))
                          (find-files "." "^(\\.config|bzImage|zImage|Image\
|vmlinuz|System\\.map|Module\\.symvers)$"))
                ;; Install device tree files
                (unless (null? (find-files "." "\\.dtb$"))
                  (mkdir-p dtbdir)
                  (apply invoke "make"
                         (string-append "INSTALL_DTBS_PATH=" dtbdir)
                         "dtbs_install" make-flags))
                ;; Install kernel modules
                (mkdir-p moddir)
                (apply invoke "make"
                       ;; Disable depmod because the Guix system's module
                       ;; directory is an union of potentially multiple
                       ;; packages.  It is not possible to use depmod to
                       ;; usefully calculate a dependency graph while building
                       ;; only one of them.
                       "DEPMOD=true"
                       (string-append "MODULE_DIR=" moddir)
                       (string-append "INSTALL_PATH=" #$output)
                       (string-append "INSTALL_MOD_PATH=" #$output)
                       "INSTALL_MOD_STRIP=1"
                       "modules_install" make-flags)
                (let* ((versions (filter (lambda (name)
                                           (not (string-prefix? "." name)))
                                         (scandir moddir)))
                       (version (match versions
                                  ((x) x))))
                  ;; There are symlinks to the build and source directory.
                  ;; Both will point to target /tmp/guix-build* and thus not
                  ;; be useful in a profile.  Delete the symlinks.
                  (false-if-file-not-found
                   (delete-file
                    (string-append moddir "/" version "/build")))
                  (false-if-file-not-found
                   (delete-file
                    (string-append moddir "/" version "/source"))))))))))
    (native-inputs
     (list perl
           bc
           openssl
           elfutils                  ;needed to enable CONFIG_STACK_VALIDATION
           flex
           bison
           util-linux          ;needed for hexdump
           ;; These are needed to compile the GCC plugins.
           gmp
           mpfr
           mpc
           ;; These are needed when building with the CONFIG_DEBUG_INFO_BTF
           ;; support.
           dwarves                      ;for pahole
           python-wrapper
           zlib
           ;; For Zstd compression of kernel modules.
           zstd))
    (home-page "https://www.gnu.org/software/linux-libre/")
    (synopsis "100% free redistribution of a cleaned Linux kernel")
    (description "GNU Linux-Libre is a free (as in freedom) variant of the
Linux kernel.  It has been modified to remove all non-free binary blobs.")
    (license license:gpl2)
    (properties '((max-silent-time . 10800)))))

my-linux-package
