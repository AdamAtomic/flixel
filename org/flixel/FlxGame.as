package org.flixel
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.utils.getTimer;
	
	import org.flixel.data.FlxConsole;
	import org.flixel.data.FlxPause;

	/**
	 * FlxGame is the heart of all flixel games, and contains a bunch of basic game loops and things.
	 * It is a long and sloppy file that you shouldn't have to worry about too much!
	 * It is basically only used to create your game object in the first place,
	 * after that FlxG and FlxState have all the useful stuff you actually need.
	 */
	public class FlxGame extends Sprite
	{
		[Embed(source="data/nokiafc22.ttf",fontFamily="system")] protected var junk:String;
		[Embed(source="data/beep.mp3")] protected var SndBeep:Class;
		[Embed(source="data/flixel.mp3")] protected var SndFlixel:Class;

		/**
		 * Essentially locks the framerate to 30 FPS minimum
		 */
		internal const MAX_ELAPSED:Number = 0.0333;

		/**
		 * Sets 0, -, and + to control the global volume and P to pause.
		 * @default true
		 */
		public var useDefaultHotKeys:Boolean;
		/**
		 * Displayed whenever the game is paused.
		 * Override with your own <code>FlxLayer</code> for hot custom pause action!
		 * Defaults to <code>data.FlxPause</code>.
		 */
		public var pause:FlxGroup;
		
		//startup
		internal var _iState:Class;
		internal var _created:Boolean;
		
		//basic display stuff
		internal var _state:FlxState;
		internal var _buffer:Sprite;
		internal var _bmpBack:Bitmap;
		internal var _bmpFront:Bitmap;
		internal var _r:Rectangle;
		internal var _flipped:Boolean;
		internal var _zoom:uint;
		internal var _gameXOffset:int;
		internal var _gameYOffset:int;
		internal var _frame:Class;
		internal var _zeroPoint:Point;
		
		//basic update stuff
		internal var _elapsed:Number;
		internal var _total:uint;
		internal var _paused:Boolean;
		
		//Pause screen, sound tray, support panel, dev console, and special effects objects
		internal var _soundTray:Sprite;
		internal var _soundTrayTimer:Number;
		internal var _soundTrayBars:Array;
		internal var _console:FlxConsole;
		
		/**
		 * Game object constructor - sets up the basic properties of your game.
		 * 
		 * @param	GameSizeX		The width of your game in pixels (e.g. 320).
		 * @param	GameSizeY		The height of your game in pixels (e.g. 240).
		 * @param	InitialState	The class name of the state you want to create and switch to first (e.g. MenuState).
		 * @param	Zoom			The level of zoom (e.g. 2 means all pixels are now rendered twice as big).
		 */
		public function FlxGame(GameSizeX:uint,GameSizeY:uint,InitialState:Class,Zoom:uint=2)
		{
			flash.ui.Mouse.hide();
			
			_zoom = Zoom;
			FlxState.bgColor = 0xff000000;
			FlxG.setGameData(this,GameSizeX,GameSizeY,Zoom);
			_elapsed = 0;
			_total = 0;
			pause = new FlxPause();
			_state = null;
			_iState = InitialState;
			_zeroPoint = new Point();

			useDefaultHotKeys = true;
			
			_frame = null;
			_gameXOffset = 0;
			_gameYOffset = 0;
			
			_paused = false;
			_created = false;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		/**
		 * Adds a frame around your game for presentation purposes (see Canabalt, Gravity Hook).
		 * 
		 * @param	Frame			If you want you can add a little graphical frame to the outside edges of your game.
		 * @param	ScreenOffsetX	Width in pixels of left side of frame.
		 * @param	ScreenOffsetY	Height in pixels of top of frame.
		 * 
		 * @return	This <code>FlxGame</code> instance.
		 */
		protected function addFrame(Frame:Class,ScreenOffsetX:uint,ScreenOffsetY:uint):FlxGame
		{
			_frame = Frame;
			_gameXOffset = ScreenOffsetX;
			_gameYOffset = ScreenOffsetY;
			return this;
		}
		
		/**
		 * Makes the little volume tray slide out.
		 * 
		 * @param	Silent	Whether or not it should beep.
		 */
		public function showSoundTray(Silent:Boolean=false):void
		{
			if(!Silent)
				FlxG.play(SndBeep);
			_soundTrayTimer = 1;
			_soundTray.y = _gameYOffset*_zoom;
			_soundTray.visible = true;
			var gv:uint = Math.round(FlxG.volume*10);
			if(FlxG.mute)
				gv = 0;
			for (var i:uint = 0; i < _soundTrayBars.length; i++)
			{
				if(i < gv) _soundTrayBars[i].alpha = 1;
				else _soundTrayBars[i].alpha = 0.5;
			}
		}
		
		/**
		 * Switch from one <code>FlxState</code> to another.
		 * Usually called from <code>FlxG</code>.
		 * 
		 * @param	State		The class name of the state you want (e.g. PlayState)
		 */
		public function switchState(State:FlxState):void
		{ 
			//Basic reset stuff
			FlxG.panel.hide();
			FlxG.unfollow();
			FlxG.resetInput();
			FlxG.destroySounds();
			FlxG.flash.stop();
			FlxG.fade.stop();
			FlxG.quake.stop();
			_buffer.x = 0;
			_buffer.y = 0;
			
			//Swap the new state for the old one and dispose of it
			_buffer.addChild(State);
			if(_state != null)
			{
				_state.destroy(); //important that it is destroyed while still in the display list
				_buffer.swapChildren(State,_state);
				_buffer.removeChild(_state);
			}
			_state = State;
			
			//Finally, create the new state
			_state.create();
		}

		/**
		 * Internal event handler for input and focus.
		 */
		protected function onKeyUp(event:KeyboardEvent):void
		{
			if((event.keyCode == 192) || (event.keyCode == 220)) //FOR ZE GERMANZ
			{
				_console.toggle();
				return;
			}
			if(useDefaultHotKeys)
			{
				var c:int = event.keyCode;
				var code:String = String.fromCharCode(event.charCode);
				switch(c)
				{
					case 48:
					case 96:
						FlxG.mute = !FlxG.mute;
						showSoundTray();
						return;
					case 109:
					case 189:
						FlxG.mute = false;
			    		FlxG.volume = FlxG.volume - 0.1;
			    		showSoundTray();
						return;
					case 107:
					case 187:
						FlxG.mute = false;
			    		FlxG.volume = FlxG.volume + 0.1;
			    		showSoundTray();
						return;
					case 80:
						FlxG.pause = !FlxG.pause;
					default: break;
				}
			}
			FlxG.keys.handleKeyUp(event);
		}
		
		/**
		 * Internal event handler for input and focus.
		 */
		protected function onFocus(event:Event=null):void
		{
			if(FlxG.pause)
				FlxG.pause = false;
		}
		
		/**
		 * Internal event handler for input and focus.
		 */
		protected function onFocusLost(event:Event=null):void
		{
			FlxG.pause = true;
		}
		
		/**
		 * Internal function to help with basic pause game functionality.
		 */
		internal function unpauseGame():void
		{
			if(!FlxG.panel.visible) flash.ui.Mouse.hide();
			FlxG.resetInput();
			_paused = false;
			stage.frameRate = 60;
		}
		
		/**
		 * Internal function to help with basic pause game functionality.
		 */
		internal function pauseGame():void
		{
			if((x != 0) || (y != 0))
			{
				x = 0;
				y = 0;
			}
			if(!_flipped)
				_bmpBack.bitmapData.copyPixels(_bmpFront.bitmapData,_r,_zeroPoint);
			else
				_bmpFront.bitmapData.copyPixels(_bmpBack.bitmapData,_r,_zeroPoint);
			flash.ui.Mouse.show();
			_paused = true;
			stage.frameRate = 10;
		}
		
		/**
		 * This is the main game loop, but only once creation and logo playback is finished.
		 */
		protected function onEnterFrame(event:Event):void
		{
			var i:uint;
			var soundPrefs:FlxSave;
			
			//Frame timing
			var t:uint = getTimer();
			_elapsed = (t-_total)/1000;
			if(_created)
				_console.lastElapsed = _elapsed;
			_total = t;
			FlxG.elapsed = _elapsed;
			if(FlxG.elapsed > MAX_ELAPSED)
				FlxG.elapsed = MAX_ELAPSED;
			FlxG.elapsed *= FlxG.timeScale;
			
			if(_soundTray != null)
			{
				if(_soundTrayTimer > 0)
					_soundTrayTimer -= _elapsed;
				else if(_soundTray.y > -_soundTray.height)
				{
					_soundTray.y -= _elapsed*FlxG.height*2;
					if(_soundTray.y <= -_soundTray.height)
					{
						_soundTray.visible = false;
						
						//Save sound preferences
						soundPrefs = new FlxSave();
						if(soundPrefs.bind("flixel"))
						{
							if(soundPrefs.data.sound == null)
								soundPrefs.data.sound = new Object;
							soundPrefs.data.mute = FlxG.mute;
							soundPrefs.data.volume = FlxG.volume;
							soundPrefs.forceSave();
						}
					}
				}
			}
			
			if(_created)
			{
				//Animate flixel HUD elements
				FlxG.panel.update();
				_console.update();
				
				//State updating
				FlxG.updateInput();
				FlxG.updateSounds();
				if(_paused)
				{
					pause.update();
					if(_flipped)
						FlxG.buffer.copyPixels(_bmpFront.bitmapData,_r,_zeroPoint);
					else
						FlxG.buffer.copyPixels(_bmpBack.bitmapData,_r,_zeroPoint);
					pause.render();
				}
				else
				{
					//Clear video buffer
					if(_flipped)
						FlxG.buffer = _bmpFront.bitmapData;
					else
						FlxG.buffer = _bmpBack.bitmapData;
					FlxState.screen.unsafeBind(FlxG.buffer);
					_state.preProcess();
					
					//Update the camera and game state
					FlxG.doFollow();
					_state.update();
					
					//Update the various special effects
					if(FlxG.flash.exists)
						FlxG.flash.update();
					if(FlxG.fade.exists)
						FlxG.fade.update();
					FlxG.quake.update();
					_buffer.x = FlxG.quake.x;
					_buffer.y = FlxG.quake.y;
					
					//Render game content, special fx, and overlays
					_state.render();
					if(FlxG.flash.exists)
						FlxG.flash.render();
					if(FlxG.fade.exists)
						FlxG.fade.render();
					if(FlxG.panel.visible)
						FlxG.panel.render();
					if(FlxG.mouse.cursor != null)
					{
						if(FlxG.mouse.cursor.active)
							FlxG.mouse.cursor.update();
						if(FlxG.mouse.cursor.visible)
							FlxG.mouse.cursor.render();
					}
					
					//Post-processing hook
					_state.postProcess();
					
					//Swap video buffers
					_bmpBack.visible = !(_bmpFront.visible = _flipped);
					_flipped = !_flipped;
				}
			}
			else if(root != null)
			{
				//Set up the view window and double buffering
				stage.scaleMode = StageScaleMode.NO_SCALE;
	            stage.align = StageAlign.TOP_LEFT;
	            stage.frameRate = 60;
	            _buffer = new Sprite();
	            _buffer.scaleX = _zoom;
	            _buffer.scaleY = _zoom;
	            addChild(_buffer);
				_bmpBack = new Bitmap(new BitmapData(FlxG.width,FlxG.height,true,FlxState.bgColor));
				_bmpBack.x = _gameXOffset;
				_bmpBack.y = _gameYOffset;
				_buffer.addChild(_bmpBack);
				_bmpFront = new Bitmap(new BitmapData(_bmpBack.width,_bmpBack.height,true,FlxState.bgColor));
				_bmpFront.x = _bmpBack.x;
				_bmpFront.y = _bmpBack.y;
				_buffer.addChild(_bmpFront);
				_flipped = false;
				_r = new Rectangle(0,0,_bmpFront.width,_bmpFront.height);
				
				//Initialize game console
				_console = new FlxConsole(_gameXOffset,_gameYOffset,_zoom);
				addChild(_console);
				var vstring:String = FlxG.LIBRARY_NAME+" v"+FlxG.LIBRARY_MAJOR_VERSION+"."+FlxG.LIBRARY_MINOR_VERSION;
				if(FlxG.debug)
					vstring += " [debug]";
				else
					vstring += " [release]";
				var underline:String = "";
				for(i = 0; i < vstring.length+32; i++)
					underline += "-";
				FlxG.log(vstring);
				FlxG.log(underline);
				
				//Add basic input even listeners
				stage.addEventListener(KeyboardEvent.KEY_DOWN, FlxG.keys.handleKeyDown);
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, FlxG.mouse.handleMouseDown);
				stage.addEventListener(MouseEvent.MOUSE_UP, FlxG.mouse.handleMouseUp);
				stage.addEventListener(MouseEvent.MOUSE_OUT, FlxG.mouse.handleMouseOut);
				stage.addEventListener(MouseEvent.MOUSE_OVER, FlxG.mouse.handleMouseOver);
								
				//Initialize the pause screen
				stage.addEventListener(Event.DEACTIVATE, onFocusLost);
				stage.addEventListener(Event.ACTIVATE, onFocus);
				
				//Sound Tray popup
				_soundTray = new Sprite();
				_soundTray.visible = false;
				_soundTray.scaleX = 2;
				_soundTray.scaleY = 2;
				var tmp:Bitmap = new Bitmap(new BitmapData(80,30,true,0x7F000000));
				_soundTray.x = (_gameXOffset+FlxG.width/2)*_zoom-(tmp.width/2)*_soundTray.scaleX;
				_soundTray.addChild(tmp);
				
				var text:TextField = new TextField();
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

				//Initialize the decorative frame (optional)
				if(_frame != null)
				{
					var bmp:Bitmap = new _frame;
					bmp.scaleX = _zoom;
					bmp.scaleY = _zoom;
					addChild(bmp);
				}
				
				//Check for saved sound preference data
				soundPrefs = new FlxSave();
				if(soundPrefs.bind("flixel") && (soundPrefs.data.sound != null))
				{
					if(soundPrefs.data.volume != null)
						FlxG.volume = soundPrefs.data.volume;
					if(soundPrefs.data.mute != null)
						FlxG.mute = soundPrefs.data.mute;
					showSoundTray(true);
				}
				
				//All set!
				_created = true;
				switchState(new _iState());
			}
		}
	}
}
