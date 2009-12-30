package org.flixel.data
{
	import org.flixel.*;
	
	import flash.ui.Mouse;

	/**
	 * This is a little built-in support visor that developers can optionally display.
	 * It has built in support for syndicating your game to StumbleUpon, Digg,
	 * Reddit, Del.icio.us, and Twitter.  It also has a PayPal donate button.
	 * This panel is automatically created by <code>FlxGame</code> and you
	 * can toggle the visibility via <code>FlxG</code>.
	 */
	public class FlxPanel extends FlxCore
	{
		[Embed(source="donate.png")] private var ImgDonate:Class;
		[Embed(source="stumble.png")] private var ImgStumble:Class;
		[Embed(source="digg.png")] private var ImgDigg:Class;
		[Embed(source="reddit.png")] private var ImgReddit:Class;
		[Embed(source="delicious.png")] private var ImgDelicious:Class;
		[Embed(source="twitter.png")] private var ImgTwitter:Class;
		[Embed(source="close.png")] private var ImgClose:Class;

		/**
		 * @private
		 */
		protected var _topBar:FlxSprite;
		/**
		 * @private
		 */
		protected var _mainBar:FlxSprite;
		/**
		 * @private
		 */
		protected var _bottomBar:FlxSprite;
		/**
		 * @private
		 */
		protected var _donate:FlxButton;
		/**
		 * @private
		 */
		protected var _stumble:FlxButton;
		/**
		 * @private
		 */
		protected var _digg:FlxButton;
		/**
		 * @private
		 */
		protected var _reddit:FlxButton;
		/**
		 * @private
		 */
		protected var _delicious:FlxButton;
		/**
		 * @private
		 */
		protected var _twitter:FlxButton;
		/**
		 * @private
		 */
		protected var _close:FlxButton;
		/**
		 * @private
		 */
		protected var _caption:FlxText;
		
		protected var _payPalID:String;
		/**
		 * @private
		 */
		protected var _payPalAmount:Number;
		/**
		 * @private
		 */
		protected var _gameTitle:String;
		/**
		 * @private
		 */
		protected var _gameURL:String;
		
		/**
		 * @private
		 */
		protected var _initialized:Boolean;
		/**
		 * @private
		 */
		protected var _closed:Boolean;
		
		/**
		 * @private
		 */
		protected var _ty:Number;
		/**
		 * @private
		 */
		protected var _s:Number;
		
		/**
		 * Constructor.
		 */
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
		
		/**
		 * Set up the support panel with donation and aggregation info.
		 * Like <code>show()</code> and <code>hide()</code> this function is usually
		 * called through <code>FlxGame</code> or <code>FlxG</code>, not directly.
		 * 
		 * @param	PayPalID		Your paypal username, usually your email address (leave it blank to disable donations).
		 * @param	PayPalAmount	The default amount of the donation.
		 * @param	GameTitle		The text that you would like to appear in the aggregation services (usually just the name of your game).
		 * @param	GameURL			The URL you would like people to use when trying to find your game.
		 */
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
		
		/**
		 * Updates and animates the panel.
		 */
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
		
		/**
		 * Actually draws the bar to the screen.
		 */
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
		
		/**
		 * Show the support panel.
		 * 
		 * @param	Top		Whether the visor should appear at the top or bottom of the screen.
		 */
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
		
		/**
		 * Hide the support panel.
		 */
		public function hide():void
		{
			if(y < 0) _ty = -21;
			else _ty = FlxG.height;
			Mouse.hide();
			visible = false;
		}
		
		/**
		 * Called when the player presses the Donate button.
		 */
		public function onDonate():void
		{
			FlxG.openURL("https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business="+encodeURIComponent(_payPalID)+"&item_name="+encodeURIComponent(_gameTitle+" Contribution ("+_gameURL)+")&currency_code=USD&amount="+_payPalAmount);
		}
		
		/**
		 * Called when the player presses the StumbleUpon button.
		 */
		public function onStumble():void
		{
			FlxG.openURL("http://www.stumbleupon.com/submit?url="+encodeURIComponent(_gameURL));
		}
		
		/**
		 * Called when the player presses the Digg button.
		 */
		public function onDigg():void
		{
			FlxG.openURL("http://digg.com/submit?url="+encodeURIComponent(_gameURL)+"&title="+encodeURIComponent(_gameTitle));
		}
		
		/**
		 * Called when the player presses the Reddit button.
		 */
		public function onReddit():void
		{
			FlxG.openURL("http://www.reddit.com/submit?url="+encodeURIComponent(_gameURL));
		}
		
		/**
		 * Called when the player presses the del.icio.us button.
		 */
		public function onDelicious():void
		{
			FlxG.openURL("http://delicious.com/save?v=5&amp;noui&amp;jump=close&amp;url="+encodeURIComponent(_gameURL)+"&amp;title="+encodeURIComponent(_gameTitle));
		}
		
		/**
		 * Called when the player presses the Twitter button.
		 */
		public function onTwitter():void
		{
			FlxG.openURL("http://twitter.com/home?status=Playing"+encodeURIComponent(" "+_gameTitle+" - "+_gameURL));
		}
		
		/**
		 * Called when the player presses the Close button.
		 */
		public function onClose():void
		{
			_closed = true;
			hide();
		}
	}
}
