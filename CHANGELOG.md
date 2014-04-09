# Chef Server Changelog

## 11.0.12 (2014-04-09)

### curl 7.36.0
* [CVE-2014-0138] - libcurl can in some circumstances re-use the wrong connection when asked to do transfers using other protocols than HTTP and FTP
* [CVE-2014-0139] - libcurl incorrectly validates wildcard SSL certificates containing literal IP addresses when built to use OpenSSL
* [CVE-2014-1263] - When asked to do a TLS connection (HTTPS, FTPS, IMAPS, etc) to a URL specified with an IP address instead of a name, libcurl built to use Darwinssl would wrongly not verify the server's name in the certificate
* [CVE-2014-2522] - When asked to do a TLS connection (HTTPS, FTPS, IMAPS, etc) to a URL specified with an IP address instead of a name, libcurl built to use Winssl would wrongly not verify the server's name in the certificate

### libyaml 0.1.6
* [CVE-2014-2525] - Heap-based buffer overflow allows context-dependent attackers to execute arbitrary code

### openssl 1.0.1g
* [CVE-2014-0160] - heartbeat extension allows remote attackers to obtain sensitive information from process memory

## 11.0.11 (2014-02-17)

### libyaml 0.1.5
* [CVE-2013-6393] - ml_parser_scan_tag_uri function in scanner.c performs incorrect cast
