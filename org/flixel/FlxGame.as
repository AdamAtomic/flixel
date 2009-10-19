package org.flixel
{
	import org.flixel.data.FlxLogoPixel;
	import org.flixel.data.FlxPanel;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.getTimer;

	public class FlxGame extends Sprite
	{
		[Embed(source="data/nokiafc22.ttf",fontFamily="system")] private var junk:String;
		[Embed(source="data/poweredby.png")] private var ImgPoweredBy:Class;
		[Embed(source="data/key_x.png")] private var ImgKeyX:Class;
		[Embed(source="data/key_c.png")] private var ImgKeyC:Class;
		[Embed(source="data/key_mouse.png")] private var ImgKeyMouse:Class;
		[Embed(source="data/keys_arrows.png")] private var ImgKeysArrows:Class;
		[Embed(source="data/key_minus.png")] private var ImgKeyMinus:Class;
		[Embed(source="data/key_plus.png")] private var ImgKeyPlus:Class;
		[Embed(source="data/key_0.png")] private var ImgKey0:Class;
		[Embed(source="data/key_1.png")] private var ImgKey1:Class;
		[Embed(source="data/beep.mp3")] private var SndBeep:Class;
		[Embed(source="data/flixel.mp3")] private var SndFlixel:Class;
		
		private const MAX_CONSOLE_LINES:uint = 256;
		private const MAX_ELAPSED:Number = 0.0333;
		
		//startup
		private var _iState:Class;
		private var _created:Boolean;
		
		//basic display stuff
		private var _buffer:Sprite;
		private var _bmpBack:Bitmap;
		private var _bmpFront:Bitmap;
		private var _flipped:Boolean;
		private var _z:uint;
		private var _gx:int;
		private var _gy:int;
		private var _bgc:Number;
		private var _frame:Class;
		private var _curState:FlxState;
		private var _cursor:Bitmap;
		
		//basic update stuff
		private var _elapsed:Number;
		private var _total:uint;
		private var _paused:Boolean;
		
		//console stuff
		private var _console:Sprite;
		private var _consoleText:TextField;
		private var _consoleFPS:TextField;
		private var _FPS:Array;
		private var _curFPS:uint;
		private var _consoleLines:Array;
		private var _consoleY:Number;
		private var _consoleYT:Number;
		private var _fpsUpdate:Boolean;
		
		//pause stuff
		private var _focusPopup:Sprite;
		private var _focusField:TextField;
		private var _help:Array;
		
		//sound tray stuff
		private var _soundTray:Sprite;
		private var _soundTrayTimer:Number;
		private var _soundTrayBars:Array;
		
		//logo stuff
		private var _f:FlxArray;
		private var _fc:uint;
		private var _logoComplete:Boolean;
		private var _logoTimer:Number;
		private var _poweredBy:Bitmap;
		private var _logoFade:Bitmap;
		private var _fSound:Class;
		private var _showLogo:Boolean;
		
		//quake stuff
		private var _quakeIntensity:Number;
		private var _quakeLength:Number;
		private var _quakeTimer:Number;
		
		//flash and fade stuff
		private var _flash:Bitmap;
		private var _flashHelper:Number;
		private var _flashDelay:Number;
		private var _flashComplete:Function;
		private var _fade:Bitmap;
		private var _fadeHelper:Number;
		private var _fadeDelay:Number;
		private var _fadeComplete:Function;
		
		private var _panel:FlxPanel;
		
		//@desc		Constructor
		//@param	GameSizeX		The width of your game in pixels (e.g. 320)
		//@param	GameSizeY		The height of your game in pixels (e.g. 240)
		//@param	InitialState	The class name of the state you want to create and switch to first (e.g. MenuState)
		//@param	Zoom			The level of zoom (e.g. 2 means all pixels are now rendered twice as big)
		//@param	BGColor			The color of the Flash app's background
		//@param	FlixelColor		The color of the great big 'f' in the flixel logo
		//@param	FlixelSound		The sound that is played over the flixel 'f' logo
		//@param	Frame			If you want you can add a little graphical frame to the outside edges of your game
		//@param	ScreenOffsetX	If you use a frame, you're probably going to want to scoot your game down to fit properly inside it
		//@param	ScreenOffsetY	These variables do exactly that!		
		public function FlxGame(GameSizeX:uint,GameSizeY:uint,InitialState:Class,Zoom:uint=2,BGColor:Number=0xff000000,ShowFlixelLogo:Boolean=true,FlixelColor:Number=0xffffffff,FlixelSound:Class=null,Frame:Class=null,ScreenOffsetX:uint=0,ScreenOffsetY:uint=0)
		{
			_z = Zoom;
			_gx = ScreenOffsetX;
			_gy = ScreenOffsetY;
			_bgc = BGColor;
			_fc = FlixelColor;
			FlxG.setGameData(GameSizeX,GameSizeY,switchState,log,quake,flash,fade,setCursor,showSupportPanel,hideSupportPanel);
			_created = false;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_elapsed = 0;
			_total = 0;
			_fpsUpdate = true;
			flash.ui.Mouse.hide();
			_logoComplete = false;
			_f = null;
			_quakeTimer = 0;
			_quakeIntensity = 0;
			_quakeLength = 0;
			if(FlixelSound == null)
				_fSound = SndFlixel;
			else
				_fSound = FlixelSound;
			_curState = null;
			_frame = Frame;
			_iState = InitialState;
			_FPS = new Array(8);
			_curFPS = 0;
			_paused = false;
			_help = new Array();
			_help.push("A Button");
			_help.push("B Button");
			_help.push("Mouse");
			_help.push("Move");
			_showLogo = ShowFlixelLogo;
			_panel = new FlxPanel();
		}
		
		//@desc		Sets up the strings that are displayed on the left side of the pause game popup
		//@param	X		What to display next to the X button
		//@param	C		What to display next to the C button
		//@param	Mouse	What to display next to the mouse icon
		//@param	Arrows	What to display next to the arrows icon
		protected function help(X:String=null,C:String=null,Mouse:String=null,Arrows:String=null):void
		{
			if(X != null)
				_help[0] = X;
			if(C != null)
				_help[1] = C;
			if(Mouse != null)
				_help[2] = Mouse;
			if(Arrows != null)
				_help[3] = Arrows;
		}
		
		//@desc		Switch from one FlxState to another
		//@param	State		The class name of the state you want (e.g. PlayState)
		private function switchState(state:Class):void
		{
			_panel.hide();
			FlxG.unfollow();
			FlxG.resetKeys();
			_quakeTimer = 0;
			_buffer.x = 0;
			_buffer.y = 0;
			if(_cursor != null)
			{
				_buffer.removeChild(_cursor);
				_cursor = null;
			}
			
			var newState:FlxState = new state;
			_buffer.addChild(newState);
			if(_curState != null)
			{
				_buffer.swapChildren(newState,_curState);
				_buffer.removeChild(_curState);
				_curState.destroy();
			}
			_fade.visible = false;
			_curState = newState;
		}
		
		//@desc		This function is only used by the FlxGame class to do important internal management stuff
		private function onKeyUp(event:KeyboardEvent):void
		{
			var code:String = String.fromCharCode(event.charCode);
			if (event.keyCode == 37) {
				FlxG.kLeft = false;
				FlxG.releaseKey(0); //left
		    } else if (event.keyCode == 39) {
		    	FlxG.kRight = false;
		        FlxG.releaseKey(1); //right
		    } else if (event.keyCode == 38) {
		    	FlxG.kUp = false;
		        FlxG.releaseKey(2); //up
		    } else if (event.keyCode == 40) {
		    	FlxG.kDown = false;
		        FlxG.releaseKey(3); //down
		    } else if ((code == 'x') || (code == 'X') || (event.keyCode == Keyboard.TAB)) {
		    	FlxG.kA = false;
		    	FlxG.releaseKey(4); //A
		    } else if ((code == 'c') || (code == 'C') || (event.keyCode == Keyboard.SPACE)) {
		    	FlxG.kB = false;
		    	FlxG.releaseKey(5); //B
		    } else if ((code == '0') || (code == ')')) {
		    	FlxG.setMute(!FlxG.getMute());
		    	showSoundTray();
		    } else if ((code == '-') || (code == '_')) {
		    	FlxG.setMute(false);
		    	FlxG.setMasterVolume(FlxG.getMasterVolume() - 0.1);
		    	showSoundTray();
		    } else if ((code == '+') || (code == '=')) {
		    	FlxG.setMute(false);
		    	FlxG.setMasterVolume(FlxG.getMasterVolume() + 0.1);
		    	showSoundTray();
		    } else if ((code == '1') || (code == '!') || (code == '~') || (code == '`')) {
		    	toggleConsole();
		    } else if(event.keyCode == Keyboard.ESCAPE) {
		    	stage.displayState = "fullScreen";
		    	var w:uint = FlxG.width*_z;
		    	var h:uint = FlxG.height*_z;
		    	if(_frame != null)
		    	{
		    		var bmp:Bitmap = new _frame();
		    		w = bmp.width*_z;
		    		h = bmp.height*_z;
		    	}
		    	x = (stage.fullScreenWidth - w)/2;
		    	y = (stage.fullScreenHeight - h)/2;
		    }
		}
		
		//@desc		This function is only used by the FlxGame class to do important internal management stuff
		private function onKeyDown(event:KeyboardEvent):void
		{
			var code:String = String.fromCharCode(event.charCode);
			if (event.keyCode == 37) {
				FlxG.kLeft = true;
		        FlxG.pressKey(0); //left
		    } else if (event.keyCode == 39) {
		    	FlxG.kRight = true;
		        FlxG.pressKey(1); //right
		    } else if (event.keyCode == 38) {
		    	FlxG.kUp = true;
		        FlxG.pressKey(2); //up
		    } else if (event.keyCode == 40) {
		    	FlxG.kDown = true;
		        FlxG.pressKey(3); //down
		    } else if ((code == 'x') || (code == 'X') || (event.keyCode == Keyboard.TAB)) {
		    	FlxG.kA = true;
		    	FlxG.pressKey(4); //A
		    } else if ((code == 'c') || (code == 'C') || (event.keyCode == Keyboard.SPACE)) {
		    	FlxG.kB = true;
		    	FlxG.pressKey(5); //B
		    }
		}
		
		//@desc		This function is only used by the FlxGame class to do important internal management stuff
		private function onMouseUp(event:MouseEvent):void
		{
			FlxG.kMouse = false;
			FlxG.releaseKey(6);
		}
		
		//@desc		This function is only used by the FlxGame class to do important internal management stuff
		private function onMouseDown(event:MouseEvent):void
		{
			FlxG.kMouse = true;
			FlxG.pressKey(6);
		}
		
		//@desc		This function is only used by the FlxGame class to do important internal management stuff
		private function onFocus(event:Event=null):void
		{
			if(!_panel.visible) flash.ui.Mouse.hide();
			_focusPopup.visible = false;
			FlxG.resetKeys();
			_paused = false;
			FlxG.playMusic();
			stage.frameRate = 90;
		}
		
		//@desc		This function is only used by the FlxGame class to do important internal management stuff
		private function onFocusLost(event:Event=null):void
		{
			if((x != 0) || (y != 0))
			{
				x = 0;
				y = 0;
			}
			flash.ui.Mouse.show();
			_focusPopup.visible = true;
			_paused = true;
			FlxG.pauseMusic();
			stage.frameRate = 10;
		}
		
		//@desc		This is the main game loop, but only once creation and logo playback is finished
		private function onEnterFrame(event:Event):void
		{
			var i:uint;
			
			//Frame timing
			var t:uint = getTimer();
			_elapsed = (t-_total)/1000;
			_total = t;
			FlxG.elapsed = _elapsed;
			if(FlxG.elapsed > MAX_ELAPSED)
				FlxG.elapsed = MAX_ELAPSED;
			
			if(_logoComplete)
			{
				//Animate the support panel
				_panel.update();
				
				//Animate the sound tray
				if(_soundTrayTimer > 0)
					_soundTrayTimer -= _elapsed;
				else if(_soundTray.y > -_soundTray.height)
				{
					_soundTray.y -= _elapsed*FlxG.height*2;
					if(_soundTray.y < -_soundTray.height)
						_soundTray.visible = false;
				}
				
				//Animate the popdown console
				if(_console.visible)
				{
					_FPS[_curFPS] = 1/_elapsed;
					if(++_curFPS >= _FPS.length) _curFPS = 0;
					_fpsUpdate = !_fpsUpdate;
					if(_fpsUpdate)
					{
						var fps:uint = 0;
						for(i = 0; i < _FPS.length; i++)
							fps += _FPS[i];
						_consoleFPS.text = Math.floor(fps/_FPS.length)+" fps";
					}
				}
				if(_consoleY < _consoleYT)
					_consoleY += FlxG.height*10*_elapsed;
				else if(_consoleY > _consoleYT)
					_consoleY -= FlxG.height*10*_elapsed;
				if(_consoleY > _gy*_z)
					_consoleY = _gy*_z;
				else if(_consoleY < _gy*_z-FlxG.height*_z)
				{
					_consoleY = _gy*_z-FlxG.height*_z;
					_console.visible = false;
				}
				_console.y = Math.floor(_consoleY);
				
				//State updating
				if(!_paused)
				{
					FlxG.updateKeys();
					if(_cursor != null)
					{
						_cursor.x = FlxG.mouse.x+FlxG.scroll.x;
						_cursor.y = FlxG.mouse.y+FlxG.scroll.y;
					}
					FlxG.doFollow();
					_curState.update();
					
					//Quakes
					if(_quakeTimer > 0)
					{
						_quakeTimer += _elapsed;
						if(_quakeTimer > _quakeLength)
						{
							_quakeTimer = 0;
							_buffer.x = 0;
							_buffer.y = 0;
						}
						else
						{
							_buffer.x = (Math.random()*_quakeIntensity*FlxG.width*2-_quakeIntensity*FlxG.width)*_z;
							_buffer.y = (Math.random()*_quakeIntensity*FlxG.height*2-_quakeIntensity*FlxG.height)*_z;
						}
					}
					
					//Flashes & Fades
					if(_flash.visible)
					{
						_flashHelper -= _elapsed/_flashDelay;
						_flash.alpha = _flashHelper;
						if(_flash.alpha <= 0)
						{
							_flash.visible = false;
							if(_flashComplete != null)
								_flashComplete();
						}
					}
					if(_fade.visible && (_fade.alpha != 1))
					{
						_fadeHelper += _elapsed/_fadeDelay;
						_fade.alpha = _fadeHelper;
						if(_fade.alpha >= 1)
						{
							_fade.alpha = 1;
							if(_fadeComplete != null)
								_fadeComplete();
						}
					}
					
					//Rendering
					if(_flipped)
					{
						_bmpFront.bitmapData.fillRect(new Rectangle(0,0,_bmpFront.width,_bmpFront.height),_bgc);
						FlxG.buffer = _bmpFront.bitmapData;
					}
					else
					{
						_bmpBack.bitmapData.fillRect(new Rectangle(0,0,_bmpBack.width,_bmpBack.height),_bgc);
						FlxG.buffer = _bmpBack.bitmapData;
					}
					_curState.render();
					_panel.render();
					_bmpBack.visible = !(_bmpFront.visible = _flipped);
					_flipped = !_flipped;
				}
			}
			else if(_created)
			{
				if(!_showLogo)
				{
					_logoComplete = true;
					switchState(_iState);
				}
				else
				{
					if(_f == null)
					{
						var tmp:Bitmap;
						_f = new FlxArray();
						var scale:uint = 1;
						if(FlxG.height > 200)
							scale = 2;
						var pixelSize:uint = 32*scale;
						var top:int = FlxG.height*_z/2-pixelSize*2;
						var left:int = FlxG.width*_z/2-pixelSize;
						
						_f.push(addChild(new FlxLogoPixel(left+pixelSize,top,pixelSize,0,_fc)) as FlxLogoPixel);
						_f.push(addChild(new FlxLogoPixel(left,top+pixelSize,pixelSize,1,_fc)) as FlxLogoPixel);
						_f.push(addChild(new FlxLogoPixel(left,top+pixelSize*2,pixelSize,2,_fc)) as FlxLogoPixel);
						_f.push(addChild(new FlxLogoPixel(left+pixelSize,top+pixelSize*2,pixelSize,3,_fc)) as FlxLogoPixel);
						_f.push(addChild(new FlxLogoPixel(left,top+pixelSize*3,pixelSize,4,_fc)) as FlxLogoPixel);
						
						_poweredBy = new ImgPoweredBy;
						_poweredBy.scaleX = scale;
						_poweredBy.scaleY = scale;
						_poweredBy.x = FlxG.width*_z/2-_poweredBy.width/2;
						_poweredBy.y = top+pixelSize*4+16;
						var ct:ColorTransform = new ColorTransform();
						ct.color = _fc;
						_poweredBy.bitmapData.colorTransform(new Rectangle(0,0,_poweredBy.width,_poweredBy.height),ct);
						addChild(_poweredBy);
						
						_logoFade = addChild(new Bitmap(new BitmapData(FlxG.width*_z,FlxG.height*_z,true,0xFF000000))) as Bitmap;
						_logoFade.x = _gx*_z;
						_logoFade.y = _gy*_z;
						
						if(_fSound != null)
							(new _fSound).play(0,0,new SoundTransform(0.35,0));
					}
					
					_logoTimer += _elapsed;
					for(i = 0; i < _f.length; i++)
						_f[i].update();
					if(_logoFade.alpha > 0)
						_logoFade.alpha -= _elapsed*0.5;
						
					if(_logoTimer > 2)
					{
						removeChild(_poweredBy);
						for(i = 0; i < _f.length; i++)
							removeChild(_f[i]);
						_f.clear();
						removeChild(_logoFade);
						switchState(_iState);
						_logoComplete = true;
					}
				}
			}
			else if(root != null)
			{
				//Create the game instance and associated classes
				stage.showDefaultContextMenu = false;
				stage.scaleMode = StageScaleMode.NO_SCALE;
	            stage.align = StageAlign.TOP_LEFT;
	            stage.frameRate = 90;
	            _buffer = new Sprite();
	            _buffer.scaleX = _z;
	            _buffer.scaleY = _z;
	            addChild(_buffer);
				
				_bmpBack = new Bitmap(new BitmapData(FlxG.width,FlxG.height,true,_bgc));
				_bmpBack.x = _gx;
				_bmpBack.y = _gy;
				_buffer.addChild(_bmpBack);
				
				_bmpFront = new Bitmap(new BitmapData(_bmpBack.width,_bmpBack.height,true,_bgc));
				_bmpFront.x = _bmpBack.x;
				_bmpFront.y = _bmpBack.y;
				_buffer.addChild(_bmpFront);
				
				_flipped = false;
				
				_flash = new Bitmap(new BitmapData(FlxG.width*_z,FlxG.height*_z));
				_flash.x = _gx*_z;
				_flash.y = _gy*_z;
				_flash.visible = false;
				addChild(_flash);
				
				_fade = new Bitmap(new BitmapData(FlxG.width*_z,FlxG.height*_z));
				_fade.x = _gx*_z;
				_fade.y = _gy*_z;
				_fade.visible = false;
				addChild(_fade);
				
				_console = new Sprite();
				_console.visible = false;
				_console.x = _gx*_z;
				_console.y = _gy*_z-FlxG.height*_z;
				_consoleYT = _consoleY = _console.y;
				tmp = new Bitmap(new BitmapData(FlxG.width*_z,FlxG.height*_z,true,0x7F000000));
				_console.addChild(tmp);

				_consoleText = new TextField();
				_consoleText.width = tmp.width;
				_consoleText.height = tmp.height;
				_consoleText.multiline = true;
				_consoleText.wordWrap = true;
				_consoleText.embedFonts = true;
				_consoleText.antiAliasType = AntiAliasType.NORMAL;
				_consoleText.gridFitType = GridFitType.PIXEL;
				_consoleText.defaultTextFormat = new TextFormat("system",8,0xffffff);
				_console.addChild(_consoleText);

				_consoleFPS = new TextField();
				_consoleFPS.width = tmp.width;
				_consoleFPS.height = 20;
				_consoleFPS.multiline = true;
				_consoleFPS.wordWrap = true;
				_consoleFPS.embedFonts = true;
				_consoleFPS.antiAliasType = AntiAliasType.NORMAL;
				_consoleFPS.gridFitType = GridFitType.PIXEL;
				_consoleFPS.defaultTextFormat = new TextFormat("system",16,0xffffff,true,null,null,null,null,"right");
				_console.addChild(_consoleFPS);
				
				_consoleLines = new Array();
				
				addChild(_console);
				
				log("flixel v1.25");
				log("---------------------------------------");
				
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				
				//Pause screen popup
				_focusPopup = new Sprite();
				_focusPopup.visible = false;
				if(FlxG.width > 160)
				{
					_focusPopup.scaleX = 2;
					_focusPopup.scaleY = 2;
				}
				_focusPopup.x = _gx*_z+8*_z;
				_focusPopup.y = _gy*_z+FlxG.height*_z/4;
				tmp = new Bitmap(new BitmapData(160,100,true,0xBF000000));
				_focusPopup.x = (_gx+FlxG.width/2)*_z-(tmp.width/2)*_focusPopup.scaleX;
				_focusPopup.y = (_gy+FlxG.height/2)*_z-(tmp.height/2)*_focusPopup.scaleY;
				_focusPopup.addChild(tmp);
				
				var text:TextField = new TextField();
				text.width = tmp.width;
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
				_focusPopup.addChild(text);
				
				//Icons for the pause screen
				var tmp2:Bitmap;
				tmp2 = _focusPopup.addChild(new ImgKeyX) as Bitmap;
				tmp2.x = 4;
				tmp2.y = 36;
				tmp2 = _focusPopup.addChild(new ImgKeyC) as Bitmap;
				tmp2.x = 4;
				tmp2.y = 36+14;
				tmp2 = _focusPopup.addChild(new ImgKeyMouse) as Bitmap;
				tmp2.x = 4;
				tmp2.y = 36+14+14;
				tmp2 = _focusPopup.addChild(new ImgKeysArrows) as Bitmap;
				tmp2.x = 4;
				tmp2.y = 36+14+14+14;
				tmp2 = _focusPopup.addChild(new ImgKeyMinus) as Bitmap;
				tmp2.x = 84;
				tmp2.y = 36;
				tmp2 = _focusPopup.addChild(new ImgKeyPlus) as Bitmap;
				tmp2.x = 84;
				tmp2.y = 36+14;
				tmp2 = _focusPopup.addChild(new ImgKey0) as Bitmap;
				tmp2.x = 84;
				tmp2.y = 36+14+14;
				tmp2 = _focusPopup.addChild(new ImgKey1) as Bitmap;
				tmp2.x = 84;
				tmp2.y = 36+14+14+14;
				
				text = new TextField();
				text.width = tmp.width/2;
				text.height = tmp.height-20;
				text.multiline = true;
				text.wordWrap = true;
				text.selectable = false;
				text.embedFonts = true;
				text.antiAliasType = AntiAliasType.NORMAL;
				text.gridFitType = GridFitType.PIXEL;
				text.defaultTextFormat = new TextFormat("system",8,0xffffff,null,null,null,null,null,"left",null,null,null,4);
				text.text = "";
				for(i = 0; i < _help.length; i++)
				{
					if(i == _help.length-1)
						text.appendText("          ");
					if(_help[i] != null) text.appendText(_help[i]);
					text.appendText("\n");
				}
				text.x = 15;
				text.y = 35;
				_focusPopup.addChild(text);
				
				text = new TextField();
				text.width = tmp.width/2;
				text.height = tmp.height-20;
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
				_focusPopup.addChild(text);			
				
				addChild(_focusPopup);
				
				//Sound Tray popup
				_soundTray = new Sprite();
				_soundTray.visible = false;
				_soundTray.scaleX = 2;
				_soundTray.scaleY = 2;
				tmp = new Bitmap(new BitmapData(80,30,true,0x7F000000));
				_soundTray.x = (_gx+FlxG.width/2)*_z-(tmp.width/2)*_soundTray.scaleX;
				_soundTray.addChild(tmp);
				
				text = new TextField();
				text.width = tmp.width;
				text.height = tmp.height;
				text.multiline = true;
				text.wordWrap = true;
				text.selectable = false;
				text.embedFonts = true;
				text.antiAliasType = AntiAliasType.NORMAL;
				text.gridFitType = GridFitType.PIXEL;
				text.defaultTextFormat = new TextFormat("system",8,0xffffff,null,null,null,null,null,"center");;
				_soundTray.addChild(text);
				text.text = "VOLUME";
				text.y = 16;
				
				var bx:uint = 10;
				var by:uint = 14;
				_soundTrayBars = new Array();
				for(i = 0; i < 10; i++)
				{
					tmp = new Bitmap(new BitmapData(4,i+1,false,0xffffff));
					tmp.x = bx;
					tmp.y = by;
					_soundTrayBars.push(_soundTray.addChild(tmp));
					bx += 6;
					by--;
				}
				addChild(_soundTray);

				//FOCUS CONTROL
				stage.addEventListener(Event.DEACTIVATE, onFocusLost);
				stage.addEventListener(Event.ACTIVATE, onFocus);

				if(_frame != null)
				{
					var bmp:Bitmap = new _frame;
					bmp.scaleX = _z;
					bmp.scaleY = _z;
					addChild(bmp);
				}
				
				_created = true;
				
				_logoTimer = 0;
			}
		}
		
		//@desc		Log data to the developer console
		//@param	Data		The data (in string format) that you wanted to write to the console
		private function log(Data:String):void
		{
			if(Data == null)
				Data = "ERROR: NULL GAME LOG MESSAGE";
			
			if(_console == null)
			{
				trace(Data);
				return;
			}
			else
			{
				_consoleLines.push(Data);
				if(_consoleLines.length > MAX_CONSOLE_LINES)
				{
					_consoleLines.shift();
					var newText:String = "";
					for(var i:uint = 0; i < _consoleLines.length; i++)
						newText += _consoleLines[i]+"\n";
					_consoleText.text = newText;
				}
				else
					_consoleText.appendText(Data+"\n");
				_consoleText.scrollV = _consoleText.height;
			}
		}
		
		//@desc		This function is only used by the FlxGame class to do important internal management stuff
		private function toggleConsole():void
		{
			if(_consoleYT == _gy*_z)
				_consoleYT = _gy*_z-FlxG.height*_z;
			else
			{
				_consoleYT = _gy*_z;
				_console.visible = true;
			}
		}
		
		//@desc		Shake the screen
		//@param	Intensity	Percentage of screen size representing the maximum distance that the screen can move during the 'quake'
		//@param	Duration	The length in seconds that the "quake" should last
		private function quake(Intensity:Number,Duration:Number=0.5):void
		{
			_quakeIntensity = Intensity;
			_quakeLength = Duration;
			_quakeTimer = 0.01;
		}
		
		//@desc		Temporarily fill the screen with a certain color, then fade it out
		//@param	Color			The color you want to use
		//@param	Duration		How long it takes for the flash to fade
		//@param	FlashComplete	A function you want to run when the flash finishes
		//@param	Force			Force the effect to reset
		private function flash(Color:uint, Duration:Number=1, FlashComplete:Function=null, Force:Boolean=false):void
		{
			if(Color == 0)
			{
				_flash.visible = false;
				return;
			}
			if(!Force && _flash.visible) return;
			_flash.bitmapData.fillRect(new Rectangle(0,0,_flash.width,_flash.height),Color);
			_flashDelay = Duration;
			_flashComplete = FlashComplete;
			_flashHelper = 1;
			_flash.alpha = 1;
			_flash.visible = true;
		}
		
		//@desc		Fade the screen out to this color
		//@param	Color			The color you want to use
		//@param	Duration		How long it should take to fade the screen out
		//@param	FadeComplete	A function you want to run when the fade finishes
		//@param	Force			Force the effect to reset
		private function fade(Color:uint, Duration:Number=1, FadeComplete:Function=null, Force:Boolean=false):void
		{
			if(Color == 0)
			{
				_fade.visible = false;
				return;
			}
			if(!Force && _fade.visible) return;
			_fade.bitmapData.fillRect(new Rectangle(0,0,_fade.width,_fade.height),Color);
			_fadeDelay = Duration;
			_fadeComplete = FadeComplete;
			_fadeHelper = 0;
			_fade.alpha = 0;
			_fade.visible = true;
		}
		
		//@desc		Set the mouse cursor to some graphic file
		//@param	CursorGraphic	The image you want to use for the cursor
		private function setCursor(CursorGraphic:Class):void
		{
			if(_cursor != null)
				_buffer.removeChild(_cursor);
			_cursor = _buffer.addChild(new CursorGraphic) as Bitmap;
		}
		
		//@desc		This function is only used by the FlxGame class to do important internal management stuff
		private function showSoundTray():void
		{
			FlxG.play(SndBeep);
			_soundTrayTimer = 1;
			_soundTray.y = _gy*_z;
			_soundTray.visible = true;
			var gv:uint = Math.round(FlxG.getMasterVolume()*10);
			if(FlxG.getMute())
				gv = 0;
			for (var i:uint = 0; i < _soundTrayBars.length; i++)
			{
				if(i < gv) _soundTrayBars[i].alpha = 1;
				else _soundTrayBars[i].alpha = 0.5;
			}
		}
		
		//@desc		Set up the support panel thingy with donation and aggregation info
		//@param	PayPalID		Your paypal username, usually your email address (leave it blank to disable donations)
		//@param	PayPalAmount	The default amount of the donation
		//@param	GameTitle		The text that you would like to appear in the aggregation services (usually just the name of your game)
		//@param	GameURL			The URL you would like people to use when trying to find your game
		protected function setupSupportPanel(PayPalID:String,PayPalAmount:Number,GameTitle:String,GameURL:String,Caption:String):void
		{
			_panel.init(PayPalID,PayPalAmount,GameTitle,GameURL,Caption);
		}
		
		//@desc		Tell the support panel to slide onto the screen
		//@param	Top		Whether to slide on from the top or the bottom
		private function showSupportPanel(Top:Boolean=true):void
		{
			_panel.show(Top);
		}
		
		//@desc		Conceals the support panel
		private function hideSupportPanel():void
		{
			_panel.hide();
		}
	}
}
