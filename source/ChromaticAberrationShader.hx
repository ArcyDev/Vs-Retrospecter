package;

import flixel.system.FlxAssets.FlxShader;

class ChromaticAberrationShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
        uniform vec2 rOffset;
        uniform vec2 gOffset;
        uniform vec2 bOffset;

		vec4 offsetColor(vec2 offset)
        {
            return texture2D(bitmap, openfl_TextureCoordv.st - offset);
        }

		void main()
		{
			vec4 base = texture2D(bitmap, openfl_TextureCoordv);
            base.r = offsetColor(rOffset).r;
            base.g = offsetColor(gOffset).g;
            base.b = offsetColor(bOffset).b;

			gl_FragColor = base;
		}')
	public function new()
	{
		super();
	}
}
