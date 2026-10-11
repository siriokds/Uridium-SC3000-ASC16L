#!/bin/sh
# Replaces !make64_.bat (which ran sjasm/sjasm.exe, Windows-only) with sjasmplus,
# ported for macOS/Linux. See main64.asm for notes on what changed in the port
# (sjasm classic's defpage/code-page paging -> sjasmplus's DEVICE/SLOT/PAGE model).
set -e

cd "$(dirname "$0")"

sjasmplus \
	-I levels/ -I mus/ -I afx/ -I graphic/ -I options/ \
	--lst=main64.lst \
	--sym=main64.sym \
	main64.asm | tee log.txt

ls -la URIDIUM.asc
