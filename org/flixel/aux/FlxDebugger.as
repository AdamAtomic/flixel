package org.flixel.aux
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.flixel.FlxG;
	
	public class FlxDebugger extends Sprite
	{
		public var hasMouse:Boolean;
		
		protected var _perf:FlxWindow;
		protected var _log:FlxWindow;
		protected var _watch:FlxWindow;
		
		public function FlxDebugger(Width:Number,Height:Number)
		{
			super();
			visible = false;
			hasMouse = false;

			addChild(new Bitmap(new BitmapData(Width,15,true,0x7f000000)));
			
			var txt:TextField = new TextField();
			txt.x = 2;
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
			
			var gutter:uint = 8;
			var screenBounds:Rectangle = new Rectangle(gutter,gutter,Width-gutter*2,Height-gutter*2);
			
			_log = new FlxWindow("log",(Width-gutter*3)/2,Height/4,true,screenBounds);
			_log.y = Height;
			addChild(_log);
			
			_watch = new FlxWindow("watch",(Width-gutter*3)/2,Height/4,true,screenBounds);
			_watch.x = Width;
			_watch.y = Height;
			addChild(_watch);
			
			_perf = new FlxWindow("performance",100,100,false,screenBounds);
			_perf.x = Width;
			addChild(_perf);
			
			//Should help with fake mouse focus type behavior
			addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
		}
		//Should help with fake mouse focus type behavior
		protected function onMouseOver(E:MouseEvent=null):void { hasMouse = true; }
		protected function onMouseOut(E:MouseEvent=null):void { hasMouse = false; }
		
		//
	}
}