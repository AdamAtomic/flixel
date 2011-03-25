package org.flixel.aux.debugger
{
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.flixel.aux.FlxWindow;
	
	public class Watch extends FlxWindow
	{
		static protected const MAX_LOG_LINES:uint = 1024;
		
		protected var _text:TextField;
		protected var _watching:Array;
		
		public function Watch(Title:String, Width:Number, Height:Number, Resizable:Boolean=true, Bounds:Rectangle=null, BGColor:uint=0xdfBABCBF, TopColor:uint=0xff4E5359)
		{
			super(Title, Width, Height, Resizable, Bounds, BGColor, TopColor);
			
			_text = new TextField();
			_text.x = 2;
			_text.y = 15;
			_text.multiline = true;
			_text.wordWrap = true;
			_text.selectable = true;
			_text.defaultTextFormat = new TextFormat("Courier",12,0);
			addChild(_text);
			
			_watching = new Array();
		}
		
		public function add(AnyObject:Object,VariableName:String):void
		{
			_watching.push({object:AnyObject,field:VariableName});
		}

		public function update():void
		{
			var o:Object;
			var i:uint = 0;
			var l:uint = _watching.length;
			var str:String = "";
			while(i < l)
			{
				o = _watching[i++];
				str += o.field + ": "+ o.object[o.field].toString() + "\n";
			}
			_text.text = str;
		}
		
		override protected function updateSize():void
		{
			super.updateSize();
			
			_text.width = _width-10;
			_text.height = _height-15;
		}
	}
}