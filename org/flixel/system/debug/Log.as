package org.flixel.system.debug
{
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import org.flixel.system.FlxWindow;
	
	
	public class Log extends FlxWindow
	{
		static protected const MAX_LOG_LINES:uint = 200;
		
		protected var _text:TextField;
		protected var _lines:Array;
		
		public function Log(Title:String, Width:Number, Height:Number, Resizable:Boolean=true, Bounds:Rectangle=null, BGColor:uint=0x7f7f7f7f, TopColor:uint=0x7f000000)
		{
			super(Title, Width, Height, Resizable, Bounds, BGColor, TopColor);
			
			_text = new TextField();
			_text.x = 2;
			_text.y = 15;
			_text.multiline = true;
			_text.wordWrap = true;
			_text.selectable = true;
			_text.defaultTextFormat = new TextFormat("Courier",12,0xffffff);
			addChild(_text);
			
			_lines = new Array();
		}
		
		override public function destroy():void
		{
			removeChild(_text);
			_text = null;
			_lines = null;
			super.destroy();
		}
		
		public function add(Text:String):void
		{
			if(_lines.length <= 0)
				_text.text = "";
			_lines.push(Text);
			if(_lines.length > MAX_LOG_LINES)
			{
				_lines.shift();
				var newText:String = "";
				for(var i:uint = 0; i < _lines.length; i++)
					newText += _lines[i]+"\n";
				_text.text = newText;
			}
			else
				_text.appendText(Text+"\n");
			_text.scrollV = _text.height;
		}
		
		override protected function updateSize():void
		{
			super.updateSize();
			
			_text.width = _width-10;
			_text.height = _height-15;
		}
	}
}