package org.flixel.aux.debug
{
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.flixel.aux.FlxWindow;
	
	public class Log extends FlxWindow
	{
		static protected const MAX_LOG_LINES:uint = 1024;
		
		protected var _text:TextField;
		protected var _lines:Array;
		
		public function Log(Title:String, Width:Number, Height:Number, Resizable:Boolean=true, Bounds:Rectangle=null, BGColor:uint=0xdfBABCBF, TopColor:uint=0xff4E5359)
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
			
			_lines = new Array();
			
			_text.text = "You can use FlxG.log() to print log messages."
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