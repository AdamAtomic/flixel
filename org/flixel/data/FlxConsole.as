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
	import org.flixel.FlxMonitor;

	/**
	 * Contains all the logic for the developer console.
	 * This class is automatically created by FlxGame.
	 */
	public class FlxConsole extends Sprite
	{
		public var mtrUpdate:FlxMonitor;
		public var mtrRender:FlxMonitor;
		public var mtrTotal:FlxMonitor;
		
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
		protected var _fpsDisplay:TextField;
		/**
		 * @private
		 */
		protected var _extraDisplay:TextField;
		/**
		 * @private
		 */
		protected var _curFPS:uint;
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
			
			mtrUpdate = new FlxMonitor(16);
			mtrRender = new FlxMonitor(16);
			mtrTotal = new FlxMonitor(16);

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

			_fpsDisplay = new TextField();
			_fpsDisplay.width = 100;
			_fpsDisplay.x = tmp.width-100;
			_fpsDisplay.height = 20;
			_fpsDisplay.multiline = true;
			_fpsDisplay.wordWrap = true;
			_fpsDisplay.embedFonts = true;
			_fpsDisplay.selectable = false;
			_fpsDisplay.antiAliasType = AntiAliasType.NORMAL;
			_fpsDisplay.gridFitType = GridFitType.PIXEL;
			_fpsDisplay.defaultTextFormat = new TextFormat("system",16,0xffffff,true,null,null,null,null,"right");
			addChild(_fpsDisplay);
			
			_extraDisplay = new TextField();
			_extraDisplay.width = 100;
			_extraDisplay.x = tmp.width-100;
			_extraDisplay.height = 64;
			_extraDisplay.y = 20;
			_extraDisplay.alpha = 0.5;
			_extraDisplay.multiline = true;
			_extraDisplay.wordWrap = true;
			_extraDisplay.embedFonts = true;
			_extraDisplay.selectable = false;
			_extraDisplay.antiAliasType = AntiAliasType.NORMAL;
			_extraDisplay.gridFitType = GridFitType.PIXEL;
			_extraDisplay.defaultTextFormat = new TextFormat("system",8,0xffffff,true,null,null,null,null,"right");
			addChild(_extraDisplay);
			
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
			if(FlxG.mobile)
				return;
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
		public function toggle():void
		{
			if(FlxG.mobile)
			{
				log("FRAME TIMING DATA:\n=========================\n"+printTimingData()+"\n");
				return;
			}
			
			if(_YT == _by)
				_YT = _byt;
			else
			{
				_YT = _by;
				visible = true;
			}
		}
		
		/**
		 * Updates and/or animates the dev console.
		 */
		public function update():void
		{
			var total:Number = mtrTotal.average();
			_fpsDisplay.text = uint(1000/total) + " fps";
			_extraDisplay.text = printTimingData();
			
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
		
		/**
		 * Returns a string of frame timing data.
		 */
		protected function printTimingData():String
		{
			var up:uint = mtrUpdate.average();
			var rn:uint = mtrRender.average();
			var fx:uint = up+rn;
			var tt:uint = mtrTotal.average();
			return up + "ms update\n" + rn + "ms render\n" + fx + "ms flixel\n" + (tt-fx) + "ms flash\n" + tt + "ms total";
		}
	}
}