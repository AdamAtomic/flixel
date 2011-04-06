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
	
	import org.flixel.system.FlxDebugger;
	import org.flixel.system.FlxReplay;

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
		 * Sets 0, -, and + to control the global volume sound volume.
		 * @default true
		 */
		public var useSoundHotKeys:Boolean;
		/**
		 * Initialize and allow the flixel debugger overlay even in release mode.
		 * @default false
		 */
		public var debugOnRelease:Boolean;

		//basic display stuff
		internal var _state:FlxState;
		internal var _mouse:Sprite;
		
		//startup
		protected var _iState:Class;
		protected var _created:Boolean;
		
		//basic update stuff
		protected var _total:uint;
		protected var _accumulator:int;
		protected var _lostFocus:Boolean;
		internal var _step:uint;
		internal var _flashFramerate:uint;
		internal var _maxAccumulation:uint;
		internal var _requestedState:FlxState;
		internal var _requestedReset:Boolean;
		
		//"focus lost" screen, sound tray, and debugger overlays
		protected var _focus:Sprite;
		protected var _soundTray:Sprite;
		protected var _soundTrayTimer:Number;
		protected var _soundTrayBars:Array;
		internal var _debugger:FlxDebugger;
		internal var _debuggerUp:Boolean;
		
		//replays
		internal var _replay:FlxReplay;
		internal var _replayRequested:Boolean;
		internal var _recordingRequested:Boolean;
		internal var _replaying:Boolean;
		internal var _recording:Boolean;
		internal var _replayCancelKeys:Array;
		internal var _replayTimer:int;
		internal var _replayCallback:Function;

		/**
		 * Game object constructor - sets up the basic properties of your game.
		 * 
		 * @param	GameSizeX		The width of your game in pixels (e.g. 320).
		 * @param	GameSizeY		The height of your game in pixels (e.g. 240).
		 * @param	InitialState	The class name of the state you want to create and switch to first (e.g. MenuState).
		 * @param	FrameRate		How frequently the game should update (default is 60 times per second).
		 * @param	Zoom			The default level of zoom for the game's cameras (e.g. 2 = all pixels are now drawn at 2x).  Default = 1.
		 */
		public function FlxGame(GameSizeX:uint,GameSizeY:uint,InitialState:Class,Zoom:Number=1)
		{
			//super high priority init stuff (focus, mouse, etc)
			flash.ui.Mouse.hide();
			_lostFocus = false;
			_focus = new Sprite();
			_focus.visible = false;
			_soundTray = new Sprite();
			_mouse = new Sprite()
			
			//basic display and update setup stuff
			FlxG.init(this,GameSizeX,GameSizeY,Zoom);
			FlxG.framerate = 60;
			FlxG.flashFramerate = 30;
			_total = 0;
			_accumulator = 0;
			_state = null;
			useSoundHotKeys = true;
			debugOnRelease = false;
			_debuggerUp = false;
			
			//replay data
			_replay = new FlxReplay();
			_replayRequested = false;
			_recordingRequested = false;
			_replaying = false;
			_recording = false;
			
			//then get ready to create the game object for real
			_iState = InitialState;
			_requestedState null;
			_requestedReset = true;
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
		 * Internal event handler for input and focus.
		 */
		protected function onKeyUp(event:KeyboardEvent):void
		{
			if(!FlxG.mobile)
			{
				if(_debugger != null)
				{
					if(_debugger.watch.editing)
						return;
					
					if((event.keyCode == 192) || (event.keyCode == 220))
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
				}
				if(useSoundHotKeys)
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
						default:
							break;
					}
				}
			}
			if(_replaying)
				return;
			FlxG.keys.handleKeyUp(event);
		}
		
		/**
		 * Internal event handler for input and focus.
		 */
		protected function onKeyDown(event:KeyboardEvent):void
		{
			if(_replaying && (_replayCancelKeys != null) && (_debugger == null) && (event.keyCode != 192) && (event.keyCode != 220))
			{
				var cancel:Boolean = false;
				var k:String;
				var i:uint = 0;
				var l:uint = _replayCancelKeys.length;
				while(i < l)
				{
					k = _replayCancelKeys[i++];
					if((k == "ANY") || (FlxG.keys.getKeyCode(k) == event.keyCode))
					{
						if(_replayCallback != null)
						{
							_replayCallback();
							_replayCallback = null;
						}
						else
							FlxG.stopReplay();
						break;
					}
				}
				return;
			}
			FlxG.keys.handleKeyDown(event);
		}
		
		/**
		 * Internal event handler for input and focus.
		 */
		protected function onMouseDown(event:MouseEvent):void
		{
			if(_debuggerUp && _debugger.hasMouse)
				return;
			if(_replaying && (_replayCancelKeys != null))
			{
				var m:String;
				var i:uint = 0;
				var l:uint = _replayCancelKeys.length;
				while(i < l)
				{
					m = _replayCancelKeys[i++] as String;
					if((m == "MOUSE") || (m == "ANY"))
					{
						if(_replayCallback != null)
						{
							_replayCallback();
							_replayCallback = null;
						}
						else
							FlxG.stopReplay();
						break;
					}
				}
				return;
			}
			FlxG.mouse.handleMouseDown(event);
		}
		
		/**
		 * Internal event handler for input and focus.
		 */
		protected function onMouseUp(E:MouseEvent):void
		{
			if((_debuggerUp && _debugger.hasMouse) || _replaying)
				return;
			FlxG.mouse.handleMouseUp(E);
		}
		
		/**
		 * Internal event handler for input and focus.
		 */
		protected function onMouseWheel(E:MouseEvent):void
		{
			if((_debuggerUp && _debugger.hasMouse) || _replaying)
				return;
			FlxG.mouse.handleMouseWheel(E);
		}
		
		/**
		 * Internal event handler for input and focus.
		 */
		protected function onFocus(E:Event=null):void
		{
			if(!_debuggerUp || !_debugger.visible)
				flash.ui.Mouse.hide();
			FlxG.resetInput();
			_lostFocus = _focus.visible = false;
			stage.frameRate = _flashFramerate;
			FlxG.playSounds();
		}
		
		/**
		 * Internal event handler for input and focus.
		 */
		protected function onFocusLost(E:Event=null):void
		{
			if((x != 0) || (y != 0))
			{
				x = 0;
				y = 0;
			}
			flash.ui.Mouse.show();
			_lostFocus = _focus.visible = true;
			stage.frameRate = 10;
			FlxG.pauseSounds();
		}
		
		/**
		 * Handles the onEnterFrame call, figures out how many updates and draw calls to do.
		 * @param	event	A Flash system event, not terribly important for our purposes!
		 */
		protected function onEnterFrame(E:Event=null):void
		{			
			var mark:uint = getTimer();
			var ems:uint = mark-_total;
			_total = mark;
			updateSoundTray(ems);
			if(!_lostFocus)
			{
				if((_debugger != null) && _debugger.vcr.paused)
				{
					if(_debugger.vcr.stepRequested)
					{
						_debugger.vcr.stepRequested = false;
						step();
					}
				}
				else
				{
					_accumulator += ems;
					if(_accumulator > _maxAccumulation)
						_accumulator = _maxAccumulation;
					while(_accumulator >= _step)
					{
						step();
						_accumulator = _accumulator - _step; 
					}
				}
			}
			FlxBasic._VISIBLECOUNT = 0;
			draw();
			
			if(_debuggerUp)
			{
				_debugger.perf.flash(ems);
				_debugger.perf.visibleObjects(FlxBasic._VISIBLECOUNT);
				_debugger.perf.update();
				_debugger.watch.update();
			}
		}

		protected function switchState():void
		{ 
			//Basic reset stuff
			FlxG.resetCameras();
			FlxG.resetInput();
			FlxG.destroySounds();
			if(_debugger != null)
				_debugger.watch.removeAll();
			
			//Destroy the old state (if there is an old state)
			if(_state != null)
			{
				_state.destroy();
				if(FlxU.getClassName(_state) != FlxU.getClassName(_requestedState))
					FlxG.clearBitmapCache();
			}
			
			//Finally assign and create the new state
			_state = _requestedState;
			_state.create();
		}
			
		protected function step():void
		{
			//handle game reset request
			if(_requestedReset)
			{
				_requestedReset = false;
				_requestedState = new _iState();
				FlxG.reset();
			}
			
			//handle replay-related requests
			if(_recordingRequested)
			{
				_recordingRequested = false;
				_replay.create(FlxG.globalSeed);
				_recording = true;
				if(_debugger != null)
				{
					_debugger.vcr.recording();
					FlxG.log("FLIXEL: starting new flixel gameplay record.");
				}
			}
			else if(_replayRequested)
			{
				_replayRequested = false;
				_replay.rewind();
				FlxG.globalSeed = _replay.seed;
				if(_debugger != null)
					_debugger.vcr.playing();
				_replaying = true;
			}
			
			//handle state switching requests
			if(_state != _requestedState)
				switchState();
			
			//finally actually step through the game physics
			FlxBasic._ACTIVECOUNT = 0;
			if(_replaying)
			{
				_replay.playNextFrame();
				_replayTimer -= _step;
				if(_replayTimer <= 0)
				{
					if(_replayCallback != null)
					{
						_replayCallback();
						_replayCallback = null;
					}
					else
						FlxG.stopReplay();
				}
				if(_replaying && _replay.finished)
				{
					FlxG.stopReplay();
					if(_replayCallback != null)
					{
						_replayCallback();
						_replayCallback = null;
					}
				}
			}
			else
				FlxG.updateInput();
			if(_recording)
				_replay.recordFrame();
			update();
			FlxG.mouse.wheel = 0;
			if(_debuggerUp)
				_debugger.perf.activeObjects(FlxBasic._ACTIVECOUNT);
		}

		/**
		 * This function handles updating the volume controls, debugger, stuff like that.
		 * This function does NOT update the actual game state or game effects!
		 * May be called multiple times per "frame" or draw call.
		 */
		protected function updateSoundTray(MS:Number):void
		{
			//animate stupid sound tray thing
			
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
						var soundPrefs:FlxSave = new FlxSave();
						if(soundPrefs.bind("flixel"))
						{
							if(soundPrefs.data.sound == null)
								soundPrefs.data.sound = new Object;
							soundPrefs.data.sound.mute = FlxG.mute;
							soundPrefs.data.sound.volume = FlxG.volume;
							soundPrefs.close();
						}
					}
				}
			}
		}
		
		/**
		 * This function updates the actual game state.
		 * May be called multiple times per "frame" or draw call.
		 */
		protected function update():void
		{			
			var mark:uint = getTimer();
			
			FlxG.elapsed = FlxG.timeScale*(_step/1000);
			FlxG.updateSounds();
			_state.update();
			FlxG.updateCameras();
			
			if(_debuggerUp)
				_debugger.perf.flixelUpdate(getTimer()-mark);
		}
		
		/**
		 * Goes through the game state and draws all the game objects and special effects.
		 */
		protected function draw():void
		{
			var mark:uint = getTimer();
			FlxG.lockCameras();
			_state.draw();
			FlxG.unlockCameras();
			if(_debuggerUp)
				_debugger.perf.flixelDraw(getTimer()-mark);
		}
		
		/**
		 * Used to instantiate the guts of flixel once we have a valid reference to the root.
		 * 
		 * @param	event	Just a Flash system event, not too important for our purposes.
		 */
		protected function create(E:Event):void
		{
			if(root == null)
				return;
			removeEventListener(Event.ENTER_FRAME, create);
			_total = getTimer();
			
			//Set up the view window and double buffering
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.frameRate = _flashFramerate;
			
			//Add basic input event listeners and mouse container
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			addChild(_mouse);
			
			//Let mobile devs opt out of unnecessary overlays.
			if(!FlxG.mobile)
			{
				//Debugger overlay
				if(FlxG.debug || debugOnRelease)
				{
					_debugger = new FlxDebugger(FlxG.width*FlxCamera.defaultZoom,FlxG.height*FlxCamera.defaultZoom);
					addChild(_debugger);
				}
				
				//Volume display tab
				createSoundTray();
				
				//Focus gained/lost monitoring
				stage.addEventListener(MouseEvent.MOUSE_OUT, FlxG.mouse.handleMouseOut);
				stage.addEventListener(MouseEvent.MOUSE_OVER, FlxG.mouse.handleMouseOver);
				stage.addEventListener(Event.DEACTIVATE, onFocusLost);
				stage.addEventListener(Event.ACTIVATE, onFocus);
				createFocusScreen();
			}
			
			//Finally, set up an event for the actual game loop stuff.
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
			_soundTray.x = (FlxG.width/2)*FlxCamera.defaultZoom-(tmp.width/2)*_soundTray.scaleX;
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
			
			_soundTray.y = -_soundTray.height;
			_soundTray.visible = false;
			addChild(_soundTray);
			
			//load saved sound preferences for this game if they exist
			var soundPrefs:FlxSave = new FlxSave();
			if(soundPrefs.bind("flixel") && (soundPrefs.data.sound != null))
			{
				if(soundPrefs.data.sound.volume != null)
					FlxG.volume = soundPrefs.data.sound.volume;
				if(soundPrefs.data.sound.mute != null)
					FlxG.mute = soundPrefs.data.sound.mute;
				soundPrefs.destroy();
			}
		}
		
		/**
		 * Sets up the darkened overlay with the big white "play" button that appears when a flixel game loses focus.
		 */
		protected function createFocusScreen():void
		{
			var g:Graphics = _focus.graphics;
			var w:uint = FlxG.width*FlxCamera.defaultZoom;
			var h:uint = FlxG.height*FlxCamera.defaultZoom;
			
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
