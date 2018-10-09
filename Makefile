MMARK=~/go/bin/mmark

DRAFT=draft-fanf-dnsop-aname

OUT= ${DRAFT}.html ${DRAFT}.xml ${DRAFT}.txt

all: ${OUT}

${DRAFT}.html: ${DRAFT}.md
	${MMARK} -html ${DRAFT}.md >${DRAFT}.html

${DRAFT}.xml: ${DRAFT}.md
	${MMARK} -2 ${DRAFT}.md >${DRAFT}.xml

${DRAFT}.txt: ${DRAFT}.xml
	xml2rfc --raw -o ${DRAFT}.txt ${DRAFT}.xml

stamp:
	./util/stamp ${DRAFT}.md

clean:
	rm -f ${OUT}
