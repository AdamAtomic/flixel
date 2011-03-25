package org.flixel.aux
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.flixel.FlxG;
	
	public class FlxDebugger extends Sprite
	{
		protected var _perf:Sprite;
		protected var _trace:Sprite;
		protected var _watch:Sprite;
		
		public function FlxDebugger(Width:Number,Height:Number)
		{
			super();
			visible = false;

			addChild(new Bitmap(new BitmapData(Width,15,true,0x7f000000)));
			
			var txt:TextField = new TextField();
			txt.width = 160;
			txt.height = 16;
			txt.selectable = false;
			txt.multiline = false;
			txt.defaultTextFormat = new TextFormat("Courier",12,0xffffff);
			var str:String = FlxG.LIBRARY_NAME + " v" + FlxG.LIBRARY_MAJOR_VERSION + "." + FlxG.LIBRARY_MINOR_VERSION;
			if(FlxG.debug)
				str += " [debug]";
			else
				str += " [release]";
			txt.text = str;
			addChild(txt);
		}
	}
}