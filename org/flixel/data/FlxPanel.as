package org.flixel.data
{
	import org.flixel.*;
	
	import flash.ui.Mouse;

	public class FlxPanel extends FlxCore
	{
		[Embed(source="donate.png")] private var ImgDonate:Class;
		[Embed(source="stumble.png")] private var ImgStumble:Class;
		[Embed(source="digg.png")] private var ImgDigg:Class;
		[Embed(source="reddit.png")] private var ImgReddit:Class;
		[Embed(source="delicious.png")] private var ImgDelicious:Class;
		[Embed(source="twitter.png")] private var ImgTwitter:Class;
		[Embed(source="close.png")] private var ImgClose:Class;

		private var _topBar:FlxSprite;
		private var _mainBar:FlxSprite;
		private var _bottomBar:FlxSprite;
		private var _donate:FlxButton;
		private var _stumble:FlxButton;
		private var _digg:FlxButton;
		private var _reddit:FlxButton;
		private var _delicious:FlxButton;
		private var _twitter:FlxButton;
		private var _close:FlxButton;
		private var _caption:FlxText;
		
		private var _payPalID:String;
		private var _payPalAmount:Number;
		private var _gameTitle:String;
		private var _gameURL:String;
		
		private var _initialized:Boolean;
		private var _closed:Boolean;
		
		private var _ty:Number;
		private var _s:Number;
		
		public function FlxPanel()
		{
			super();
			y = -21;
			_ty = y;
			_closed = false;
			_initialized = false;
			_topBar = new FlxSprite();
			_topBar.createGraphic(FlxG.width,1,0x7fffffff);
			_topBar.scrollFactor.x = 0;
			_topBar.scrollFactor.y = 0;
			_mainBar = new FlxSprite();
			_mainBar.createGraphic(FlxG.width,19,0x7f000000);
			_mainBar.scrollFactor.x = 0;
			_mainBar.scrollFactor.y = 0;
			_bottomBar = new FlxSprite();
			_bottomBar.createGraphic(FlxG.width,1,0x7fffffff);
			_bottomBar.scrollFactor.x = 0;
			_bottomBar.scrollFactor.y = 0;
			_donate = new FlxButton(3,0,onDonate);
			_donate.loadGraphic(new FlxSprite(0,0,ImgDonate));
			_donate.scrollFactor.x = 0;
			_donate.scrollFactor.y = 0;
			_stumble = new FlxButton(FlxG.width/2-6-13-6-13-6,0,onStumble);
			_stumble.loadGraphic(new FlxSprite(0,0,ImgStumble));
			_stumble.scrollFactor.x = 0;
			_stumble.scrollFactor.y = 0;
			_digg = new FlxButton(FlxG.width/2-6-13-6,0,onDigg);
			_digg.loadGraphic(new FlxSprite(0,0,ImgDigg));
			_digg.scrollFactor.x = 0;
			_digg.scrollFactor.y = 0;
			_reddit = new FlxButton(FlxG.width/2-6,0,onReddit);
			_reddit.loadGraphic(new FlxSprite(0,0,ImgReddit));
			_reddit.scrollFactor.x = 0;
			_reddit.scrollFactor.y = 0;
			_delicious = new FlxButton(FlxG.width/2+7+6,0,onDelicious);
			_delicious.loadGraphic(new FlxSprite(0,0,ImgDelicious));
			_delicious.scrollFactor.x = 0;
			_delicious.scrollFactor.y = 0;
			_twitter = new FlxButton(FlxG.width/2+7+6+12+6,0,onTwitter);
			_twitter.loadGraphic(new FlxSprite(0,0,ImgTwitter));
			_twitter.scrollFactor.x = 0;
			_twitter.scrollFactor.y = 0;
			_caption = new FlxText(FlxG.width/2,0,FlxG.width/2-19,"");
			_caption.alignment = "right";
			_caption.scrollFactor.x = 0;
			_caption.scrollFactor.y = 0;
			_close = new FlxButton(FlxG.width-16,0,onClose);
			_close.loadGraphic(new FlxSprite(0,0,ImgClose));
			_close.scrollFactor.x = 0;
			_close.scrollFactor.y = 0;
			hide();
			_s = 50;
		}
		
		public function init(PayPalID:String,PayPalAmount:Number,GameTitle:String,GameURL:String,Caption:String):void
		{
			_payPalID = PayPalID;
			if(_payPalID.length <= 0) _donate.visible = false;
			_payPalAmount = PayPalAmount;
			_gameTitle = GameTitle;
			_gameURL = GameURL;
			_caption.text = Caption;
			_initialized = true;
		}
		
		override public function update():void
		{
			if(!_initialized) return;
			if(_ty != y)
			{
				if(y < _ty)
				{
					y += FlxG.elapsed*_s;
					if(y > _ty) y = _ty;
				}
				else
				{
					y -= FlxG.elapsed*_s;
					if(y < _ty) y = _ty;
				}
			}
			if((y <= -21) || (y > FlxG.height)) visible = false;
			_topBar.y = y;
			_mainBar.y = y+1;
			_bottomBar.y = y+20;
			_donate.y = y+4;
			_stumble.y = y+4;
			_digg.y = y+4;
			_reddit.y = y+4;
			_delicious.y = y+5;
			_twitter.y = y+4;
			_caption.y = y+4;
			_close.y = y+4;
			if(_donate.active) _donate.update();
			if(_stumble.active) _stumble.update();
			if(_digg.active) _digg.update();
			if(_reddit.active) _reddit.update();
			if(_delicious.active) _delicious.update();
			if(_twitter.active) _twitter.update();
			if(_caption.active) _caption.update();
			if(_close.active) _close.update();
		}
		
		override public function render():void
		{
			if(!_initialized) return;
			if(_topBar.visible) _topBar.render();
			if(_mainBar.visible) _mainBar.render();
			if(_bottomBar.visible) _bottomBar.render();
			if(_donate.visible) _donate.render();
			if(_stumble.visible) _stumble.render();
			if(_digg.visible) _digg.render();
			if(_reddit.visible) _reddit.render();
			if(_delicious.visible) _delicious.render();
			if(_twitter.visible) _twitter.render();
			if(_caption.visible) _caption.render();
			if(_close.visible) _close.render();
		}
		
		public function show(Top:Boolean=true):void
		{
			if(!_initialized)
			{
				FlxG.log("SUPPORT PANEL ERROR: Uninitialized.\nYou forgot to call FlxGame.setupSupportPanel()\nfrom your game constructor.");
				return;
			}
			if(_closed) return;
			if(Top)
			{
				y = -21;
				_ty = -1;
			}
			else
			{
				y = FlxG.height;
				_ty = FlxG.height-20;
			}
			Mouse.show();
			visible = true;
		}
		
		public function hide():void
		{
			if(y < 0) _ty = -21;
			else _ty = FlxG.height;
			Mouse.hide();
			visible = false;
		}
		
		public function onDonate():void
		{
			FlxG.openURL("https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business="+encodeURIComponent(_payPalID)+"&item_name="+encodeURIComponent(_gameTitle+" Contribution ("+_gameURL)+")&currency_code=USD&amount="+_payPalAmount);
		}
		
		public function onStumble():void
		{
			FlxG.openURL("http://www.stumbleupon.com/submit?url="+encodeURIComponent(_gameURL));
		}
		
		public function onDigg():void
		{
			FlxG.openURL("http://digg.com/submit?url="+encodeURIComponent(_gameURL)+"&title="+encodeURIComponent(_gameTitle));
		}
		
		public function onReddit():void
		{
			FlxG.openURL("http://www.reddit.com/submit?url="+encodeURIComponent(_gameURL));
		}
		
		public function onDelicious():void
		{
			FlxG.openURL("http://delicious.com/save?v=5&amp;noui&amp;jump=close&amp;url="+encodeURIComponent(_gameURL)+"&amp;title="+encodeURIComponent(_gameTitle));
		}
		
		public function onTwitter():void
		{
			FlxG.openURL("http://twitter.com/home?status=Playing"+encodeURIComponent(" "+_gameTitle+" - "+_gameURL));
		}
		
		public function onClose():void
		{
			_closed = true;
			hide();
		}
	}
}
