package org.flixel.aux
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
	
	public class FlxDebugger extends Sprite
	{
		static public const STANDARD:uint = 0;
		static public const BIG:uint = 1;
		static public const TOP:uint = 2;
		static public const LEFT:uint = 3;
		static public const RIGHT:uint = 4;
		
		public var hasMouse:Boolean;
		
		protected var _perf:FlxWindow;
		protected var _log:FlxWindow;
		protected var _watch:FlxWindow;
		
		protected var _layout:uint;
		protected var _screen:Point;
		protected var _gutter:uint;
		
		public function FlxDebugger(Width:Number,Height:Number)
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
			var screenBounds:Rectangle = new Rectangle(_gutter,_gutter,_screen.x-_gutter*2,_screen.y-_gutter*2);
			
			_log = new FlxWindow("log",1,1,true,screenBounds);
			addChild(_log);
			
			_watch = new FlxWindow("watch",1,1,true,screenBounds);
			addChild(_watch);
			
			_perf = new FlxWindow("performance",100,100,false,screenBounds);
			addChild(_perf);
			
			setLayout(STANDARD);
			
			//Should help with fake mouse focus type behavior
			addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
		}
		//Should help with fake mouse focus type behavior
		protected function onMouseOver(E:MouseEvent=null):void { hasMouse = true; }
		protected function onMouseOut(E:MouseEvent=null):void { hasMouse = false; }
		
		public function setLayout(Layout:uint):void
		{
			_layout = Layout;
			resetLayout();
		}
		
		public function resetLayout():void
		{
			switch(_layout)
			{
				case BIG:
					_log.resize((_screen.x-_gutter*3)/2,_screen.y/2);
					_log.reposition(0,_screen.y);
					_watch.resize((_screen.x-_gutter*3)/2,_screen.y/2);
					_watch.reposition(_screen.x,_screen.y);
					_perf.reposition(_screen.x,0);
					break;
				case TOP:
					_log.resize((_screen.x-_gutter*3)/2,_screen.y/4);
					_log.reposition(0,0);
					_watch.resize((_screen.x-_gutter*3)/2,_screen.y/4);
					_watch.reposition(_screen.x,0);
					_perf.reposition(_screen.x,_screen.y);
					break;
				case LEFT:
					_log.resize(_screen.x/3,(_screen.y-_gutter*3)/2);
					_log.reposition(0,0);
					_watch.resize(_screen.x/3,(_screen.y-_gutter*3)/2);
					_watch.reposition(0,_screen.y);
					_perf.reposition(_screen.x,0);
					break;
				case RIGHT:
					_log.resize(_screen.x/3,(_screen.y-_gutter*3)/2);
					_log.reposition(_screen.x,0);
					_watch.resize(_screen.x/3,(_screen.y-_gutter*3)/2);
					_watch.reposition(_screen.x,_screen.y);
					_perf.reposition(0,0);
					break;
				case STANDARD:
				default:
					_log.resize((_screen.x-_gutter*3)/2,_screen.y/4);
					_log.reposition(0,_screen.y);
					_watch.resize((_screen.x-_gutter*3)/2,_screen.y/4);
					_watch.reposition(_screen.x,_screen.y);
					_perf.reposition(_screen.x,0);
					break;
			}
		}
	}
}