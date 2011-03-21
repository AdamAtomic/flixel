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

	/**
	 * Contains all the logic for the developer console.
	 * This class is automatically created by FlxGame.
	 */
	public class FlxConsole extends Sprite {
		public var stats:Stats;
		public var updateMS:int;
		public var renderMS:int;
		
		/**
		 * @private
		 */
		protected const MAX_CONSOLE_LINES:uint = 256;
		/**
		 * @private
		 */
		protected var _console:Sprite;
		/**
		 * @private
		 */
		protected var _text:TextField;
		/**
		 * @private
		 */
		protected var _lines:Array;
		/**
		 * @private
		 */
		protected var _Y:Number;
		/**
		 * @private
		 */
		protected var _YT:Number;
		/**
		 * @private
		 */
		protected var _bx:int;
		/**
		 * @private
		 */
		protected var _by:int;
		/**
		 * @private
		 */
		protected var _byt:int;
		
		/**
		 * Constructor
		 * 
		 * @param	X		X position of the console
		 * @param	Y		Y position of the console
		 * @param	Zoom	The game's zoom level
		 */
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
			
			_text = new TextField();
			_text.width = tmp.width;
			_text.height = tmp.height;
			_text.multiline = true;
			_text.wordWrap = true;
			_text.embedFonts = true;
			_text.selectable = false;
			_text.antiAliasType = AntiAliasType.NORMAL;
			_text.gridFitType = GridFitType.PIXEL;
			_text.defaultTextFormat = new TextFormat("system",8,0xffffff);
			addChild(_text);
			
			stats = new Stats();
			addChild(stats);
			stats.init(Zoom);
			
			_lines = new Array();
		}
		
		/**
		 * Logs data to the developer console
		 * 
		 * @param	Text	The text that you wanted to write to the console
		 */
		public function log(Text:String):void
		{
			if(Text == null)
				Text = "NULL";
			trace(Text);
			_lines.push(Text);
			if(_lines.length > MAX_CONSOLE_LINES)
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
		
		/**
		 * Shows/hides the console.
		 */
		public function toggle():void {
			if (_YT == _by) _YT = _byt;
			else {
				_YT = _by;
				visible = true;
			}
		}
		
		/**
		 * Updates and/or animates the dev console.
		 */
		public function update():void {
			var _anim:Number = FlxG.height*10*FlxG.elapsed;
			if (_Y < _YT) _Y += _anim;
			else if (_Y > _YT) _Y -= _anim;
			
			if (_Y > _by) _Y = _by;
			else if (_Y < _byt) {
				_Y = _byt;
				visible = false;
			}
			y = Math.floor(_Y);
			stats.update(updateMS, renderMS);
		}
		
		public function destroy():void {
			while (numChildren > 0) removeChildAt(0);
			stats.destroy();
			_console = null;
			_text = null;
			_lines.length = 0;
			_lines = null;
		}
	}
}