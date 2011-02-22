package org.flixel
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.utils.Timer;
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
		// NOTE: Flex 4 introduces DefineFont4, which is used by default and does not work in native text fields.
		// Use the embedAsCFF="false" param to switch back to DefineFont4. In earlier Flex 4 SDKs this was cff="false".
		// So if you are using the Flex 3.x SDK compiler, switch the embed statment below to expose the correct version.
		
		//Flex v4.x SDK only (see note above):
		[Embed(source="data/nokiafc22.ttf",fontFamily="system",embedAsCFF="false")] protected var junk:String;
		
		//Flex v3.x SDK only (see note above):
		//[Embed(source="data/nokiafc22.ttf",fontFamily="system")] protected var junk:String;
		
		[Embed(source="data/beep.mp3")] protected var SndBeep:Class;
		[Embed(source="data/flixel.mp3")] protected var SndFlixel:Class;

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
		internal var _screen:Sprite;
		internal var _buffer:Bitmap;
		internal var _zoom:uint;
		internal var _gameXOffset:int;
		internal var _gameYOffset:int;
		internal var _frame:Class;
		internal var _zeroPoint:Point;
		
		//basic update stuff
		internal var _elapsed:Number;
		internal var _total:uint;
		internal var _paused:Boolean;
		internal var _framerate:uint;
		internal var _frameratePaused:uint;
		
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
			
			addEventListener(Event.ENTER_FRAME, create);
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
			_screen.x = 0;
			_screen.y = 0;
			
			//Swap the new state for the old one and dispose of it
			_screen.addChild(State);
			if(_state != null)
			{
				_state.destroy(); //important that it is destroyed while still in the display list
				_screen.swapChildren(State,_state);
				_screen.removeChild(_state);
			}
			_state = State;
			_state.scaleX = _state.scaleY = _zoom;
			
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
			stage.frameRate = _framerate;
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
			flash.ui.Mouse.show();
			_paused = true;
			stage.frameRate = _frameratePaused;
		}
		
		/**
		 * This is the main game loop.  It controls all the updating and rendering.
		 */
		protected function update(event:Event):void
		{
			var mark:uint = getTimer();
			
			var i:uint;
			var soundPrefs:FlxSave;

			//Frame timing
			var ems:uint = mark-_total;
			_elapsed = ems/1000;
			_console.mtrTotal.add(ems);
			_total = mark;
			FlxG.elapsed = _elapsed;
			if(FlxG.elapsed > FlxG.maxElapsed)
				FlxG.elapsed = FlxG.maxElapsed;
			FlxG.elapsed *= FlxG.timeScale;
			
			//Sound tray crap
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

			//Animate flixel HUD elements
			FlxG.panel.update();
			if(_console.visible)
				_console.update();
			
			//State updating
			FlxObject._refreshBounds = false;
			FlxG.updateInput();
			FlxG.updateSounds();
			if(_paused)
				pause.update();
			else
			{
				//Update the camera and game state
				FlxG.doFollow();
				_state.update();
				
				//Update the various special effects
				if(FlxG.flash.exists)
					FlxG.flash.update();
				if(FlxG.fade.exists)
					FlxG.fade.update();
				FlxG.quake.update();
				_screen.x = FlxG.quake.x;
				_screen.y = FlxG.quake.y;
			}
			//Keep track of how long it took to update everything
			var updateMark:uint = getTimer();
			_console.mtrUpdate.add(updateMark-mark);
			
			//Render game content, special fx, and overlays
			FlxG.buffer.lock();
			_state.preProcess();
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
			_state.postProcess();
			if(_paused)
				pause.render();
			FlxG.buffer.unlock();
			//Keep track of how long it took to draw everything
			_console.mtrRender.add(getTimer()-updateMark);
		}
		
		/**
		 * Used to instantiate the guts of flixel once we have a valid pointer to the root.
		 */
		internal function create(event:Event):void
		{
			if(root == null)
				return;

			var i:uint;
			var soundPrefs:FlxSave;
			
			//Set up the view window and double buffering
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.frameRate = _framerate;
            _screen = new Sprite();
            addChild(_screen);
			var tmp:Bitmap = new Bitmap(new BitmapData(FlxG.width,FlxG.height,true,FlxState.bgColor));
			tmp.x = _gameXOffset;
			tmp.y = _gameYOffset;
			tmp.scaleX = tmp.scaleY = _zoom;
			_screen.addChild(tmp);
			FlxG.buffer = tmp.bitmapData;
			
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
			tmp = new Bitmap(new BitmapData(80,30,true,0x7F000000));
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
			switchState(new _iState());
			FlxState.screen.unsafeBind(FlxG.buffer);
			removeEventListener(Event.ENTER_FRAME, create);
			addEventListener(Event.ENTER_FRAME, update);
		}
	}
}
