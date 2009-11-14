package org.flixel.data
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.flixel.FlxG;

	//@desc		Contains all the logic for the developer console
	public class FlxConsole extends Sprite
	{
		protected const MAX_CONSOLE_LINES:uint = 256;
		protected var _console:Sprite;
		protected var _text:TextField;
		protected var _fpsDisplay:TextField;
		protected var _fps:Array;
		protected var _curFPS:uint;
		protected var _lines:Array;
		protected var _Y:Number;
		protected var _YT:Number;
		protected var _fpsUpdate:Boolean;
		protected var _bx:int;
		protected var _by:int;
		protected var _byt:int;
		
		public function FlxConsole(X:uint,Y:uint,Zoom:uint)
		{
			super();
			
			visible = false;
			x = X*Zoom;
			_by = Y*Zoom;
			_byt = _by - FlxG.height*Zoom;
			_YT = _Y = y = _byt;
			var tmp:Bitmap = new Bitmap(new BitmapData(FlxG.width*Zoom,FlxG.height*Zoom,true,0x7F000000));
			addChild(tmp);
			
			_fps = new Array(8);
			_curFPS = 0;
			_fpsUpdate = true;

			_text = new TextField();
			_text.width = tmp.width;
			_text.height = tmp.height;
			_text.multiline = true;
			_text.wordWrap = true;
			_text.embedFonts = true;
			_text.antiAliasType = AntiAliasType.NORMAL;
			_text.gridFitType = GridFitType.PIXEL;
			_text.defaultTextFormat = new TextFormat("system",8,0xffffff);
			addChild(_text);

			_fpsDisplay = new TextField();
			_fpsDisplay.width = tmp.width;
			_fpsDisplay.height = 20;
			_fpsDisplay.multiline = true;
			_fpsDisplay.wordWrap = true;
			_fpsDisplay.embedFonts = true;
			_fpsDisplay.antiAliasType = AntiAliasType.NORMAL;
			_fpsDisplay.gridFitType = GridFitType.PIXEL;
			_fpsDisplay.defaultTextFormat = new TextFormat("system",16,0xffffff,true,null,null,null,null,"right");
			addChild(_fpsDisplay);
			
			_lines = new Array();
		}
		
		//@desc		Log data to the developer console
		//@param	Data		The data (in string format) that you wanted to write to the console
		public function log(Data:String):void
		{
			if(Data == null)
				Data = "NULL";
			trace(Data);
			_lines.push(Data);
			if(_lines.length > MAX_CONSOLE_LINES)
			{
				_lines.shift();
				var newText:String = "";
				for(var i:uint = 0; i < _lines.length; i++)
					newText += _lines[i]+"\n";
				_text.text = newText;
			}
			else
				_text.appendText(Data+"\n");
			_text.scrollV = _text.height;
		}
		
		//@desc		Shows/hides the console
		public function toggle():void
		{
			if(_YT == _by)
				_YT = _byt;
			else
			{
				_YT = _by;
				visible = true;
			}
		}
		
		//@desc		Updates and/or animates the dev console
		public function update():void
		{
			if(visible)
			{
				_fps[_curFPS] = 1/FlxG.elapsed;
				if(++_curFPS >= _fps.length) _curFPS = 0;
				_fpsUpdate = !_fpsUpdate;
				if(_fpsUpdate)
				{
					var fps:uint = 0;
					for(var i:uint = 0; i < _fps.length; i++)
						fps += _fps[i];
					_fpsDisplay.text = Math.floor(fps/_fps.length)+" fps";
				}
			}
			if(_Y < _YT)
				_Y += FlxG.height*10*FlxG.elapsed;
			else if(_Y > _YT)
				_Y -= FlxG.height*10*FlxG.elapsed;
			if(_Y > _by)
				_Y = _by;
			else if(_Y < _byt)
			{
				_Y = _byt;
				visible = false;
			}
			y = Math.floor(_Y);
		}
	}
}