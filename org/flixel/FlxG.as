package org.flixel
{
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import org.flixel.system.FlxDebugger;
	import org.flixel.system.FlxSound;
	import org.flixel.system.fx.*;
	import org.flixel.system.input.*;
	
	/**
	 * This is a global helper class full of useful functions for audio,
	 * input, basic info, and the camera system among other things.
	 */
	public class FlxG
	{
		/**
		 * If you build and maintain your own version of flixel,
		 * you can give it your own name here.  Appears in the console.
		 */
		static public var LIBRARY_NAME:String = "flixel";
		/**
		 * Assign a major version to your library.
		 * Appears before the decimal in the console.
		 */
		static public var LIBRARY_MAJOR_VERSION:uint = 2;
		/**
		 * Assign a minor version to your library.
		 * Appears after the decimal in the console.
		 */
		static public var LIBRARY_MINOR_VERSION:uint = 50;
		
		static public const DEBUGGER_STANDARD:uint = 0;
		static public const DEBUGGER_MICRO:uint = 1;
		static public const DEBUGGER_BIG:uint = 2;
		static public const DEBUGGER_TOP:uint = 3;
		static public const DEBUGGER_LEFT:uint = 4;
		static public const DEBUGGER_RIGHT:uint = 5;

		/**
		 * Internal tracker for game object (so we can pause & unpause)
		 */
		static internal var _game:FlxGame;
		/**
		 * Handy shared variable for implementing your own pause behavior.
		 */
		static public var paused:Boolean;
		/**
		 * Whether you are running in Debug or Release mode.
		 * Set automatically by <code>FlxFactory</code> during startup.
		 */
		static public var debug:Boolean;
		
		/**
		 * Represents the amount of time in seconds that passed since last frame.
		 */
		static public var elapsed:Number;
		/**
		 * How fast or slow time should pass in the game; default is 1.0.
		 */
		static public var timeScale:Number;
		/**
		 * The width of the screen in game pixels.
		 */
		static public var width:uint;
		/**
		 * The height of the screen in game pixels.
		 */
		static public var height:uint;
		/**
		 * Setting this to true will disable/skip stuff that isn't necessary for mobile platforms like Android. [BETA]
		 */
		static public var mobile:Boolean; 
		/**
		 * The global random number generator seed (for deterministic behavior in recordings and saves).
		 */
		static public var globalSeed:Number;
		/**
		 * <code>FlxG.levels</code> and <code>FlxG.scores</code> are generic
		 * global variables that can be used for various cross-state stuff.
		 */
		static public var levels:Array;
		static public var level:int;
		static public var scores:Array;
		static public var score:int;
		/**
		 * <code>FlxG.saves</code> is a generic bucket for storing
		 * FlxSaves so you can access them whenever you want.
		 */
		static public var saves:Array; 
		static public var save:int;

		/**
		 * A reference to a <code>FlxMouse</code> object.  Important for input!
		 */
		static public var mouse:Mouse;
		/**
		 * A reference to a <code>FlxKeyboard</code> object.  Important for input!
		 */
		static public var keys:Keyboard;
		
		/**
		 * A handy container for a background music object.
		 */
		static public var music:FlxSound;
		/**
		 * A list of all the sounds being played in the game.
		 */
		static public var sounds:FlxGroup;
		/**
		 * Whether or not the game sounds are muted.
		 */
		static public var mute:Boolean;
		/**
		 * Internal volume level, used for global sound control.
		 */
		static protected var _volume:Number;
		
		/**
		 * Tells the camera to follow this <code>FlxCore</code> object around.
		 */
		static public var followTarget:FlxObject;
		/**
		 * Used to force the camera to look ahead of the <code>followTarget</code>.
		 */
		static public var followLead:Point;
		/**
		 * Used to smoothly track the camera as it follows.
		 */
		static public var followLerp:Number;
		/**
		 * Stores the top and left edges of the camera area.
		 */
		static public var followMin:Point;
		/**
		 * Stores the bottom and right edges of the camera area.
		 */
		static public var followMax:Point;
		/**
		 * Internal, used to assist camera and scrolling.
		 */
		static protected var _scrollTarget:Point;
		
		/**
		 * Stores the basic parallax scrolling values.
		 */
		static public var scroll:Point;
		/**
		 * Reference to the active graphics buffer.
		 * Can also be referenced via <code>FlxState.screen</code>.
		 */
		static public var buffer:BitmapData;
		/**
		 * Internal storage system to prevent graphics from being used repeatedly in memory.
		 */
		static protected var _cache:Object;

		/**
		 * A special effect that shakes the screen.  Usage: FlxG.quake.start();
		 */
		static public var quake:Quake;
		/**
		 * A special effect that flashes a color on the screen.  Usage: FlxG.flash.start();
		 */
		static public var flash:Flash;
		/**
		 * A special effect that fades a color onto the screen.  Usage: FlxG.fade.start();
		 */
		static public var fade:Fade;
		
		/**
		 * Log data to the debugger.
		 * 
		 * @param	Data		Anything you want to log to the console.
		 */
		static public function log(Data:Object):void
		{
			if((_game != null) && (_game._debugger != null))
				_game._debugger.log.add((Data == null)?"ERROR: null object":Data.toString());
		}
		
		/**
		 * Add a variable to the watch list in the debugger.
		 * This lets you see the value of the variable all the time.
		 * 
		 * @param	AnyObject		A reference to any object in your game, e.g. Player or Robot or this.
		 * @param	VariableName	The name of the variable you want to watch, in quotes, as a string: e.g. "speed" or "health".
		 */
		static public function watch(AnyObject:Object,VariableName:String):void
		{
			if((_game != null) && (_game._debugger != null))
				_game._debugger.watch.add(AnyObject,VariableName);
		}
		
		/**
		 * Remove a variable from the watch list in the debugger.
		 * Don't pass a Variable Name to remove all watched variables for the specified object.
		 * 
		 * @param	AnyObject		A reference to any object in your game, e.g. Player or Robot or this.
		 * @param	VariableName	The name of the variable you want to watch, in quotes, as a string: e.g. "speed" or "health".
		 */
		static public function unwatch(AnyObject:Object,VariableName:String=null):void
		{
			if((_game != null) && (_game._debugger != null))
				_game._debugger.watch.remove(AnyObject,VariableName);
		}
		
		/**
		 * How many times you want your game to update each second.
		 * More updates usually means better collisions and smoother motion.
		 * NOTE: This is NOT the same thing as the Flash Player framerate!
		 */
		static public function get framerate():Number
		{
			return 1/_game._step;
		}
		
		/**
		 * @private
		 */
		static public function set framerate(Framerate:Number):void
		{
			_game._step = 1/Framerate;
		}
		
		/**
		 * How many times you want your game to update each second.
		 * More updates usually means better collisions and smoother motion.
		 * NOTE: This is NOT the same thing as the Flash Player framerate!
		 */
		static public function get flashFramerate():Number
		{
			if(_game.root != null)
				return _game.stage.frameRate;
			else
				return 0;
		}
		
		/**
		 * @private
		 */
		static public function set flashFramerate(Framerate:Number):void
		{
			_game._flashFramerate = Framerate;
			if(_game.root != null)
				_game.stage.frameRate = _game._flashFramerate;
		}
		
		/**
		 * Generates a random number.  Deterministic, meaning safe
		 * to use if you want to record replays in random environments.
		 * 
		 * @return	A <code>Number</code> between 0 and 1.
		 */
		static public function random():Number
		{
			return globalSeed = FlxU.srand(globalSeed);
		}
		
		/**
		 * Shuffles the entries in an array into a new random order.
		 * 
		 * @param	A				A Flash <code>Array</code> object containing...stuff.
		 * @param	HowManyTimes	How many swaps to perform during the shuffle operation.  Good rule of thumb is 2-4 times as many objects are in the list.
		 * 
		 * @return	The same Flash <code>Array</code> object that you passed in in the first place.
		 */
		static public function shuffle(Objects:Array,HowManyTimes:uint):Array
		{
			var i1:uint;
			var i2:uint;
			var o:Object;
			for(var i:uint = 0; i < HowManyTimes; i++)
			{
				i1 = FlxG.random()*Objects.length;
				i2 = FlxG.random()*Objects.length;
				o = Objects[i2];
				Objects[i2] = Objects[i1];
				Objects[i1] = o;
			}
			return Objects;
		}
		
		static public function getRandom(Objects:Array):Object
		{
			if(Objects != null)
			{
				var l:uint = Objects.length;
				if(l > 0)
					return Objects[uint(FlxG.random()*l)];
			}
			return null;
		}
		
		/**
		 * Load replay data from a string and play it back.
		 * 
		 * @param	Data		The replay that you want to load.
		 * @param	State		Optional parameter: if you recorded a state-specific demo or cutscene, pass a new instance of that state here.
		 * @param	CancelKeys	Optional parameter: an array of string names of keys (see FlxKeyboard) that can be pressed to cancel the playback, e.g. ["ESCAPE","ENTER"].  Also accepts 2 custom key names: "ANY" and "MOUSE" (fairly self-explanatory I hope!).
		 * @param	Timeout		Optional parameter: set a time limit for the replay.  CancelKeys will override this if pressed.
		 * @param	Callback	Optional parameter: if set, called when the replay finishes.  Running to the end, CancelKeys, and Timeout will all trigger Callback(), but only once, and CancelKeys and Timeout will NOT call FlxG.stopReplay() if Callback is set!
		 */
		static public function loadReplay(Data:String,State:FlxState=null,CancelKeys:Array=null,Timeout:Number=NaN,Callback:Function=null):void
		{
			_game._replay.load(Data);
			if(State == null)
				FlxG.resetGame();
			else
				FlxG.switchState(State);
			_game._replayCancelKeys = CancelKeys;
			_game._replayTimer = Timeout;
			_game._replayCallback = Callback;
			_game._replayRequested = true;
		}
		
		static public function reloadReplay(StandardMode:Boolean=true):void
		{
			if(StandardMode)
				FlxG.resetGame();
			else
				FlxG.resetState();
			if(_game._replay.frameCount > 0)
				_game._replayRequested = true;
		}
		
		static public function stopReplay():void
		{
			_game._replaying = false;
			if(_game._debugger != null)
				_game._debugger.vcr.stopped();
			resetInput();
		}
		
		static public function recordReplay(StandardMode:Boolean=true):void
		{
			if(StandardMode)
				FlxG.resetGame();
			else
				FlxG.resetState();
			_game._recordingRequested = true;
		}
		
		static public function stopRecording():String
		{
			_game._recording = false;
			if(_game._debugger != null)
				_game._debugger.vcr.stopped();
			return _game._replay.save();
		}
		
		static public function resetState():void
		{
			_game._requestedState = new (FlxU.getClass(FlxU.getClassName(_game._state,false)))();
		}
		
		/**
		 * Like hitting the reset button on a game console, this will re-launch the game as if it just started.
		 */
		static public function resetGame():void
		{
			_game._requestedReset = true;
		}
		
		/**
		 * Reset the input helper objects (useful when changing screens or states)
		 */
		static public function resetInput():void
		{
			keys.reset();
			mouse.reset();
		}
		
		/**
		 * Set up and play a looping background soundtrack.
		 * 
		 * @param	Music		The sound file you want to loop in the background.
		 * @param	Volume		How loud the sound should be, from 0 to 1.
		 */
		static public function playMusic(Music:Class,Volume:Number=1.0):void
		{
			if(music == null)
				music = new FlxSound();
			else if(music.active)
				music.stop();
			music.loadEmbedded(Music,true);
			music.volume = Volume;
			music.survive = true;
			music.play();
		}
		
		/**
		 * Creates a new sound object from an embedded <code>Class</code> object.
		 * 
		 * @param	EmbeddedSound	The sound you want to play.
		 * @param	Volume			How loud to play it (0 to 1).
		 * @param	Looped			Whether or not to loop this sound.
		 * 
		 * @return	A <code>FlxSound</code> object.
		 */
		static public function play(EmbeddedSound:Class,Volume:Number=1.0,Looped:Boolean=false):FlxSound
		{
			var s:FlxSound = sounds.recycle(FlxSound) as FlxSound;
			s.loadEmbedded(EmbeddedSound,Looped);
			s.volume = Volume;
			s.play();
			return s;
		}
		
		/**
		 * Creates a new sound object from a URL.
		 * 
		 * @param	EmbeddedSound	The sound you want to play.
		 * @param	Volume			How loud to play it (0 to 1).
		 * @param	Looped			Whether or not to loop this sound.
		 * 
		 * @return	A FlxSound object.
		 */
		static public function stream(URL:String,Volume:Number=1.0,Looped:Boolean=false):FlxSound
		{
			var s:FlxSound = sounds.recycle(FlxSound) as FlxSound;
			s.loadStream(URL,Looped);
			s.volume = Volume;
			s.play();
			return s;
		}
		
		/**
		 * Set <code>volume</code> to a number between 0 and 1 to change the global volume.
		 * 
		 * @default 0.5
		 */
		 static public function get volume():Number { return _volume; }
		 
		/**
		 * @private
		 */
		static public function set volume(Volume:Number):void
		{
			_volume = Volume;
			if(_volume < 0)
				_volume = 0;
			else if(_volume > 1)
				_volume = 1;
		}

		/**
		 * Called by FlxGame on state changes to stop and destroy sounds.
		 * 
		 * @param	ForceDestroy		Kill sounds even if they're flagged <code>survive</code>.
		 */
		static internal function destroySounds(ForceDestroy:Boolean=false):void
		{
			if((music != null) && (ForceDestroy || !music.survive))
			{
				music.destroy();
				music = null;
			}
			var i:uint = 0;
			var s:FlxSound;
			var l:uint = sounds.members.length;
			while(i < l)
			{
				s = sounds.members[i++] as FlxSound;
				if((s != null) && (ForceDestroy || !s.survive))
					s.destroy();
			}
		}
		
		/**
		 * Called by the game loop to make sure the sounds get updated each frame.
		 */
		static internal function updateSounds():void
		{
			if((music != null) && music.active)
				music.update();
			if((sounds != null) && sounds.active)
				sounds.update();
		}
		
		/**
		 * Pause all sounds currently playing.
		 */
		static public function pauseSounds():void
		{
			if((music != null) && music.active)
				music.pause();
			var i:uint = 0;
			var s:FlxSound;
			var l:uint = sounds.members.length;
			while(i < l)
			{
				s = sounds.members[i++] as FlxSound;
				if((s != null) && s.exists && s.active)
					s.pause();
			}
		}
		
		/**
		 * Resume playing existing sounds.
		 */
		static public function playSounds():void
		{
			if((music != null) && music.active)
				music.play();
			var i:uint = 0;
			var s:FlxSound;
			var l:uint = sounds.members.length;
			while(i < l)
			{
				s = sounds.members[i++] as FlxSound;
				if((s != null) && s.exists && s.active)
					s.play();
			}
		}
		
		/**
		 * Check the local bitmap cache to see if a bitmap with this key has been loaded already.
		 *
		 * @param	Key		The string key identifying the bitmap.
		 * 
		 * @return	Whether or not this file can be found in the cache.
		 */
		static public function checkBitmapCache(Key:String):Boolean
		{
			return (_cache[Key] != undefined) && (_cache[Key] != null);
		}
		
		/**
		 * Generates a new <code>BitmapData</code> object (a colored square) and caches it.
		 * 
		 * @param	Width	How wide the square should be.
		 * @param	Height	How high the square should be.
		 * @param	Color	What color the square should be (0xAARRGGBB)
		 * 
		 * @return	The <code>BitmapData</code> we just created.
		 */
		static public function createBitmap(Width:uint, Height:uint, Color:uint, Unique:Boolean=false, Key:String=null):BitmapData
		{
			var key:String = Key;
			if(key == null)
			{
				key = Width+"x"+Height+":"+Color;
				if(Unique && (_cache[key] != undefined) && (_cache[key] != null))
				{
					//Generate a unique key
					var inc:uint = 0;
					var ukey:String;
					do { ukey = key + inc++;
					} while((_cache[ukey] != undefined) && (_cache[ukey] != null));
					key = ukey;
				}
			}
			if(!checkBitmapCache(key))
				_cache[key] = new BitmapData(Width,Height,true,Color);
			return _cache[key];
		}
		
		/**
		 * Loads a bitmap from a file, caches it, and generates a horizontally flipped version if necessary.
		 * 
		 * @param	Graphic		The image file that you want to load.
		 * @param	Reverse		Whether to generate a flipped version.
		 * 
		 * @return	The <code>BitmapData</code> we just created.
		 */
		static public function addBitmap(Graphic:Class, Reverse:Boolean=false, Unique:Boolean=false, Key:String=null):BitmapData
		{
			var needReverse:Boolean = false;
			var key:String = Key;
			if(key == null)
			{
				key = String(Graphic)+(Reverse?"_REVERSE_":"");
				if(Unique && (_cache[key] != undefined) && (_cache[key] != null))
				{
					//Generate a unique key
					var inc:uint = 0;
					var ukey:String;
					do { ukey = key + inc++;
					} while((_cache[ukey] != undefined) && (_cache[ukey] != null));
					key = ukey;
				}
			}
			//If there is no data for this key, generate the requested graphic
			if(!checkBitmapCache(key))
			{
				_cache[key] = (new Graphic).bitmapData;
				if(Reverse) needReverse = true;
			}
			var pixels:BitmapData = _cache[key];
			if(!needReverse && Reverse && (pixels.width == (new Graphic).bitmapData.width))
				needReverse = true;
			if(needReverse)
			{
				var newPixels:BitmapData = new BitmapData(pixels.width<<1,pixels.height,true,0x00000000);
				newPixels.draw(pixels);
				var mtx:Matrix = new Matrix();
				mtx.scale(-1,1);
				mtx.translate(newPixels.width,0);
				newPixels.draw(pixels,mtx);
				pixels = newPixels;
			}
			return pixels;
		}
		
		static public function clearBitmapCache():void
		{
			_cache = new Object();
		}

		/**
		 * Tells the camera subsystem what <code>FlxCore</code> object to follow.
		 * 
		 * @param	Target		The object to follow.
		 * @param	Lerp		How much lag the camera should have (can help smooth out the camera movement).
		 */
		static public function follow(Target:FlxObject, Lerp:Number=1):void
		{
			followTarget = Target;
			followLerp = Lerp;
			_scrollTarget.x = (width>>1)-followTarget.x-(followTarget.width>>1);
			_scrollTarget.y = (height>>1)-followTarget.y-(followTarget.height>>1);
			scroll.x = _scrollTarget.x;
			scroll.y = _scrollTarget.y;
			doFollow();
		}
		
		/**
		 * Specify an additional camera component - the velocity-based "lead",
		 * or amount the camera should track in front of a sprite.
		 * 
		 * @param	LeadX		Percentage of X velocity to add to the camera's motion.
		 * @param	LeadY		Percentage of Y velocity to add to the camera's motion.
		 */
		static public function followAdjust(LeadX:Number = 0, LeadY:Number = 0):void
		{
			followLead = new Point(LeadX,LeadY);
		}
		
		/**
		 * Specify the boundaries of the level or where the camera is allowed to move.
		 * 
		 * @param	MinX				The smallest X value of your level (usually 0).
		 * @param	MinY				The smallest Y value of your level (usually 0).
		 * @param	MaxX				The largest X value of your level (usually the level width).
		 * @param	MaxY				The largest Y value of your level (usually the level height).
		 * @param	UpdateWorldBounds	Whether the quad tree's dimensions should be updated to match.
		 */
		static public function followBounds(MinX:int=0, MinY:int=0, MaxX:int=0, MaxY:int=0, UpdateWorldBounds:Boolean=true):void
		{
			followMin = new Point(-MinX,-MinY);
			followMax = new Point(-MaxX+width,-MaxY+height);
			if(followMax.x > followMin.x)
				followMax.x = followMin.x;
			if(followMax.y > followMin.y)
				followMax.y = followMin.y;
			if(UpdateWorldBounds)
				FlxU.setWorldBounds(MinX,MinY,MaxX-MinX,MaxY-MinY);
			doFollow();
		}
		
		/**
		 * Retrieves the Flash stage object (required for event listeners)
		 * 
		 * @return	A Flash <code>MovieClip</code> object.
		 */
		static public function get stage():Stage
		{
			if(_game.root != null)
				return _game.stage;
			return null;
		}
		
		/**
		 * Access the current game state from anywhere.
		 */
		static public function get state():FlxState
		{
			return _game._state;
		}
		
		/**
		 * Switch from the current game state to the one specified here.
		 */
		static public function switchState(State:FlxState):void
		{
			_game._requestedState = State;
		}
		
		/**
		 * Stops and resets the camera.
		 */
		static public function unfollow():void
		{
			followTarget = null;
			followLead = null;
			followLerp = 1;
			followMin = null;
			followMax = null;
			if(scroll == null)
				scroll = new Point();
			else
				scroll.x = scroll.y = 0;
			if(_scrollTarget == null)
				_scrollTarget = new Point();
			else
				_scrollTarget.x = _scrollTarget.y = 0;
		}
		
		/**
		 * Change the way the debugger's windows are laid out.
		 * 
		 * @param	Layout		Check aux/FlxDebugger for helpful constants like FlxDebugger.LEFT, etc.
		 */
		static public function setDebuggerLayout(Layout:uint):void
		{
			if(_game._debugger != null)
				_game._debugger.setLayout(Layout);
		}
		
		/**
		 * Just resets the debugger windows to whatever the sizes and positions of the selected layout are.
		 */
		static public function resetDebuggerLayout():void
		{
			if(_game._debugger != null)
				_game._debugger.resetLayout();
		}

		/**
		 * Called by <code>FlxGame</code> to set up <code>FlxG</code> during <code>FlxGame</code>'s constructor.
		 */
		static internal function init(Game:FlxGame,Width:uint,Height:uint):void
		{
			_game = Game;
			width = Width;
			height = Height;
			
			mute = false;
			_volume = 0.5;
			sounds = new FlxGroup();
			
			clearBitmapCache();
			
			mouse = new Mouse();
			keys = new Keyboard();
			mobile = false;

			FlxG.levels = new Array();
			FlxG.scores = new Array();
			FlxU.setWorldBounds(0,0,FlxG.width,FlxG.height);
		}
		
		static internal function reset():void
		{
			clearBitmapCache();
			quake = new Quake(_game._zoom);
			if(flash != null)
				flash.destroy();
			flash = new Flash();
			if(fade != null)
				fade.destroy();
			fade = new Fade();
			
			resetInput();
			destroySounds(true);
			scroll = null;
			_scrollTarget = null;
			unfollow();
			levels.length = 0;
			scores.length = 0;
			level = 0;
			score = 0;
			paused = false;
			timeScale = 1.0;
			FlxG.elapsed = 0;
			FlxG.globalSeed = Math.random();
		}

		/**
		 * Internal function that updates the camera and parallax scrolling.
		 */
		static internal function doFollow():void
		{
			if(followTarget != null)
			{
				_scrollTarget.x = (width>>1)-followTarget.x-(followTarget.width>>1);
				_scrollTarget.y = (height>>1)-followTarget.y-(followTarget.height>>1);
				if((followLead != null) && (followTarget is FlxSprite))
				{
					_scrollTarget.x -= (followTarget as FlxSprite).velocity.x*followLead.x;
					_scrollTarget.y -= (followTarget as FlxSprite).velocity.y*followLead.y;
				}
				scroll.x += (_scrollTarget.x-scroll.x)*followLerp*FlxG.elapsed;
				scroll.y += (_scrollTarget.y-scroll.y)*followLerp*FlxG.elapsed;
				
				if(followMin != null)
				{
					if(scroll.x > followMin.x)
						scroll.x = followMin.x;
					if(scroll.y > followMin.y)
						scroll.y = followMin.y;
				}
				
				if(followMax != null)
				{
					if(scroll.x < followMax.x)
						scroll.x = followMax.x;
					if(scroll.y < followMax.y)
						scroll.y = followMax.y;
				}
			}
		}
		
		/**
		 * Calls update on the keyboard and mouse input tracking objects.
		 */
		static internal function updateInput():void
		{
			keys.update();
			if(!_game._debuggerUp || !_game._debugger.hasMouse)
				mouse.update(_game._buffer.mouseX,_game._buffer.mouseY);
		}
	}
}
