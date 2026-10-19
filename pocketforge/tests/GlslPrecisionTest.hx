import hxsl.Ast;

/**
	Generates a minimal vertex and fragment shader with hxsl.GlslOut for OpenGL ES 3.0
	and checks the default float precision line of each.
	Expected: vertex is always highp; fragment is mediump, or highp with -D pf_highp.
	Run with test-glsl-precision.sh (Neko VM, no GPU needed).
**/
class GlslPrecisionTest {
	static function shader(kind:FunctionKind):ShaderData {
		var ref:TVar = {id: 1, name: kind == Vertex ? "vertex" : "fragment", type: TFun([]), kind: Function};
		var body:TExpr = {e: TBlock([]), t: TVoid, p: null};
		return {name: "precisionTest", vars: [], funs: [{kind: kind, ref: ref, args: [], ret: TVoid, expr: body}]};
	}

	static function precisionLine(kind:FunctionKind) {
		var out = new hxsl.GlslOut();
		out.glES = 3;
		out.version = 300;
		var src = out.run(shader(kind));
		for (line in src.split("\n"))
			if (StringTools.startsWith(StringTools.trim(line), "precision ") && line.indexOf(" float;") >= 0)
				return StringTools.trim(line);
		return null;
	}

	static function main() {
		var expectFragment = #if pf_highp "precision highp float;" #else "precision mediump float;" #end;
		var vertex = precisionLine(Vertex);
		var fragment = precisionLine(Fragment);
		Sys.println('vertex:   $vertex');
		Sys.println('fragment: $fragment');
		var ok = vertex == "precision highp float;" && fragment == expectFragment;
		Sys.println(ok ? 'PASS (fragment expected "$expectFragment")' : 'FAIL (fragment expected "$expectFragment")');
		Sys.exit(ok ? 0 : 1);
	}
}
