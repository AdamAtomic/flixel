package org.flixel
{
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import org.flixel.data.*;
	
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
		static public var LIBRARY_MINOR_VERSION:uint = 43;

		/**
		 * Internal tracker for game object (so we can pause & unpause)
		 */
		static protected var _game:FlxGame;
		/**
		 * Internal tracker for game pause state.
		 */
		static protected var _pause:Boolean;
		/**
		 * Whether you are running in Debug or Release mode.
		 * Set automatically by <code>FlxFactory</code> during startup.
		 */
		static public var debug:Boolean;
		/**
		 * Set <code>showBounds</code> to true to display the bounding boxes of the in-game objects.
		 */
		static public var showBounds:Boolean;
		
		/**
		 * Represents the amount of time in seconds that passed since last frame.
		 */
		static public var elapsed:Number;
		/**
		 * Essentially locks the framerate to a minimum value - any slower and you'll get slowdown instead of frameskip; default is 1/30th of a second.
		 */
		static public var maxElapsed:Number;
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
		static public var mouse:FlxMouse;
		/**
		 * A reference to a <code>FlxKeyboard</code> object.  Important for input!
		 */
		static public var keys:FlxKeyboard;
		/**
		 * An array of <code>FlxGamepad</code> objects.  Important for input!
		 */
		static public var gamepads:Array;
		
		/**
		 * A handy container for a background music object.
		 */
		static public var music:FlxSound;
		/**
		 * A list of all the sounds being played in the game.
		 */
		static public var sounds:Array;
		/**
		 * Internal flag for whether or not the game is muted.
		 */
		static protected var _mute:Boolean;
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
		 * Access to the Kongregate high scores and achievements API.
		 */
		static public var kong:FlxKong;
		
		/**
		 * The support panel (twitter, reddit, stumbleupon, paypal, etc) visor thing
		 */
		static public var panel:FlxPanel;
		/**
		 * A special effect that shakes the screen.  Usage: FlxG.quake.start();
		 */
		static public var quake:FlxQuake;
		/**
		 * A special effect that flashes a color on the screen.  Usage: FlxG.flash.start();
		 */
		static public var flash:FlxFlash;
		/**
		 * A special effect that fades a color onto the screen.  Usage: FlxG.fade.start();
		 */
		static public var fade:FlxFade;
		
		/**
		 * Log data to the developer console.
		 * 
		 * @param	Data		Anything you want to log to the console.
		 */
		static public function log(Data:Object):void
		{
			if((_game != null) && (_game._console != null))
				_game._console.log((Data == null)?"ERROR: null object":Data.toString());
		}
		
		/**
		 * Set <code>pause</code> to true to pause the game, all sounds, and display the pause popup.
		 */
		static public function get pause():Boolean
		{
			return _pause;
		}
		
		/**
		 * @private
		 */
		static public function set pause(Pause:Boolean):void
		{
			var op:Boolean = _pause;
			_pause = Pause;
			if(_pause != op)
			{
				if(_pause)
				{
					_game.pauseGame();
					pauseSounds();
				}
				else
				{
					_game.unpauseGame();
					playSounds();
				}
			}
		}
		
		/**
		 * The game and SWF framerate; default is 60.
		 */
		static public function get framerate():uint
		{
			return _game._framerate;
		}
		
		/**
		 * @private
		 */
		static public function set framerate(Framerate:uint):void
		{
			_game._framerate = Framerate;
			if(!_game._paused && (_game.stage != null))
				_game.stage.frameRate = Framerate;
		}
		
		/**
		 * The game and SWF framerate while paused; default is 10.
		 */
		static public function get frameratePaused():uint
		{
			return _game._frameratePaused;
		}
		
		/**
		 * @private
		 */
		static public function set frameratePaused(Framerate:uint):void
		{
			_game._frameratePaused = Framerate;
			if(_game._paused && (_game.stage != null))
				_game.stage.frameRate = Framerate;
		}
		
		/**
		 * Reset the input helper objects (useful when changing screens or states)
		 */
		static public function resetInput():void
		{
			keys.reset();
			mouse.reset();
			var i:uint = 0;
			var l:uint = gamepads.length;
			while(i < l)
				gamepads[i++].reset();
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
			var i:uint = 0;
			var sl:uint = sounds.length;
			while(i < sl)
			{
				if(!(sounds[i] as FlxSound).active)
					break;
				i++;
			}
			if(sounds[i] == null)
				sounds[i] = new FlxSound();
			var s:FlxSound = sounds[i];
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
			var i:uint = 0;
			var sl:uint = sounds.length;
			while(i < sl)
			{
				if(!(sounds[i] as FlxSound).active)
					break;
				i++;
			}
			if(sounds[i] == null)
				sounds[i] = new FlxSound();
			var s:FlxSound = sounds[i];
			s.loadStream(URL,Looped);
			s.volume = Volume;
			s.play();
			return s;
		}
		
		/**
		 * Set <code>mute</code> to true to turn off the sound.
		 * 
		 * @default false
		 */
		static public function get mute():Boolean
		{
			return _mute;
		}
		
		/**
		 * @private
		 */
		static public function set mute(Mute:Boolean):void
		{
			_mute = Mute;
			changeSounds();
		}
		
		/**
		 * Get a number that represents the mute state that we can multiply into a sound transform.
		 * 
		 * @return		An unsigned integer - 0 if muted, 1 if not muted.
		 */
		static public function getMuteValue():uint
		{
			if(_mute)
				return 0;
			else
				return 1;
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
			changeSounds();
		}

		/**
		 * Called by FlxGame on state changes to stop and destroy sounds.
		 * 
		 * @param	ForceDestroy		Kill sounds even if they're flagged <code>survive</code>.
		 */
		static internal function destroySounds(ForceDestroy:Boolean=false):void
		{
			if(sounds == null)
				return;
			if((music != null) && (ForceDestroy || !music.survive))
				music.destroy();
			var i:uint = 0;
			var s:FlxSound;
			var sl:uint = sounds.length;
			while(i < sl)
			{
				s = sounds[i++] as FlxSound;
				if((s != null) && (ForceDestroy || !s.survive))
					s.destroy();
			}
		}

		/**
		 * An internal function that adjust the volume levels and the music channel after a change.
		 */
		static protected function changeSounds():void
		{
			if((music != null) && music.active)
				music.updateTransform();
			var i:uint = 0;
			var s:FlxSound;
			var sl:uint = sounds.length;
			while(i < sl)
			{
				s = sounds[i++] as FlxSound;
				if((s != null) && s.active)
					s.updateTransform();
			}
		}
		
		/**
		 * Called by the game loop to make sure the sounds get updated each frame.
		 */
		static internal function updateSounds():void
		{
			if((music != null) && music.active)
				music.update();
			var i:uint = 0;
			var s:FlxSound;
			var sl:uint = sounds.length;
			while(i < sl)
			{
				s = sounds[i++] as FlxSound;
				if((s != null) && s.active)
					s.update();
			}
		}
		
		/**
		 * Internal helper, pauses all game sounds.
		 */
		static protected function pauseSounds():void
		{
			if((music != null) && music.active)
				music.pause();
			var i:uint = 0;
			var s:FlxSound;
			var sl:uint = sounds.length;
			while(i < sl)
			{
				s = sounds[i++] as FlxSound;
				if((s != null) && s.active)
					s.pause();
			}
		}
		
		/**
		 * Internal helper, pauses all game sounds.
		 */
		static protected function playSounds():void
		{
			if((music != null) && music.active)
				music.play();
			var i:uint = 0;
			var s:FlxSound;
			var sl:uint = sounds.length;
			while(i < sl)
			{
				s = sounds[i++] as FlxSound;
				if((s != null) && s.active)
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
				key = String(Graphic);
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
			if((_game._state != null)  && (_game._state.parent != null))
				return _game._state.parent.stage;
			return null;
		}
		
		/**
		 * Safely access the current game state.
		 */
		static public function get state():FlxState
		{
			return _game._state;
		}
		
		/**
		 * @private
		 */
		static public function set state(State:FlxState):void
		{
			_game.switchState(State);
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
		 * Called by <code>FlxGame</code> to set up <code>FlxG</code> during <code>FlxGame</code>'s constructor.
		 */
		static internal function setGameData(Game:FlxGame,Width:uint,Height:uint,Zoom:uint):void
		{
			_game = Game;
			_cache = new Object();
			width = Width;
			height = Height;
			_mute = false;
			_volume = 0.5;
			sounds = new Array();
			mouse = new FlxMouse();
			keys = new FlxKeyboard();
			gamepads = new Array(4);
			gamepads[0] = new FlxGamepad();
			gamepads[1] = new FlxGamepad();
			gamepads[2] = new FlxGamepad();
			gamepads[3] = new FlxGamepad();
			scroll = null;
			_scrollTarget = null;
			unfollow();
			FlxG.levels = new Array();
			FlxG.scores = new Array();
			level = 0;
			score = 0;
			kong = null;
			pause = false;
			timeScale = 1.0;
			framerate = 60;
			frameratePaused = 10;
			maxElapsed = 0.0333333;
			FlxG.elapsed = 0;
			showBounds = false;
			
			mobile = false;
			
			panel = new FlxPanel();
			quake = new FlxQuake(Zoom);
			flash = new FlxFlash();
			fade = new FlxFade();

			FlxU.setWorldBounds(0,0,FlxG.width,FlxG.height);
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
			mouse.update(state.mouseX,state.mouseY,scroll.x,scroll.y);
			var i:uint = 0;
			var l:uint = gamepads.length;
			while(i < l)
				gamepads[i++].update();
		}
	}
}
