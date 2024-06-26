#!/usr/bin/env bash

###
### Simple scanning script using `scanimage` and `gs` to scan a series of images
### from a flatbed scanner (continuing to new pages or breaking to a new
### document based on user input as needed) in lieu of access to a feeding
### scanner.
###

set -e

SCAN_OUTPUT_DIR=~/Pictures/Scans
TMP_DIR="$(mktemp -d --suffix='scans')"

while
	page_number=1
	while
		echo "Scanning page $page_number"
		scanimage --format tiff --resolution 150 --output "$TMP_DIR/scan$(printf '%02d' "$page_number").tiff"
		echo

		read -r -n 1 -p "Press enter to scan page $(( page_number + 1 )), 'n' to start scanning a new document, or any other character to stop scanning: " prompt
		[[ -z "$prompt" ]]
	do
		(( page_number++ ))
	done
	echo

	# convert image sequence to pdf
	scan_output_filename=scan_"$(date +%Y-%m-%d-%H-%M-%S)"
	convert "$TMP_DIR"/*.tiff "${SCAN_OUTPUT_DIR}/${scan_output_filename}_raw.pdf"

	# compress pdf
	# see: https://itsfoss.com/compress-pdf-linux/
	gs \
		-sDEVICE=pdfwrite \
		-dCompatibilityLevel=1.4 \
		-dPDFSETTINGS=/prepress \
		-dNOPAUSE \
		-dQUIET \
		-dBATCH \
		-sOutputFile="${SCAN_OUTPUT_DIR}/${scan_output_filename}.pdf" \
		"${SCAN_OUTPUT_DIR}/${scan_output_filename}_raw.pdf"

	# remove temp files
	rm -rf "${TMP_DIR:?}"/* "${SCAN_OUTPUT_DIR}/${scan_output_filename}_raw.pdf"

	echo "Scanned $(( page_number )) pages to ${SCAN_OUTPUT_DIR}/${scan_output_filename}.pdf"
	echo

	[[ "$prompt" == 'n' || "$prompt" == 'N' ]]
do
	true
done

rm -rf "$TMP_DIR"
