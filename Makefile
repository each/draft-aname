all: xml txt

xml: draft-hunt-dnsop-aname-00.xml 

txt: draft-hunt-dnsop-aname-00.txt

html: draft-hunt-dnsop-aname-00.html

draft-hunt-dnsop-aname-00.xml: abstract.mkd middle.mkd template.xml
	pandoc2rfc -X abstract.mkd middle.mkd && mv draft.xml draft-hunt-dnsop-aname-00.xml

draft-hunt-dnsop-aname-00.txt: abstract.mkd middle.mkd template.xml
	pandoc2rfc -T abstract.mkd middle.mkd && mv draft.txt draft-hunt-dnsop-aname-00.txt

draft-hunt-dnsop-aname-00.html: abstract.mkd middle.mkd template.xml
	pandoc2rfc -M abstract.mkd middle.mkd && mv draft.html draft-hunt-dnsop-aname-00.html
