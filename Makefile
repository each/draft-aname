MMARK=${GOPATH}/bin/mmark

DRAFT=draft-fanf-dnsop-aname

OUT= ${DRAFT}.html ${DRAFT}.xml ${DRAFT}.txt

all: ${OUT}

${DRAFT}.html: ${DRAFT}.xml
	xml2rfc --html -o ${DRAFT}.html ${DRAFT}.xml

${DRAFT}.xml: ${DRAFT}.md
	${MMARK} -2 ${DRAFT}.md >${DRAFT}.xml

${DRAFT}.txt: ${DRAFT}.xml
	xml2rfc --raw -o ${DRAFT}.txt ${DRAFT}.xml

commit: stamp ${OUT}
	git add ${OUT}
	git commit -m 'Update rendered versions'

stamp::
	./util/stamp ${DRAFT}.md

clean:
	rm -f ${OUT}
