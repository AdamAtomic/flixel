package org.flixel
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import org.flixel.data.FlxKeyboard;
	import org.flixel.data.FlxKong;
	import org.flixel.data.FlxMouse;
	
	//@desc		This is a global helper class full of useful functions for audio, input, basic info, and the camera system
	public class FlxG
	{
		[Embed(source="data/cursor.png")] static protected var ImgDefaultCursor:Class;
		
		static public var LIBRARY_NAME:String = "flixel";
		static public var LIBRARY_MAJOR_VERSION:uint = 1;
		static public var LIBRARY_MINOR_VERSION:uint = 47;

		static protected var _pause:Boolean;
		static protected var _game:FlxGame;
		static public var debug:Boolean;
		
		//@desc Represents the amount of time in seconds that passed since last frame
		static public var elapsed:Number;
		//@desc A reference or pointer to the current FlxState object being used by the game
		static public var state:FlxState;
		//@desc The width of the screen in game pixels
		static public var width:uint;
		//@desc The height of the screen in game pixels
		static public var height:uint;
		//@desc FlxG.levels and FlxG.scores are generic global variables that can be used for various cross-state stuff
		static public var levels:Array;
		static public var level:int;
		static public var scores:Array;
		static public var score:int;
		//@desc FlxG.saves is a generic bucket for storing FlxSaves so you can access them whenever you want
		static public var saves:Array; 
		static public var save:int;

		//@desc The current game coordinates of the mouse pointer (not necessarily the screen coordinates)
		static public var mouse:FlxMouse;
		static public var keys:FlxKeyboard;
		
		//audio
		static public var music:FlxSound;
		static public var sounds:Array;
		static protected var _mute:Boolean;
		static protected var _volume:Number;
		
		//Ccmera system variables
		static public var followTarget:FlxCore;
		static public var followLead:Point;
		static public var followLerp:Number;
		static public var followMin:Point;
		static public var followMax:Point;
		static protected var _scrollTarget:Point;
		
		//graphics stuff
		static public var scroll:Point;
		static public var buffer:BitmapData;
		static protected var _cache:Object;
		
		//Kongregate API object
		static public var kong:FlxKong;
		
		//Random number stuff
		static protected var _seed:Number;
		static protected var _originalSeed:Number;
		
		//@desc		The setter for FlxG.pause - pauses the game + sounds and displays the pause message
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
		
		//@desc		The getter for FlxG.pause - just returns whether the game is paused or not
		static public function get pause():Boolean
		{
			return _pause;
		}
		
		//@desc		Call this function to reset the input objects (useful when changing screens or states)
		static public function resetInput():void
		{
			keys.reset();
			mouse.reset();
		}
		
		//@desc		Picks an entry at random from an array
		//@param	A		The array you want to pick the object from
		//@return	Any object
		static public function getRandom(A:Array):Object
		{
			return A[int(FlxG.random()*A.length)];
		}
		
		//@desc		Find the first entry in the array that doesn't "exist"
		//@param	A		The array you want to search
		//@return	Anything based on FlxCore (FlxSprite, FlxText, FlxBlock, etc)
		static public function getNonexist(A:Array):FlxCore
		{
			var l:uint = A.length;
			if(l <= 0) return null;
			var i:uint = 0;
			do
			{
				if(!A[i].exists)
					return A[i];
			} while (++i < l);
			return null;
		}
		
		//@desc		Set up and autoplay a music track
		//@param	Music		The sound file you want to loop in the background
		//@param	Volume		How loud the sound should be, from 0 to 1
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
		
		//@desc		Creates a new sound object from an embedded Class object
		//@param	EmbeddedSound	The sound you want to play
		//@param	Volume			How loud to play it (0 to 1)
		//@param	Looped			Whether or not to loop this sound
		//@return	A FlxSound object
		static public function play(EmbeddedSound:Class,Volume:Number=1.0,Looped:Boolean=false):FlxSound
		{
			var i:uint;
			var sl:uint = sounds.length;
			for(i = 0; i < sl; i++)
				if(!sounds[i].active)
					break;
			if(sounds[i] == null)
				sounds[i] = new FlxSound();
			var s:FlxSound = sounds[i];
			s.loadEmbedded(EmbeddedSound,Looped);
			s.volume = Volume;
			s.play();
			return s;
		}
		
		//@desc		Creates a new sound object from a URL
		//@param	EmbeddedSound	The sound you want to play
		//@param	Volume			How loud to play it (0 to 1)
		//@param	Looped			Whether or not to loop this sound
		//@return	A FlxSound object
		static public function stream(URL:String,Volume:Number=1.0,Looped:Boolean=false):FlxSound
		{
			var i:uint;
			var sl:uint = sounds.length;
			for(i = 0; i < sl; i++)
				if(!sounds[i].active)
					break;
			if(sounds[i] == null)
				sounds[i] = new FlxSound();
			var s:FlxSound = sounds[i];
			s.loadStream(URL,Looped);
			s.volume = Volume;
			s.play();
			return s;
		}
		
		//@desc		Mutes the sound
		//@param	SoundOff	Whether the sound should be off or on
		static public function set mute(Mute:Boolean):void
		{
			_mute = Mute;
			changeSounds();
		}
		
		//@desc		Check to see if the game is muted
		//@return	Whether the game is muted
		static public function get mute():Boolean
		{
			return _mute;
		}
		
		//@desc		Get a number we can multiply into a sound transform
		//@return	An unsigned integer - 0 if muted, 1 if not muted
		static public function getMuteValue():uint
		{
			if(_mute)
				return 0;
			else
				return 1;
		}
		
		//@desc		Change the volume of the game
		//@param	Volume		A number from 0 to 1
		static public function set volume(Volume:Number):void
		{
			_volume = Volume;
			if(_volume < 0)
				_volume = 0;
			else if(_volume > 1)
				_volume = 1;
			changeSounds();
		}
		
		//@desc		Find out how loud the game is currently
		//@param	A number from 0 to 1
		static public function get volume():Number { return _volume; }
		
		//@desc		Called by FlxGame on state changes to stop and destroy sounds
		static internal function destroySounds(ForceDestroy:Boolean=false):void
		{
			if(sounds == null)
				return;
			if((music != null) && (ForceDestroy || !music.survive))
				music.destroy();
			var sl:uint = sounds.length;
			for(var i:uint = 0; i < sl; i++)
				if(ForceDestroy || !sounds[i].survive)
					sounds[i].destroy();
		}

		//@desc		An internal function that adjust the volume levels and the music channel after a change
		static protected function changeSounds():void
		{
			if((music != null) && music.active)
				music.updateTransform();
			var sl:uint = sounds.length;
			for(var i:uint = 0; i < sl; i++)
				if(sounds[i].active)
					sounds[i].updateTransform();
		}
		
		//@desc		Called by the game loop to make sure the sounds get updated each frame
		static internal function updateSounds():void
		{
			if((music != null) && music.active)
				music.update();
			var sl:uint = sounds.length;
			for(var i:uint = 0; i < sl; i++)
				if(sounds[i].active)
					sounds[i].update();
		}
		
		static protected function pauseSounds():void
		{
			if((music != null) && music.active)
				music.pause();
			var sl:uint = sounds.length;
			for(var i:uint = 0; i < sl; i++)
				if(sounds[i].active)
					sounds[i].pause();
		}
		
		static protected function playSounds():void
		{
			if((music != null) && music.active)
				music.play();
			var sl:uint = sounds.length;
			for(var i:uint = 0; i < sl; i++)
				if(sounds[i].active)
					sounds[i].play();
		}
		
		//@desc		Generates a new BitmapData object (basically a colored square :P) and caches it
		//@param	Width	How wide the square should be
		//@param	Height	How high the square should be
		//@param	Color	What color the square should be
		//@return	This object is used during the sprite blitting process
		static public function createBitmap(Width:uint, Height:uint, Color:uint,Unique:Boolean):BitmapData
		{
			var key:String = Width+"x"+Height+":"+Color;
			var gen:Boolean = false;
			if(Unique && (_cache[ukey] != undefined) && (_cache[ukey] != null))
			{
				var inc:uint = 0;
				var ukey:String;
				do { ukey = key + inc++;
				} while((_cache[ukey] != undefined) && (_cache[ukey] != null));
				key = ukey;
			}
			_cache[key] = new BitmapData(Width,Height,true,Color);
			return _cache[key];
		}
		
		//@desc		Loads a bitmap from a file, caches it, and generates a horizontally flipped version if necessary
		//@param	Graphic		The image file that you want to load
		//@param	Reverse		Whether to generate a flipped version
		static public function addBitmap(Graphic:Class,Reverse:Boolean=false):BitmapData
		{
			var needReverse:Boolean = false;
			var key:String = String(Graphic);
			if((_cache[key] == undefined) || (_cache[key] == null))
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
		
		//@desc		Rotates a point in 2D space around another point by the given angle
		//@param	X		The X coordinate of the point you want to rotate
		//@param	Y		The Y coordinate of the point you want to rotate
		//@param	PivotX	The X coordinate of the point you want to rotate around
		//@param	PivotY	The Y coordinate of the point you want to rotate around
		//@param	Angle	Rotate the point by this many degrees
		//@return	A Flash Point object containing the coordinates of the rotated point
		static public function rotatePoint(X:Number, Y:Number, PivotX:Number, PivotY:Number, Angle:Number):Point
		{
			var radians:Number = -Angle / 180 * Math.PI;
			var dx:Number = X-PivotX;
			var dy:Number = PivotY-Y;
			return new Point(PivotX + Math.cos(radians)*dx - Math.sin(radians)*dy, PivotY - (Math.sin(radians)*dx + Math.cos(radians)*dy));
		};
		
		//@desc		Calculates the angle between a point and the origin (0,0)
		//@param	X		The X coordinate of the point
		//@param	Y		The Y coordinate of the point
		//@return	The angle in degrees
		static public function getAngle(X:Number, Y:Number):Number
		{
			return Math.atan2(Y,X) * 180 / Math.PI;
		};

		//@desc		Tells the camera subsystem what FlxCore object to follow
		//@param	Target		The object to follow
		//@param	Lerp		How much lag the camera should have (can help smooth out the camera movement)
		static public function follow(Target:FlxCore, Lerp:Number=1):void
		{
			followTarget = Target;
			followLerp = Lerp;
			scroll.x = _scrollTarget.x = (width>>1)-followTarget.x-(followTarget.width>>1);
			scroll.y = _scrollTarget.y = (height>>1)-followTarget.y-(followTarget.height>>1);
			doFollow();
		}
		
		//@desc		Specify an additional camera component - the velocity-based "lead", or amount the camera should track in front of a sprite
		//@param	LeadX		Percentage of X velocity to add to the camera's motion
		//@param	LeadY		Percentage of Y velocity to add to the camera's motion
		static public function followAdjust(LeadX:Number = 0, LeadY:Number = 0):void
		{
			followLead = new Point(LeadX,LeadY);
		}
		
		//@desc		Specify the boundaries of the level or where the camera is allowed to move
		//@param	MinX	The smallest X value of your level (usually 0)
		//@param	MinY	The smallest Y value of your level (usually 0)
		//@param	MaxX	The largest X value of your level (usually the level width)
		//@param	MaxY	The largest Y value of your level (usually the level height)
		static public function followBounds(MinX:int=0, MinY:int=0, MaxX:int=0, MaxY:int=0):void
		{
			followMin = new Point(-MinX,-MinY);
			followMax = new Point(-MaxX+width,-MaxY+height);
			if(followMax.x > followMin.x)
				followMax.x = followMin.x;
			if(followMax.y > followMin.y)
				followMax.y = followMin.y;
			doFollow();
		}
		
		//@desc		A fairly stupid tween-like function that takes a starting velocity and some other factors and returns an altered velocity
		//@param	Velocity		Any component of velocity (e.g. 20)
		//@param	Acceleration	Rate at which the velocity is changing
		//@param	Drag			Really kind of a deceleration, this is how much the velocity changes if Acceleration is not set
		//@param	Max				An absolute value cap for the velocity
		static public function computeVelocity(Velocity:Number, Acceleration:Number=0, Drag:Number=0, Max:Number=10000):Number
		{
			if(Acceleration != 0)
				Velocity += Acceleration*FlxG.elapsed;
			else if(Drag != 0)
			{
				var d:Number = Drag*FlxG.elapsed;
				if(Velocity - d > 0)
					Velocity -= d;
				else if(Velocity + d < 0)
					Velocity += d;
				else
					Velocity = 0;
			}
			if((Velocity != 0) && (Max != 10000))
			{
				if(Velocity > Max)
					Velocity = Max;
				else if(Velocity < -Max)
					Velocity = -Max;
			}
			return Velocity;
		}
		
		//@desc		Checks to see if a FlxCore overlaps any of the FlxCores in the array, and calls a function when they do
		//@param	Cores		An array of FlxCore objects
		//@param	Core		A FlxCore object
		//@param	Collide		A function that takes two sprites as parameters (first the one from Array, then Sprite)
		static public function overlapArray(Cores:Array,Core:FlxCore,Collide:Function=null):void
		{
			if((Core == null) || !Core.exists || Core.dead) return;
			var c:FlxCore;
			var l:uint = Cores.length;
			for(var i:uint = 0; i < l; i++)
			{
				c = Cores[i];
				if((c === Core) || (c == null) || !c.exists || c.dead) continue;
				if(c.overlaps(Core))
				{
					if(Collide != null)
						Collide(c,Core);
					else
					{
						c.kill();
						Core.kill();
					}
				}
			}
		}
		
		//@desc		Checks to see if any FlxCore in Array1 overlaps any FlxCore in Array2, and calls Collide when they do
		//@param	Cores1		An array of FlxCore objects
		//@param	Cores2		Another array of FlxCore objects
		//@param	Collide		A function that takes two FlxCore objects as parameters (first the one from Array1, then the one from Array2)
		static public function overlapArrays(Cores1:Array,Cores2:Array,Collide:Function=null):void
		{
			var i:uint;
			var j:uint;
			var core1:FlxCore;
			var core2:FlxCore;
			var l1:uint = Cores1.length;
			var l2:uint = Cores2.length;
			if(Cores1 === Cores2)
			{
				for(i = 0; i < l1; i++)
				{
					core1 = Cores1[i];
					if((core1 == null) || !core1.exists || core1.dead) continue;
					for(j = i+1; j < l2; j++)
					{
						core2 = Cores2[j];
						if((core2 == null) || !core2.exists || core2.dead) continue;
						if(core1.overlaps(core2))
						{
							if(Collide != null)
								Collide(core1,core2);
							else
							{
								core1.kill();
								core2.kill();
							}
						}
					}
				}
			}
			else
			{
				for(i = 0; i < Cores1.length; i++)
				{
					core1 = Cores1[i];
					if((core1 == null) || !core1.exists || core1.dead) continue;
					for(j = 0; j < Cores2.length; j++)
					{
						core2 = Cores2[j];
						if((core1 === core2) || (core2 == null) || !core2.exists || core2.dead) continue;
						if(core1.overlaps(core2))
						{
							if(Collide != null)
								Collide(core1,core2);
							else
							{
								core1.kill();
								core2.kill();
							}
						}
					}
				}
			}
		}
		
		//@desc		Collides a FlxCore against the FlxCores in the array 
		//@param	Cores		An array of FlxCore objects
		//@param	Core		A FlxCore object
		static public function collideArray(Cores:Array,Core:FlxCore):void
		{
			if((Core == null) || !Core.exists || Core.dead) return;
			var core:FlxCore;
			var l:uint = Cores.length;
			for(var i:uint = 0; i < l; i++)
			{
				core = Cores[i];
				if((core === Core) || (core == null) || !core.exists || core.dead) continue;
				core.collide(Core);
			}
		}
		
		//@desc		Collides a FlxCore against the FlxCores in the array on the X axis ONLY
		//@param	Cores		An array of FlxCore objects
		//@param	Core		A FlxCore object
		static public function collideArrayX(Cores:Array,Core:FlxCore):void
		{
			if((Core == null) || !Core.exists || Core.dead) return;
			var core:FlxCore;
			var l:uint = Cores.length;
			for(var i:uint = 0; i < l; i++)
			{
				core = Cores[i];
				if((core === Core) || (core == null) || !core.exists || core.dead) continue;
				core.collideX(Core);
			}
		}
		
		//@desc		Collides a FlxSprite against the FlxCores in the array on the Y axis ONLY
		//@param	Cores		An array of FlxCore objects
		//@param	Core		A FlxSprite object
		static public function collideArrayY(Cores:Array,Core:FlxCore):void
		{
			if((Core == null) || !Core.exists || Core.dead) return;
			var core:FlxCore;
			var l:uint = Cores.length;
			for(var i:uint = 0; i < l; i++)
			{
				core = Cores[i];
				if((core === Core) || (core == null) || !core.exists || core.dead) continue;
				core.collideY(Core);
			}
		}
		
		//@desc		Collides the first array of FlxCores against the second array of FlxCores
		//@param	Array1		An array of FlxCore objects
		//@param	Array2		An array of FlxCore objects
		static public function collideArrays(Cores1:Array,Cores2:Array):void
		{
			var i:uint;
			var j:uint;
			var core1:FlxCore;
			var core2:FlxCore;
			var l1:uint = Cores1.length;
			var l2:uint = Cores2.length;
			if(Cores1 === Cores2)
			{
				for(i = 0; i < l1; i++)
				{
					core1 = Cores1[i];
					if((core1 == null) || !core1.exists || core1.dead) continue;
					for(j = i+1; j < l2; j++)
					{
						core2 = Cores2[j];
						if((core2 == null) || !core2.exists || core2.dead) continue;
						core1.collide(core2);
					}
				}
			}
			else
			{
				for(i = 0; i < l1; i++)
				{
					core1 = Cores1[i];
					if((core1 == null) || !core1.exists || core1.dead) continue;
					for(j = 0; j < l2; j++)
					{
						core2 = Cores2[j];
						if((core1 === core2) || (core2 == null) || !core2.exists || core2.dead) continue;
						core1.collide(core2);
					}
				}
			}
		}
		
		//@desc		Collides the first array of FlxCores against the second array of FlxCores on the X axis only
		//@param	Array1		An array of FlxCore objects
		//@param	Array2		An array of FlxCore objects
		static public function collideArraysX(Cores1:Array,Cores2:Array):void
		{
			var i:uint;
			var j:uint;
			var core1:FlxCore;
			var core2:FlxCore;
			var l1:uint = Cores1.length;
			var l2:uint = Cores2.length;
			if(Cores1 === Cores2)
			{
				for(i = 0; i < l1; i++)
				{
					core1 = Cores1[i];
					if((core1 == null) || !core1.exists || core1.dead) continue;
					for(j = i+1; j < l2; j++)
					{
						core2 = Cores2[j];
						if((core2 == null) || !core2.exists || core2.dead) continue;
						core1.collideX(core2);
					}
				}
			}
			else
			{
				for(i = 0; i < l1; i++)
				{
					core1 = Cores1[i];
					if((core1 == null) || !core1.exists || core1.dead) continue;
					for(j = 0; j < l2; j++)
					{
						core2 = Cores2[j];
						if((core1 === core2) || (core2 == null) || !core2.exists || core2.dead) continue;
						core1.collideX(core2);
					}
				}
			}
		}
		
		//@desc		Collides the first array of FlxCores against the second array of FlxCores on the Y axis only
		//@param	Array1		An array of FlxCore objects
		//@param	Array2		An array of FlxCore objects
		static public function collideArraysY(Cores1:Array,Cores2:Array):void
		{
			var i:uint;
			var j:uint;
			var core1:FlxCore;
			var core2:FlxCore;
			var l1:uint = Cores1.length;
			var l2:uint = Cores2.length;
			if(Cores1 === Cores2)
			{
				for(i = 0; i < l1; i++)
				{
					core1 = Cores1[i];
					if((core1 == null) || !core1.exists || core1.dead) continue;
					for(j = i+1; j < l2; j++)
					{
						core2 = Cores2[j];
						if((core2 == null) || !core2.exists || core2.dead) continue;
						core1.collideY(core2);
					}
				}
			}
			else
			{
				for(i = 0; i < l1; i++)
				{
					core1 = Cores1[i];
					if((core1 == null) || !core1.exists || core1.dead) continue;
					for(j = 0; j < l2; j++)
					{
						core2 = Cores2[j];
						if((core1 === core2) || (core2 == null) || !core2.exists || core2.dead) continue;
						core1.collideY(core2);
					}
				}
			}
		}
		
		//@desc		Switch from one FlxState to another
		//@param	State		The class name of the state you want (e.g. PlayState)
		static public function switchState(State:Class):void
		{
			_game.switchState(State);
		}
		
		//@desc		Log data to the developer console
		//@param	Data		The data (in string format) that you wanted to write to the console
		static public function log(Data:Object):void
		{
			_game._console.log(Data.toString());
		}
		
		//@desc		Shake the screen
		//@param	Intensity	Percentage of screen size representing the maximum distance that the screen can move during the 'quake'
		//@param	Duration	The length in seconds that the "quake" should last
		static public function quake(Intensity:Number,Duration:Number=0.5):void
		{
			_game._quake.reset(Intensity,Duration);
		}
		
		//@desc		Temporarily fill the screen with a certain color, then fade it out
		//@param	Color			The color you want to use
		//@param	Duration		How long it takes for the flash to fade
		//@param	FlashComplete	A function you want to run when the flash finishes
		//@param	Force			Force the effect to reset
		static public function flash(Color:uint, Duration:Number=1, FlashComplete:Function=null, Force:Boolean=false):void
		{
			_game._flash.restart(Color,Duration,FlashComplete,Force);
		}
		
		//@desc		Fade the screen out to this color
		//@param	Color			The color you want to use
		//@param	Duration		How long it should take to fade the screen out
		//@param	FadeComplete	A function you want to run when the fade finishes
		//@param	Force			Force the effect to reset
		static public function fade(Color:uint, Duration:Number=1, FadeComplete:Function=null, Force:Boolean=false):void
		{
			_game._fade.restart(Color,Duration,FadeComplete,Force);
		}
		
		//@desc		Set the mouse cursor to some graphic file
		//@param	CursorGraphic	The image you want to use for the cursor
		static public function showCursor(CursorGraphic:Class=null):void
		{
			if(CursorGraphic == null)
				_game._cursor = _game._buffer.addChild(new ImgDefaultCursor) as Bitmap;
			else
				_game._cursor = _game._buffer.addChild(new CursorGraphic) as Bitmap;
		}
		
		//@desc		Hides the mouse cursor
		static public function hideCursor():void
		{
			if(_game._cursor == null) return;
			_game._buffer.removeChild(_game._cursor);
			_game._cursor = null;
		}
		
		//@desc		Switch to a different web page
		static public function openURL(URL:String):void
		{
			navigateToURL(new URLRequest(URL), "_blank");
		}

		//@desc		Tell the support panel to slide onto the screen
		//@param	Top		Whether to slide on from the top or the bottom
		static public function showSupportPanel(Top:Boolean=true):void
		{
			_game._panel.show(Top);
		}
		
		//@desc		Conceals the support panel
		static public function hideSupportPanel():void
		{
			_game._panel.hide();
		}
		
		//@desc		Generate a pseudo-random number
		//@param	UseGlobalSeed		Whether or not to use the stored FlxG.seed value to calculate it
		//@return	A pseudo-random Number object
		static public function random(UseGlobalSeed:Boolean=true):Number
		{
			if(UseGlobalSeed && !isNaN(_seed))
			{
				var random:Number = randomize(_seed);
				_seed = mutate(_seed,random);
				return random;
			}
			else
				return Math.random();
		}
		
		//@desc		Generate a pseudo-random number
		//@param	Seed		The number to use to generate a new random value
		//@return	A pseudo-random Number object
		static public function randomize(Seed:Number):Number
		{
			return ((69621 * int(Seed * 0x7FFFFFFF)) % 0x7FFFFFFF) / 0x7FFFFFFF;
		}
		
		//@desc		Mutate a seed, usually using the result of randomize()
		//@param	Seed		The number to mutate
		//@param	Mutator		The value to use in the mutation
		//@return	A predictably-altered version of the Seed
		static public function mutate(Seed:Number,Mutator:Number):Number
		{
			Seed += Mutator;
			if(Seed > 1) Seed -= int(Seed);
			return Seed;
		}

		//@desc		Fetches the original global FlxG.seed value the user set
		//@return	The original seed value
		static public function get seed():Number
		{
			return _originalSeed;
		}
		
		//@desc		Allow the user to set the global seed
		//@param	Seed		The new number to use as a seed in random()
		static public function set seed(Seed:Number):void
		{
			_seed = Seed;
			_originalSeed = _seed;
		}

		//@desc		This function is only used by the FlxGame class to do important internal management stuff
		static internal function setGameData(Game:FlxGame,Width:uint,Height:uint):void
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
			unfollow();
			FlxG.levels = new Array();
			FlxG.scores = new Array();
			level = 0;
			score = 0;
			seed = NaN;
			kong = null;
			pause = false;
		}

		//@desc		This function is only used by the FlxGame class to do important internal management stuff
		static internal function doFollow():void
		{
			if(followTarget != null)
			{
				if(followTarget.exists && !followTarget.dead)
				{
					_scrollTarget.x = (width>>1)-followTarget.x-(followTarget.width>>1);
					_scrollTarget.y = (height>>1)-followTarget.y-(followTarget.height>>1);
					if((followLead != null) && (followTarget is FlxSprite))
					{
						_scrollTarget.x -= (followTarget as FlxSprite).velocity.x*followLead.x;
						_scrollTarget.y -= (followTarget as FlxSprite).velocity.y*followLead.y;
					}
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
		
		//@desc		This function is only used by the FlxGame class to do important internal management stuff
		static internal function unfollow():void
		{
			followTarget = null;
			followLead = null;
			followLerp = 1;
			followMin = null;
			followMax = null;
			scroll = new Point();
			_scrollTarget = new Point();
		}
		
		//@desc		This function is only used by the FlxGame class to do important internal management stuff
		static internal function updateInput():void
		{
			keys.update();
			mouse.update(state.mouseX-scroll.x,state.mouseY-scroll.y);
		}
	}
}
