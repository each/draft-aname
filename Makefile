MMARK=~/go/bin/mmark

DRAFT=draft-fanf-dnsop-aname

OUT= ${DRAFT}.xml ${DRAFT}.html

all: ${OUT}

${DRAFT}.html: ${DRAFT}.md
	${MMARK} -html ${DRAFT}.md >${DRAFT}.html

${DRAFT}.xml: ${DRAFT}.md
	${MMARK} ${DRAFT}.md >${DRAFT}.xml

clean:
	rm -f ${OUT}
