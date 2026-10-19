#!/bin/bash
# Asserts that -D pf_highp switches the fragment shader float precision emitted by
# hxsl.GlslOut from mediump to highp, and that vertex shaders stay highp.
# Needs `haxe` 4.x, `neko` and the `format` haxelib (heaps' own dependency). The
# generator runs on the Neko VM, so no GPU or native build is involved.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
HEAPS=$(cd "$HERE/../.." && pwd)
OUT=$(mktemp -d)
trap 'rm -rf "$OUT"' EXIT
rc=0
run() { # label [haxe args...]
	echo "== $1"; shift
	haxe -cp "$HERE" -cp "$HEAPS" -lib format -main GlslPrecisionTest -neko "$OUT/t.n" "$@" && neko "$OUT/t.n" || rc=1
}
run "default build"
run "-D pf_highp" -D pf_highp
[ $rc = 0 ] && echo "glsl precision: PASS" || echo "glsl precision: FAIL"
exit $rc
