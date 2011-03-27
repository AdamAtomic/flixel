package org.flixel.aux.debug
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.flixel.FlxG;
	
	public class Debugger extends Sprite
	{
		static public const STANDARD:uint = 0;
		static public const MICRO:uint = 1;
		static public const BIG:uint = 2;
		static public const TOP:uint = 3;
		static public const LEFT:uint = 4;
		static public const RIGHT:uint = 5;

		public var perf:Perf;
		public var log:Log;
		public var watch:Watch;
		public var vcr:VCR;
		
		public var hasMouse:Boolean;
		
		protected var _layout:uint;
		protected var _screen:Point;
		protected var _gutter:uint;
		
		public function Debugger(Width:Number,Height:Number)
		{
			super();
			visible = false;
			hasMouse = false;
			_screen = new Point(Width,Height);

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
			
			_gutter = 8;
			var screenBounds:Rectangle = new Rectangle(_gutter,15+_gutter/2,_screen.x-_gutter*2,_screen.y-_gutter*1.5-15);
			
			log = new Log("log",0,0,true,screenBounds);
			addChild(log);
			
			watch = new Watch("watch",0,0,true,screenBounds);
			addChild(watch);
			
			perf = new Perf("stats",0,0,false,screenBounds);
			addChild(perf);
			
			vcr = new VCR();
			vcr.x = (Width - vcr.width)/2;
			vcr.y = 2;
			addChild(vcr);
			
			setLayout(STANDARD);
			
			//Should help with fake mouse focus type behavior
			addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
		}
		//Should help with fake mouse focus type behavior
		protected function onMouseOver(E:MouseEvent=null):void { hasMouse = true; }
		protected function onMouseOut(E:MouseEvent=null):void { hasMouse = false; }
		
		public function destroy():void
		{
			_screen = null;
			removeChild(log);
			log.destroy();
			log = null;
			removeChild(watch);
			watch.destroy();
			watch = null;
			removeChild(perf);
			perf.destroy();
			perf = null;
			removeChild(vcr);
			vcr.destroy();
			vcr = null;
		}
		
		public function setLayout(Layout:uint):void
		{
			_layout = Layout;
			resetLayout();
		}
		
		public function resetLayout():void
		{
			switch(_layout)
			{
				case MICRO:
					log.resize(_screen.x/4,68);
					log.reposition(0,_screen.y);
					watch.resize(_screen.x/4,68);
					watch.reposition(_screen.x,_screen.y);
					perf.reposition(_screen.x,0);
					break;
				case BIG:
					log.resize((_screen.x-_gutter*3)/2,_screen.y/2);
					log.reposition(0,_screen.y);
					watch.resize((_screen.x-_gutter*3)/2,_screen.y/2);
					watch.reposition(_screen.x,_screen.y);
					perf.reposition(_screen.x,0);
					break;
				case TOP:
					log.resize((_screen.x-_gutter*3)/2,_screen.y/4);
					log.reposition(0,0);
					watch.resize((_screen.x-_gutter*3)/2,_screen.y/4);
					watch.reposition(_screen.x,0);
					perf.reposition(_screen.x,_screen.y);
					break;
				case LEFT:
					log.resize(_screen.x/3,(_screen.y-15-_gutter*2.5)/2);
					log.reposition(0,0);
					watch.resize(_screen.x/3,(_screen.y-15-_gutter*2.5)/2);
					watch.reposition(0,_screen.y);
					perf.reposition(_screen.x,0);
					break;
				case RIGHT:
					log.resize(_screen.x/3,(_screen.y-15-_gutter*2.5)/2);
					log.reposition(_screen.x,0);
					watch.resize(_screen.x/3,(_screen.y-15-_gutter*2.5)/2);
					watch.reposition(_screen.x,_screen.y);
					perf.reposition(0,0);
					break;
				case STANDARD:
				default:
					log.resize((_screen.x-_gutter*3)/2,_screen.y/4);
					log.reposition(0,_screen.y);
					watch.resize((_screen.x-_gutter*3)/2,_screen.y/4);
					watch.reposition(_screen.x,_screen.y);
					perf.reposition(_screen.x,0);
					break;
			}
		}
	}
}