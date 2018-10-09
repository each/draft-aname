%%%
title			= "Address-specific DNS aliases (ANAME)"
abbrev			= "ANAME"
workgroup		= "DNS Operations"
area			= "Operations and Management"
submissiontype	= "IETF"
ipr				= "trust200902"
date			= 2018-10-09
keyword			= [
	"DNS",
	"RR",
	"ANAME",
	"CNAME",
	"apex",
]

[seriesInfo]
name			= "Internet-Draft"
value			= "draft-ietf-dnsop-aname-02"
status			= "standard"

[[author]]
initials		= "T."
surname			= "Finch"
fullname		= "Tony Finch"
organization	= "University of Cambridge"
 [author.address]
 email			= "dot@dotat.at"
  [author.address.postal]
  streets		= [
    "University Information Services",
	"Roger Needham Building",
	"7 JJ Thomson Avenue",
  ]
  city			= "Cambridge"
  country		= "England"
  code			= "CB3 0RB"

[[author]]
initials		= "E."
surname			= "Hunt"
fullname		= "Evan Hunt"
organization	= "ISC"
 [author.address]
 email			= "each@isc.org"
  [author.address.postal]
  street		= "950 Charter St"
  city			= "Redwood City"
  region		= "CA"
  code			= "94063"
  country		= "USA"

[[author]]
initials		= "P.D."
surname			= "van Dijk"
fullname		= "Peter van Dijk"
organization	= "PowerDNS.COM B.V."
abbrev			= "PowerDNS"
 [author.address]
 email			= "peter.van.dijk@powerdns.com"
  [author.address.postal]
  city			= "Den Haag"
  country		= "The Netherlands"

[[author]]
initials		= "A."
surname			= "Eden"
fullname		= "Anthony Eden"
organization	= "DNSimple"
 [author.address]
 email			= "anthony.eden@dnsimple.com"
 uri			= "https://dnsimple.com/"
  [author.address.postal]
  city			= "Boston"
  region		= "MA"
  code			= "USA"

%%%

.# Abstract

This document defines the "ANAME" DNS RR type, to provide similar
functionality to CNAME, but only for type A and AAAA queries. Unlike
CNAME, an ANAME can coexist with other record types. The ANAME RR
allows zone owners to make an apex domain name into an alias in a
standards compliant manner.


{mainmatter}


Introduction
============

It is often desirable to provide web sites (and other services) at a
bare domain name (such as `example.com`) as well as a service-specific
subdomain (`www.example.com`).

If the web site is hosted by a third-party provider, the ideal way to
provision its name in the DNS is using a CNAME record, so that the
third party provider retains control over the mapping from names to IP
address(es). It is now common for name-to-address mappings to be
highly dynamic, dependent on client location, server load, etc.

However, CNAME records cannot coexist with other records. (The reason
why is explored in (#history)). This means they cannot appear at a
zone apex (such as `example.com`) because of the SOA, NS, and other
records that have to be present there. CNAME records can also conflict
at subdomains, for example if `department.example.edu` has separately
hosted mail and web servers.

Redirecting website lookups to an alternate domain name via SRV or URI
resource records would be an effective solution from the DNS point of
view, but to date this approach has not been accepted by browser
implementations.

As a result, the only widely supported and standards-compliant way to
publish a web site at a bare domain is to place A and/or AAAA records
at the zone apex. The flexibility afforded by CNAME is not available.

This document specifies a new RR type "ANAME", which provides similar
functionality to CNAME, but only for address queries (i.e., for type A
or AAAA). The basic idea is that the address records next to an ANAME
record are automatically copied from and kept in sync with the ANAME
target's address records. The ANAME record can be present at any DNS
node, and can coexist with most other RR types, enabling it to be
present at a zone apex, or any other name where the presence of other
records prevents the use of CNAME.

Similar authoritative functionality has been implemented and deployed
by a number of DNS software vendors and service providers, using names
such as ALIAS, ANAME, apex CNAME, CNAME flattening, and top level
redirection. These mechanisms are proprietary, which hinders the
ability of hostmasters to serve the same zone data from multiple
providers, or move service between providers. None of these
proprietary versions include a mechanism for resolvers to follow the
redirection chain themselves.

Overview
--------

The core functionality of this specification allows zone
administrators to start using ANAME records unilaterally, without
requiring secondary servers or resolvers to be upgraded.

  * The resource record definition in (#rdata) is intended to provide
    zone data portability between standards-compliant DNS servers and
    the common core functionality of existing proprietary
    ANAME-alikes.

  * The zone maintenance described in (#primary) behaves as if DNS
    UPDATE [@!RFC2136] is used to keep an ANAME's sibling address
    records in sync with the ANAME target, so it interoperates with
    existing secondary servers and resolvers.

This is enough to be useful by itself. However it can be less than
optimal in certain situations, for instance when the ANAME target uses
clever tricks to provide different answers to different clients to
improve latency or load balancing.

  * The additional section processing rules in (#additional) inform
    resolvers that an ANAME record is in play.

  * Resolvers can use this ANAME information as described in
    (#resolver) to obtain answers that are tailored to the resolver
    rather than to the zone's primary master.

Resolver support for ANAME is not necessary, since ANAME-oblivious
resolvers will get working answers from authoritative servers. It's
just an optimization that can be rolled out incrementally, and that
will help ANAME to work better the more widely it is deployed.

Terminology
-----------

An "address record" is a DNS resource record whose type is A or AAAA.
These are referred to as "address types". "Address query" refers to a
DNS query for any address type.

The "sibling address records" of an ANAME record are the address
records at the same owner name as the ANAME, which are subject to
ANAME substitution.

The "target address records" of an ANAME record are the address
records obtained by resolving the ultimate target of the ANAME (see
(#subst)).

Other DNS-related terminology can be found in
[@!I-D.ietf-dnsop-terminology-bis].

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHALL**,
**SHALL NOT**, **SHOULD**, **SHOULD NOT**, **RECOMMENDED**, **MAY**,
and **OPTIONAL** in this document are to be interpreted as described in
[@!RFC2119].


The ANAME resource record {#rdata}
=========================

This document defines the "ANAME" DNS resource record type, with RR TYPE
value [TBD].

Presentation and wire format
----------------------------

The ANAME presentation format is identical to that of CNAME [@!RFC1033]:

```
    owner ttl class ANAME target
```

The wire format is also identical to CNAME [@!RFC1035], except that
name compression is not permitted in ANAME RDATA, per [@!RFC3597].

Coexistence with other types {#coexistence}
----------------------------

Only one ANAME \<target\> can be defined per \<owner\>. An ANAME
RRset MUST NOT contain more than one resource record.

An ANAME's sibling address records are under the control of ANAME
processing (see (#primary)) and are not first-class records in their
own right. They MAY exist in zone files, but they will be altered
by ANAME processing.

ANAME records MAY freely coexist at the same owner name with other RR
types, except they MUST NOT coexist with CNAME or any other RR type
that restricts the types with which it can itself coexist.

Like other types, ANAME records can coexist with DNAME records at the
same owner name; in fact, the two can be used cooperatively to
redirect both the owner name (via ANAME) and everything under it (via
DNAME).


Additional section processing {#additional}
=============================

The requirements in this section apply to both recursive and
authoritative servers.

An ANAME target MAY resolve to address records via a chain of CNAME
and/or ANAME records; any CNAME/ANAME chain MUST be included when
adding target address records to a response's additional section.

Address queries
---------------

When a server receives an address query for a name that has an ANAME
record, the response's additional section:

  * MUST contain the ANAME record;

  * MAY contain the target address records that matching the query
    type (or the corresponding proof of nonexistence), if they are
    available and the target address RDATA fields differ from the
    sibling address RRset.

The ANAME record indicates to a client that it might wish to resolve
the target address records itself. The target address records might
not be available if the server is authoritative and does not include
out-of-zone or non-authoritative data in its answers, or if the server
is recursive and the records are not in the cache.

ANAME queries
-------------

There are three cases:

  * The query resolved to an ANAME record, and the server has the
    target address records; any target address records SHOULD be added
    to the additional section.

  * The query resolved to an ANAME record, and the server does not
    have the target address records; any sibling address records
    SHOULD be added to the additional section.

  * The query did not resolve to an ANAME record; any would-be sibling
    address records SHOULD be added to the additional section.

When adding address records to the additional section, the server
SHOULD include a DNSSEC proof of nonexistence for missing address
records if the zone is signed.


Substituting ANAME sibling address records {#subst}
==========================================

This process is used by both primary masters (see (#primary)) and
resolvers (see (#resolver)).

The following steps MUST be performed for each address type:

  * Starting at the ANAME owner, follow the chain of ANAME and/or
    CNAME records as far as possible to find the ultimate target.

  * If a loop is detected, continue with an empty RRset, otherwise get
    the ultimate target's address records. (Ignore any sibling address
    records of intermediate ANAMEs.)

  *	Stop if resolution failed. (Note that NXDOMAIN and NODATA count as
    successfully resolving an empty RRset.)

  * Replace the owner of the target address records with the owner of
    the ANAME record. Drop any RRSIG records.

  * Stop if this modified RRset is the same as the sibling RRset
    (ignoring any RRSIG records).

  * Delete the sibling address RRset and replace it with the modified
    RRset.

At this point the substituted RRset is not signed; a primary master
will proceed to sign the sibstituted RRset, whereas resolvers can only
use the substituted RRset when an unsigned answer is appropriate. This
is explained in more detail in the following sections.


ANAME processing by primary masters {#primary}
===================================

Each ANAME record is SPONG


ANAME processing by resolvers {#resolver}
=============================

WIBBLE


IANA considerations
===================

IANA is requested to assign a DNS RR TYPE value for ANAME resource
records under the "Resource Record (RR) TYPEs" subregistry under the
"Domain Name System (DNS) Parameters" registry.

IANA may wish to consider the creation of a registry of address types;
addition of new types to such a registry would then implicitly update
this specification.


Security considerations
=======================

When a primary master updates an ANAME's sibling address records to
match its target address records, it is uses its own best information
as to the correct answer. The updated records may be signed by the
primary master, but that is not a guarantee of the actual correctness
of the answer. This can have the effect of promoting an insecure
response from the ANAME \<target\> to a signed response from the
\<owner\>, which may then appear to clients to be more trustworthy
than it should. To mitigate harm from this, DNSSEC validation SHOULD
be used when resolving the ANAME \<target\>. Primary masters MAY
refuse to substitute ANAME sibling address records unless the
\<target\> node is both signed and validated.

When a resolver substitutes an ANAME's sibling address records, it can
find that the sibling address records are secure but the target
address records are insecure. Going ahead with the substitution will
downgrade a secure answer to an insecure one. But this is likely to be
the counterpart of the situation described in the previous paragraph,
so the resolver is downgrading an answer that the ANAME's primary
master upgraded. A resolver will only downgrade an answer in this way
when its client is security-oblivious; however the client's path to
the resolver is likely to be practically safer than the resolver's
path to the ANAME target's servers. Resolvers MAY choose not to
substitute sibling address records when they are more secure than the
target address records.


{backmatter}


Acknowledgments
===============

Thanks to Mark Andrews, Ray Bellis, Stefan Buehler, Paul Ebersman,
Richard Gibson, Tatuya JINMEI, Hakan Lindqvist, Mattijs Mekking,
Stephen Morris, Bjorn Mott, Richard Salts, Mukund Sivaraman, Job
Snijders, Jan Vcelak, Paul Vixie, Duane Wessels, and Paul Wouters for
discussion and feedback.


Implementation status
=====================

PowerDNS currently implements a similar authoritative-only feature
using "ALIAS" records, which are expanded by the primary server and
transfered as address records to secondaries.

[TODO: Add discussion of DNSimple, DNS Made Easy, EasyDNS, Cloudflare, Amazon,
and Akamai.]


Historical note {#history}
===============

In the early DNS [@?RFC0882], CNAME records were allowed to coexist
with other records. However this led to coherency problems: if a
resolver had no cache entries for a given name, it would resolve
queries for un-cached records at that name in the usual way; once it
had cached a CNAME record for a name, it would resolve queries for
un-cached records using CNAME target instead.

For example, given the zone contents below, the original CNAME
behaviour meant that if you asked for `alias.example.com TXT` first,
you would get the answer "owner", but if you asked for
`alias.example.com A` then `alias.example.com TXT` you would get the
answer "target".

```
   alias.example.com.      TXT    "owner"
   alias.example.com.      CNAME  canonical.example.com.
   canonical.example.com.  TXT    "target"
   canonical.example.com.  A      192.0.2.1
```

This coherency problem was fixed in [@?RFC0973] which introduced the
inconvenient rule that a CNAME acts as an alias for all other RR types
at a name, which prevents the coexistence of CNAME with other records.

A better fix might have been to improve the cache's awareness of which
records do and do not coexist with a CNAME record. However that would
have required a negative cache mechanism which was not added to the
DNS until later [@?RFC1034] [@?RFC2308].

While [@?RFC2065] relaxed the restriction by allowing coexistence of
CNAME with DNSSEC records, this exception is still not applicable to
other resource records. RRSIG and NSEC exist to prove the integrity of
the CNAME record; they are not intended to associate arbitrary data
with the domain name. DNSSEC records avoid interoperability problems
by being largely invisible to security-oblivious resolvers.

Now that the DNS has negative caching, it is tempting to amend the
algorithm for resolving with CNAME records to allow them to coexist
with other types. Although an amended resolver will be compatible with
the rest of the DNS, it will not be of much practical use because
authoritative servers which rely on coexisting CNAMEs will not
interoperate well with older resolvers. Practical experiments show
that the problems are particularly acute when CNAME and MX try to
coexist.


Changes since the last revision
===============================

* Adjusted discussion of coexistence with other types (#coexistence)
