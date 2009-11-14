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

	public class FlxPause extends Sprite
	{
		[Embed(source="key_x.png")] private var ImgKeyX:Class;
		[Embed(source="key_c.png")] private var ImgKeyC:Class;
		[Embed(source="key_mouse.png")] private var ImgKeyMouse:Class;
		[Embed(source="keys_arrows.png")] private var ImgKeysArrows:Class;
		[Embed(source="key_minus.png")] private var ImgKeyMinus:Class;
		[Embed(source="key_plus.png")] private var ImgKeyPlus:Class;
		[Embed(source="key_0.png")] private var ImgKey0:Class;
		[Embed(source="key_1.png")] private var ImgKey1:Class;

		public function FlxPause(X:uint,Y:uint,Zoom:uint,Help:Array)
		{
			super();

			visible = false;
			if(FlxG.width > 160)
			{
				scaleX = 2;
				scaleY = 2;
			}
			var w:uint = 160;
			var h:uint = 100;
			addChild(new Bitmap(new BitmapData(w,h,true,0xBF000000)));
			x = (X+FlxG.width/2)*Zoom-(w/2)*scaleX;
			y = (Y+FlxG.height/2)*Zoom-(h/2)*scaleY;
			
			var text:TextField = new TextField();
			text.width = w;
			text.height = 20;
			text.multiline = true;
			text.wordWrap = true;
			text.selectable = false;
			text.embedFonts = true;
			text.antiAliasType = AntiAliasType.NORMAL;
			text.gridFitType = GridFitType.PIXEL;
			text.defaultTextFormat = new TextFormat("system",16,0xffffff,null,null,null,null,null,"center");
			text.text = "GAME PAUSED";
			text.y = 7;
			addChild(text);
			
			//Icons for the pause screen
			var tmp2:Bitmap;
			var spc:uint = 14;
			tmp2 = addChild(new ImgKeyX) as Bitmap;
			tmp2.x = 4;
			tmp2.y = 36;
			tmp2 = addChild(new ImgKeyC) as Bitmap;
			tmp2.x = 4;
			tmp2.y = 36+spc;
			tmp2 = addChild(new ImgKeyMouse) as Bitmap;
			tmp2.x = 4;
			tmp2.y = 36+spc*2;
			tmp2 = addChild(new ImgKeysArrows) as Bitmap;
			tmp2.x = 4;
			tmp2.y = 36+spc*3;
			tmp2 = addChild(new ImgKeyMinus) as Bitmap;
			tmp2.x = 84;
			tmp2.y = 36;
			tmp2 = addChild(new ImgKeyPlus) as Bitmap;
			tmp2.x = 84;
			tmp2.y = 36+spc;
			tmp2 = addChild(new ImgKey0) as Bitmap;
			tmp2.x = 84;
			tmp2.y = 36+spc*2;
			tmp2 = addChild(new ImgKey1) as Bitmap;
			tmp2.x = 84;
			tmp2.y = 36+spc*3;
			
			text = new TextField();
			text.width = w/2;
			text.height = h-20;
			text.multiline = true;
			text.wordWrap = true;
			text.selectable = false;
			text.embedFonts = true;
			text.antiAliasType = AntiAliasType.NORMAL;
			text.gridFitType = GridFitType.PIXEL;
			text.defaultTextFormat = new TextFormat("system",8,0xffffff,null,null,null,null,null,"left",null,null,null,4);
			text.text = "";
			for(var i:uint = 0; i < Help.length; i++)
			{
				if(i == Help.length-1)
					text.appendText("          ");
				if(Help[i] != null) text.appendText(Help[i]);
				text.appendText("\n");
			}
			text.x = 15;
			text.y = 35;
			addChild(text);
			
			text = new TextField();
			text.width = w/2;
			text.height = h-20;
			text.multiline = true;
			text.wordWrap = true;
			text.selectable = false;
			text.embedFonts = true;
			text.antiAliasType = AntiAliasType.NORMAL;
			text.gridFitType = GridFitType.PIXEL;
			text.defaultTextFormat = new TextFormat("system",8,0xffffff,null,null,null,null,null,"left",null,null,null,4);
			text.text = "Sound Down\nSound Up\nMute\nConsole";
			text.x = 95;
			text.y = 35;	
			addChild(text);			
		}
		
	}
}