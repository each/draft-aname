all: draft-hunt-dnsop-aname-00.xml draft-hunt-dnsop-aname-00.txt

draft-hunt-dnsop-aname-00.xml: abstract.mkd middle.mkd
	pandoc2rfc -X abstract.mkd middle.mkd && mv draft.xml draft-hunt-dnsop-aname-00.xml

draft-hunt-dnsop-aname-00.txt: abstract.mkd middle.mkd
	pandoc2rfc -T abstract.mkd middle.mkd && mv draft.txt draft-hunt-dnsop-aname-00.txt
