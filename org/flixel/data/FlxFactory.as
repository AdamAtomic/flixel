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

	//@desc		This class handles the 8-bit style preloader
	public class FlxFactory extends MovieClip
	{
		[Embed(source="loading_bar.png")] private var ImgBar:Class;
		[Embed(source="loading_bit.png")] private var ImgBit:Class;
		
		private var Buffer:Sprite;
		private var bmpBar:Bitmap;
		private var bits:Array;
		
		//@desc	This should always be the name of your main project/document class (e.g. GravityHook)
		protected var className:String;
		//@desc	If you want to use site-locking, set your website URL here
		protected var myURL:String;
		
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
				txt.text = "Hi there!  It looks like somebody copied this game without my permission.  It is meant to be played ad-free!  If you would like to play it at my site with NO annoying ads, just click anywhere, or copy-paste this URL into your browser.\n\n"+myURL+"\n\nThanks, and have fun!";
				addChild(txt);
				
				txt.addEventListener(MouseEvent.CLICK,goToMyURL);
				tmp.addEventListener(MouseEvent.CLICK,goToMyURL);
				return;
			}
			
			Buffer = new Sprite();
            Buffer.scaleX = 2;
            Buffer.scaleY = 2;
            addChild(Buffer);
			bmpBar = new ImgBar();
			bmpBar.x = (stage.stageWidth/Buffer.scaleX-bmpBar.width)/2;
			bmpBar.y = (stage.stageHeight/Buffer.scaleY-bmpBar.height)/2;
			Buffer.addChild(bmpBar);
			bits = new Array();
			for(var i:uint = 0; i < 9; i++)
			{
				tmp = new ImgBit();
				tmp.visible = false;
				tmp.x = bmpBar.x+2+i*3;
				tmp.y = bmpBar.y+2;
				bits.push(tmp);
				Buffer.addChild(tmp);
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
	            for(i = bits.length-1; i >= 0; i--)
					bits.pop();
                removeChild(Buffer);
            }
            
            else
            {
            	var limit:uint = (root.loaderInfo.bytesLoaded/root.loaderInfo.bytesTotal)*10;
				for(i = 0; (i < limit) && (i < bits.length); i++)
					bits[i].visible = true;
            }
        }
	}
}