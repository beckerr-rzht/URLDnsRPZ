
# Mail::SpamAssassin::Plugin::URLDnsRPZ

Checks if the hostname part of any url found in a email is DNS RPZ filtered

## Usage
```
 loadplugin Mail::SpamAssassin::Plugin::URLDnsRPZ URLDnsRPZ.pm

 body       URL_DNS_RPZ   eval:check_url_dnsrpz('^.*\.rpz\.(dfn\.de|switch\.ch)$')
 score      URL_DNS_RPZ   3.0
 describe   URL_DNS_RPZ   URL is filtered by DNS RPZ
```

## About

URLDnsRPZ is a plugin for SpamAssasin. It takes all URLs contained in a
email and resolves their hostname sequentially using DNS. The DNS response
is checked for having an "owner" in its "additions section". If this owner
matches an given regex the check terminates and returns a match.

The check function takes one mandatory and one optional argument:
```
 eval:check_url_dnsrpz(<regex>[,<linktype>)

 regex    - Regular expression to use for checking the "owner" listed in the
            "addition section" return from the DNS server. (mandatory)
 linktype - Type of URL to check. Valid types are 'a', 'img' and 'parsed'.
            See SpamAssain doumentation for more information.
            (optional, default is 'a')
```

## License

Copyright (c) 2024 Ralf Becker

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

## Author

Ralf Becker <beckerr@hochschule-trier.de>
