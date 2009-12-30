package org.flixel.data
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	
	import org.flixel.FlxG;

	/**
	 * This class handles the 8-bit style preloader.
	 */
	public class FlxFactory extends MovieClip
	{
		[Embed(source="loading_bar.png")] private var ImgBar:Class;
		[Embed(source="loading_bit.png")] private var ImgBit:Class;
		
		/**
		 * @private
		 */
		protected var _buffer:Sprite;
		/**
		 * @private
		 */
		protected var _bmpBar:Bitmap;
		/**
		 * @private
		 */
		protected var _bits:Array;
		
		/**
		 * This should always be the name of your main project/document class (e.g. GravityHook).
		 */
		public var className:String;
		/**
		 * Set this to your game's URL to use built-in site-locking.
		 */
		public var myURL:String;
		
		/**
		 * Constructor
		 */
		public function FlxFactory()
		{
			stop();
            stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//Check if we are on debug or release mode and set _DEBUG accordingly
            try
            {
                throw new Error("Setting global debug flag...");
            }
            catch(e:Error)
            {
                var re:RegExp = /\[.*:[0-9]+\]/;
                FlxG.debug = re.test(e.getStackTrace());
            }
			
			var tmp:Bitmap;
			if(!FlxG.debug && (myURL != null) && (myURL.length > 0))
			{
				tmp = new Bitmap(new BitmapData(stage.stageWidth,stage.stageHeight,true,0xFFFFFFFF));
				addChild(tmp);
				
				var fmt:TextFormat = new TextFormat();
				fmt.color = 0x000000;
				fmt.size = 16;
				fmt.align = "center";
				fmt.bold = true;
				
				var txt:TextField = new TextField();
				txt.width = tmp.width-16;
				txt.height = tmp.height-16;
				txt.y = 8;
				txt.multiline = true;
				txt.wordWrap = true;
				txt.defaultTextFormat = fmt;
				txt.text = "Hi there!  It looks like somebody copied this game without my permission.  If you would like to play it at my site with NO annoying ads, just click anywhere, or copy-paste this URL into your browser.\n\n"+myURL+"\n\nThanks, and have fun!";
				addChild(txt);
				
				txt.addEventListener(MouseEvent.CLICK,goToMyURL);
				tmp.addEventListener(MouseEvent.CLICK,goToMyURL);
				return;
			}
			
			_buffer = new Sprite();
            _buffer.scaleX = 2;
            _buffer.scaleY = 2;
            addChild(_buffer);
			_bmpBar = new ImgBar();
			_bmpBar.x = (stage.stageWidth/_buffer.scaleX-_bmpBar.width)/2;
			_bmpBar.y = (stage.stageHeight/_buffer.scaleY-_bmpBar.height)/2;
			_buffer.addChild(_bmpBar);
			_bits = new Array();
			for(var i:uint = 0; i < 9; i++)
			{
				tmp = new ImgBit();
				tmp.visible = false;
				tmp.x = _bmpBar.x+2+i*3;
				tmp.y = _bmpBar.y+2;
				_bits.push(tmp);
				_buffer.addChild(tmp);
			}
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function goToMyURL(event:MouseEvent=null):void
		{
			navigateToURL(new URLRequest("http://"+myURL));
		}
		
		private function onEnterFrame(event:Event):void
        {
        	var i:int;
            graphics.clear();
            if(framesLoaded == totalFrames)
            {
                removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                nextFrame();
                var mainClass:Class = Class(getDefinitionByName(className));
	            if(mainClass)
	            {
	                var app:Object = new mainClass();
	                addChild(app as DisplayObject);
	            }
	            for(i = _bits.length-1; i >= 0; i--)
					_bits.pop();
                removeChild(_buffer);
            }
            
            else
            {
            	var limit:uint = (root.loaderInfo.bytesLoaded/root.loaderInfo.bytesTotal)*10;
				for(i = 0; (i < limit) && (i < _bits.length); i++)
					_bits[i].visible = true;
            }
        }
	}
}