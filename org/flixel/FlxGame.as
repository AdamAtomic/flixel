package org.flixel
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
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
	
	import org.flixel.aux.debug.Debugger;
	import org.flixel.aux.debug.FrameRecord;
	import org.flixel.aux.debug.MouseRecord;

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

		/**
		 * Sets 0, -, and + to control the global volume and P to pause.
		 * @default true
		 */
		public var useDefaultHotKeys:Boolean;
		/**
		 * Initialize and allow the flixel debugger overlay even in release mode.
		 * @default false
		 */
		public var debugOnRelease:Boolean;

		//basic display stuff
		internal var _state:FlxState;
		internal var _buffer:Bitmap;
		internal var _zoom:uint;
		
		//startup
		protected var _iState:Class;
		protected var _created:Boolean;
		
		//basic update stuff
		protected var _total:uint;
		protected var _accumulator:Number;
		protected var _lostFocus:Boolean;
		internal var _step:Number;
		
		//"focus lost" screen, sound tray, and debugger overlays
		protected var _focus:Sprite;
		protected var _soundTray:Sprite;
		protected var _soundTrayTimer:Number;
		protected var _soundTrayBars:Array;
		//internal var _console:FlxConsole;
		internal var _debugger:Debugger;
		internal var _debuggerUp:Boolean;

		/**
		 * Game object constructor - sets up the basic properties of your game.
		 * 
		 * @param	GameSizeX		The width of your game in pixels (e.g. 320).
		 * @param	GameSizeY		The height of your game in pixels (e.g. 240).
		 * @param	InitialState	The class name of the state you want to create and switch to first (e.g. MenuState).
		 * @param	FrameRate		How frequently the game should update (default is 60 times per second).
		 * @param	Zoom			The level of zoom (e.g. 2 means all pixels are now rendered twice as big).
		 */
		public function FlxGame(GameSizeX:uint,GameSizeY:uint,InitialState:Class,Zoom:uint=2)
		{
			//super high priority init stuff (focus, mouse, etc)
			flash.ui.Mouse.hide();
			_lostFocus = false;
			_focus = new Sprite();
			_focus.visible = false;
			_soundTray = new Sprite();
			
			//basic display and update setup stuff
			_zoom = Zoom;
			FlxState.bgColor = 0xff000000;
			FlxG.setGameData(this,GameSizeX,GameSizeY,_zoom);
			_step = 1/60;
			_total = 0;
			_accumulator = 0;
			_state = null;
			useDefaultHotKeys = true;
			debugOnRelease = false;
			_debuggerUp = false;
			
			//then get ready to create the game object for real
			_iState = InitialState;
			_created = false;
			addEventListener(Event.ENTER_FRAME, create);
		}
		
		/**
		 * Makes the little volume tray slide out.
		 * 
		 * @param	Silent	Whether or not it should beep.
		 */
		internal function showSoundTray(Silent:Boolean=false):void
		{
			if(!Silent)
				FlxG.play(SndBeep);
			_soundTrayTimer = 1;
			_soundTray.y = 0;
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
		internal function switchState(State:FlxState):void
		{ 
			//Basic reset stuff
			FlxG.unfollow();
			FlxG.resetInput();
			FlxG.destroySounds();
			FlxG.flash.stop();
			FlxG.fade.stop();
			FlxG.quake.stop();
			if(_debugger != null)
				_debugger.watch.removeAll();
			_buffer.x = 0;
			_buffer.y = 0;
			
			//Swap the new state for the old one and dispose of it
			addChild(State);
			if(_state != null)
			{
				_state.destroy(); //important that it is destroyed while still in the display list
				swapChildren(State,_state);
				removeChild(_state);
			}
			_state = State;
			_state.scaleX = _state.scaleY = _zoom; //important for proper mouse tracking
			
			//Finally, create the new state
			_state.create();
		}
		
		/**
		 * Resets the game as if it were launching for the first time.
		 */
		internal function reset():void
		{
			FlxG.setGameData(this,FlxG.width,FlxG.height,_zoom);
			switchState(new _iState());
		}

		/**
		 * Internal event handler for input and focus.
		 */
		protected function onKeyUp(event:KeyboardEvent):void
		{
			if(!FlxG.mobile)
			{
				if((_debugger != null) && ((event.keyCode == 192) || (event.keyCode == 220)))
				{
					_debugger.visible = !_debugger.visible;
					_debuggerUp = _debugger.visible;
					if(_debugger.visible)
						flash.ui.Mouse.show();
					else
						flash.ui.Mouse.hide();
					//_console.toggle();
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
			}
			if(_debuggerUp && _debugger.vcr.playingBack)
				return;
			FlxG.keys.handleKeyUp(event);
		}
		
		/**
		 * Internal event handler for input and focus.
		 */
		protected function onKeyDown(event:KeyboardEvent):void
		{
			if(_debuggerUp && _debugger.vcr.playingBack)
				return;
			FlxG.keys.handleKeyDown(event);
		}
		
		/**
		 * Internal event handler for input and focus.
		 */
		protected function onMouseDown(event:MouseEvent):void
		{
			if(_debuggerUp && (_debugger.hasMouse || _debugger.vcr.playingBack))
				return;
			FlxG.mouse.handleMouseDown(event);
		}
		
		/**
		 * Internal event handler for input and focus.
		 */
		protected function onMouseUp(event:MouseEvent):void
		{
			if(_debuggerUp && (_debugger.hasMouse || _debugger.vcr.playingBack))
				return;
			FlxG.mouse.handleMouseUp(event);
		}
		
		/**
		 * Internal event handler for input and focus.
		 */
		protected function onMouseWheel(event:MouseEvent):void
		{
			if(_debuggerUp && (_debugger.hasMouse || _debugger.vcr.playingBack))
				return;
			FlxG.mouse.handleMouseWheel(event);
		}
		
		/**
		 * Internal event handler for input and focus.
		 */
		protected function onFocus(event:Event=null):void
		{
			if(!_debuggerUp || !_debugger.visible)
				flash.ui.Mouse.hide();
			FlxG.resetInput();
			_lostFocus = _focus.visible = false;
			stage.frameRate = 30;//_framerate;
		}
		
		/**
		 * Internal event handler for input and focus.
		 */
		protected function onFocusLost(event:Event=null):void
		{
			if((x != 0) || (y != 0))
			{
				x = 0;
				y = 0;
			}
			flash.ui.Mouse.show();
			_lostFocus = _focus.visible = true;
			stage.frameRate = 5;//_frameratePaused;
		}
		
		/**
		 * Handles the onEnterFrame call, figures out how many updates and draw calls to do.
		 * @param	event	A Flash system event, not terribly important for our purposes!
		 */
		protected function onEnterFrame(event:Event=null):void
		{
			var mark:uint = getTimer();
			var ems:uint = mark-_total;				
			_accumulator += ems/1000;
			_total = mark;
			FlxG.elapsed = FlxG.timeScale*_step;
			updateSoundTray(ems);
			if(!_lostFocus)
			{
				if((_debugger != null) && _debugger.vcr.paused)
				{
					_accumulator %= _step;
					if(_debugger.vcr.stepRequested)
					{
						_debugger.vcr.stepRequested = false;
						step();
					}
				}
				else
				{
					while(_accumulator >= _step)
					{
						step();
						_accumulator -= _step;
					}
				}
			}
			FlxGroup._VISIBLECOUNT = 0;
			draw();
			
			if(_debuggerUp)
			{
				_debugger.perf.flash(ems);
				_debugger.perf.visibleObjects(FlxGroup._VISIBLECOUNT);
				_debugger.perf.update();
				_debugger.watch.update();
			}
		}
			
		protected function step():void
		{
			FlxGroup._ACTIVECOUNT = FlxGroup._EXTANTCOUNT = 0;
			if((_debugger != null) && _debugger.vcr.playingBack)
				_debugger.vcr.playInputFrame();
			else
				FlxG.updateInput();
			if((_debugger != null) && _debugger.vcr.recording)
				_debugger.vcr.recordInputFrame();
			update();
			FlxG.mouse.wheel = 0;
			if(_debuggerUp)
				_debugger.perf.objects(FlxGroup._ACTIVECOUNT,FlxGroup._EXTANTCOUNT);
		}

		/**
		 * This function handles updating the volume controls, debugger, stuff like that.
		 * This function does NOT update the actual game state or game effects!
		 * May be called multiple times per "frame" or draw call.
		 */
		protected function updateSoundTray(MS:Number):void
		{
			//animate stupid sound tray thing
			var soundPrefs:FlxSave;
			if(_soundTray != null)
			{
				if(_soundTrayTimer > 0)
					_soundTrayTimer -= MS/1000;
				else if(_soundTray.y > -_soundTray.height)
				{
					_soundTray.y -= (MS/1000)*FlxG.height*2;
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
		}
		
		/**
		 * This function updates the actual game state.
		 * May be called multiple times per "frame" or draw call.
		 */
		protected function update(event:Event=null):void
		{			
			var mark:uint = getTimer();
			
			FlxG.updateSounds();

			//Update the camera and game state
			FlxG.doFollow();
			_state.update();
			
			//Update the various special effects
			if(FlxG.flash.exists)
				FlxG.flash.update();
			if(FlxG.fade.exists)
				FlxG.fade.update();
			FlxG.quake.update();
			x = FlxG.quake.x;
			y = FlxG.quake.y;
			
			if(_debuggerUp)
				_debugger.perf.flixelUpdate(getTimer()-mark);
		}
		
		/**
		 * Goes through the game state and draws all the game objects and special effects.
		 */
		protected function draw(event:Event=null):void
		{
			var mark:uint = getTimer();
			FlxG.buffer.lock();
			_state.preProcess();
			_state.render();
			if(FlxG.flash.exists)
				FlxG.flash.draw();
			if(FlxG.fade.exists)
				FlxG.fade.draw();
			if(FlxG.mouse.cursor != null)
			{
				if(FlxG.mouse.cursor.active)
					FlxG.mouse.cursor.update();
				if(FlxG.mouse.cursor.visible)
					FlxG.mouse.cursor.draw();
			}
			_state.postProcess();
			FlxG.buffer.unlock();
			if(_debuggerUp)
				_debugger.perf.flixelDraw(getTimer()-mark);
		}
		
		/**
		 * Used to instantiate the guts of flixel once we have a valid reference to the root.
		 * 
		 * @param	event	Just a Flash system event, not too important for our purposes.
		 */
		protected function create(event:Event):void
		{
			if(root == null)
				return;
			removeEventListener(Event.ENTER_FRAME, create);

			var soundPrefs:FlxSave;
			
			//Set up the view window and double buffering
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.frameRate = 30;//_framerate;
			_buffer = new Bitmap(new BitmapData(FlxG.width,FlxG.height,true,FlxState.bgColor));
			_buffer.scaleX = _buffer.scaleY = _zoom;
			addChild(_buffer);
			FlxG.buffer = _buffer.bitmapData;
			
			//Initialize game console
			if(!FlxG.mobile && (FlxG.debug || debugOnRelease))
			{
				_debugger = new Debugger(FlxG.width*_zoom,FlxG.height*_zoom);
				addChild(_debugger);
			}
			
			//Add basic input even listeners
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			if(!FlxG.mobile)
			{
				stage.addEventListener(MouseEvent.MOUSE_OUT, FlxG.mouse.handleMouseOut);
				stage.addEventListener(MouseEvent.MOUSE_OVER, FlxG.mouse.handleMouseOver);
				stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
				stage.addEventListener(Event.DEACTIVATE, onFocusLost);
				stage.addEventListener(Event.ACTIVATE, onFocus);
				
				createSoundTray();
				createFocusScreen();
				
				//Check for saved sound preference data
				soundPrefs = new FlxSave();
				if(soundPrefs.bind("flixel") && (soundPrefs.data.sound != null))
				{
					if(soundPrefs.data.volume != null)
						FlxG.volume = soundPrefs.data.volume;
					if(soundPrefs.data.mute != null)
						FlxG.mute = soundPrefs.data.mute;
					//showSoundTray(true);
				}
			}
			
			//All set!
			switchState(new _iState());
			FlxState.screen.unsafeBind(FlxG.buffer);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		/**
		 * Sets up the "sound tray", the little volume meter that pops down sometimes.
		 */
		protected function createSoundTray():void
		{
			_soundTray.visible = false;
			_soundTray.scaleX = 2;
			_soundTray.scaleY = 2;
			var tmp:Bitmap = new Bitmap(new BitmapData(80,30,true,0x7F000000));
			_soundTray.x = (FlxG.width/2)*_zoom-(tmp.width/2)*_soundTray.scaleX;
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
			var i:uint = 0;
			while(i < 10)
			{
				tmp = new Bitmap(new BitmapData(4,++i,false,0xffffff));
				tmp.x = bx;
				tmp.y = by;
				_soundTrayBars.push(_soundTray.addChild(tmp));
				bx += 6;
				by--;
			}
			addChild(_soundTray);
		}
		
		/**
		 * Sets up the darkened overlay with the big white "play" button that appears when a flixel game loses focus.
		 */
		protected function createFocusScreen():void
		{
			var g:Graphics = _focus.graphics;
			var w:uint = FlxG.width*_zoom;
			var h:uint = FlxG.height*_zoom;
			
			//draw transparent black backdrop
			g.moveTo(0,0);
			g.beginFill(0,0.5);
			g.lineTo(w,0);
			g.lineTo(w,h);
			g.lineTo(0,h);
			g.lineTo(0,0);
			g.endFill();
			
			//draw white arrow
			var hw:uint = w/2;
			var hh:uint = h/2;
			var tri:uint = FlxU.min(hw,hh)/3;
			g.moveTo(hw-tri,hh-tri);
			g.beginFill(0xffffff);
			g.lineTo(hw+tri,hh);
			g.lineTo(hw-tri,hh+tri);
			g.lineTo(hw-tri,hh-tri);
			g.endFill();

			addChild(_focus);
		}
	}
}
