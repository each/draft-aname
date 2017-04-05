PANDOC2RFC=pandoc2rfc
XML=abstract.xml middle.xml
TITLE=$(shell grep docName template.xml | sed -e 's/.*docName=\"//' -e 's/\">//')
.PHONY: txt html xml

all: xml txt

xml: $(TITLE).xml 

txt: $(TITLE).txt

html: $(TITLE).html

$(TITLE).xml: abstract.mkd middle.mkd template.xml
	$(PANDOC2RFC) -X abstract.mkd middle.mkd && cp -f draft.xml $(TITLE).xml

$(TITLE).txt: abstract.mkd middle.mkd template.xml
	$(PANDOC2RFC) -T abstract.mkd middle.mkd && cp -f draft.txt $(TITLE).txt

$(TITLE).html: abstract.mkd middle.mkd template.xml
	$(PANDOC2RFC) -M abstract.mkd middle.mkd && cp -f draft.html $(TITLE).html

clean:
	rm -f $(XML) $(TITLE).txt $(TITLE).html  $(TITLE).xml
