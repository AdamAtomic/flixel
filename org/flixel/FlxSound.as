package org.flixel
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	//@desc		This is the universal flixel sound object, used for streaming, music, and sound effects
	public class FlxSound extends FlxCore
	{
		//@desc		Whether or not this sound should be automatically destroyed when you switch states
		public var survive:Boolean;
		
		protected var _init:Boolean;
		protected var _sound:Sound;
		protected var _channel:SoundChannel;
		protected var _transform:SoundTransform;
		protected var _position:Number;
		protected var _volume:Number;
		protected var _volumeAdjust:Number;
		protected var _looped:Boolean;
		protected var _core:FlxCore;
		protected var _radius:Number;
		protected var _pan:Boolean;
		protected var _fadeOutTimer:Number;
		protected var _fadeOutTotal:Number;
		protected var _pauseOnFadeOut:Boolean;
		protected var _fadeInTimer:Number;
		protected var _fadeInTotal:Number;
		
		//@desc		The FlxSound constructor gets all the variables initialized, but NOT ready to play a sound yet
		public function FlxSound()
		{
			super();
			_transform = new SoundTransform();
			init();
		}
		
		//@desc		An internal function for clearing all the variables used by sounds
		protected function init():void
		{
			_transform.pan = 0;
			_sound = null;
			_position = 0;
			_volume = 1.0;
			_volumeAdjust = 1.0;
			_looped = false;
			_core = null;
			_radius = 0;
			_pan = false;
			_fadeOutTimer = 0;
			_fadeOutTotal = 0;
			_pauseOnFadeOut = false;
			_fadeInTimer = 0;
			_fadeInTotal = 0;
			active = false;
			visible = false;
			dead = true;
		}
		
		//@desc		One of two main setup functions for sounds, this function loads a sound from an embedded MP3
		//@param	EmbeddedSound	An embedded Class object representing an MP3 file
		//@param	Looped			Whether or not this sound should loop endlessly
		//@return	This FlxSound instance (nice for chaining stuff together, if you're into that)
		public function loadEmbedded(EmbeddedSound:Class, Looped:Boolean=false):FlxSound
		{
			stop();
			init();
			_sound = new EmbeddedSound;
			_looped = Looped;
			updateTransform();
			active = true;
			return this;
		}
		
		//@desc		One of two main setup functions for sounds, this function loads a sound from a URL
		//@param	EmbeddedSound	A string representing the URL of the MP3 file you want to play
		//@param	Looped			Whether or not this sound should loop endlessly
		//@return	This FlxSound instance (nice for chaining stuff together, if you're into that)
		public function loadStream(SoundURL:String, Looped:Boolean=false):FlxSound
		{
			stop();
			init();
			_sound = new Sound(new URLRequest(SoundURL));
			_looped = Looped;
			updateTransform();
			active = true;
			return this;
		}
		
		//@desc		Call this function if you want this sound's volume to change based on distance from a particular FlxCore object
		//@param	X		The X position of the sound
		//@param	Y		The Y position of the sound
		//@param	Core	The object you want to track
		//@param	Radius	The maximum distance this sound can travel
		//@return	This FlxSound instance (nice for chaining stuff together, if you're into that)
		public function proximity(X:Number,Y:Number,Core:FlxCore,Radius:Number,Pan:Boolean=true):FlxSound
		{
			x = X;
			y = Y;
			_core = Core;
			_radius = Radius;
			_pan = Pan;
			return this;
		}
		
		//@desc		Call this function to play the sound
		public function play():void
		{
			if(_position < 0)
				return;
			if(_looped)
			{
				if(_position == 0)
				{
					if(_channel == null)
						_channel = _sound.play(0,9999,_transform);
				}
				else
				{
					_channel = _sound.play(_position,0,_transform);
					_channel.addEventListener(Event.SOUND_COMPLETE, looped);
				}
			}
			else
			{
				if(_position == 0)
				{
					if(_channel == null)
					{
						_channel = _sound.play(0,0,_transform);
						_channel.addEventListener(Event.SOUND_COMPLETE, stopped);
					}
				}
				else
					_channel = _sound.play(_position,0,_transform);
			}
			_position = 0;
		}
		
		//@desc		Call this function to pause this sound
		public function pause():void
		{
			if(_channel == null)
			{
				_position = -1;
				return;
			}
			_position = _channel.position;
			_channel.stop();
			if(_looped)
			{
				while(_position >= _sound.length)
					_position -= _sound.length;
			}
			_channel = null;
		}
		
		//@desc		Call this function to stop this sound
		public function stop():void
		{
			_position = 0;
			if(_channel != null)
			{
				_channel.stop();
				stopped();
			}
		}
		
		//@desc		Call this function to make this sound fade out over a certain time interval
		//@param	Seconds		The amount of time the fade out operation should take
		public function fadeOut(Seconds:Number,PauseInstead:Boolean=false):void
		{
			_pauseOnFadeOut = PauseInstead;
			_fadeInTimer = 0;
			_fadeOutTimer = Seconds;
			_fadeOutTotal = _fadeOutTimer;
		}
		
		//@desc		Call this function to make a sound fade in over a certain time interval (calls play() automatically)
		//@param	Seconds		The amount of time the fade in operation should take
		public function fadeIn(Seconds:Number):void
		{
			_fadeOutTimer = 0;
			_fadeInTimer = Seconds;
			_fadeInTotal = _fadeInTimer;
			play();
		}
		
		//@desc		This is the setter for FlxSound.volume
		//@param	Volume		The new volume for this sound (a number between 0 and 1.0)
		public function set volume(Volume:Number):void
		{
			_volume = Volume;
			if(_volume < 0)
				_volume = 0;
			else if(_volume > 1)
				_volume = 1;
			updateTransform();
		}
		
		//@desc		This is the getter for FlxSound.volume
		//@return	The volume of this sound (a number between 0 and 1.0)
		public function get volume():Number
		{
			return _volume;
		}
		
		//@desc		The basic game loop update function - doesn't do much except optional proximity and fade calculations
		override public function update():void
		{
			if(_position != 0)
				return;
				
			super.update();
			
			var radial:Number = 1.0;
			var fade:Number = 1.0;
			
			//Distance-based volume control
			if(_core != null)
			{
				var pc:Point = new Point();
				var pt:Point = new Point();
				_core.getScreenXY(pc);
				getScreenXY(pt);
				var dx:Number = pc.x - pt.x;
				var dy:Number = pc.y - pt.y;
				radial = (_radius - Math.sqrt(dx*dx + dy*dy))/_radius;
				if(radial < 0) radial = 0;
				if(radial > 1) radial = 1;
				
				if(_pan)
				{
					var d:Number = -dx/_radius;
					if(d < -1) d = -1;
					else if(d > 1) d = 1;
					_transform.pan = d;
				}
			}
			
			//Cross-fading volume control
			if(_fadeOutTimer > 0)
			{
				_fadeOutTimer -= FlxG.elapsed;
				if(_fadeOutTimer <= 0)
				{
					if(_pauseOnFadeOut)
						pause();
					else
						stop();
				}
				fade = _fadeOutTimer/_fadeOutTotal;
				if(fade < 0) fade = 0;
			}
			else if(_fadeInTimer > 0)
			{
				_fadeInTimer -= FlxG.elapsed;
				fade = _fadeInTimer/_fadeOutTotal;
				if(fade < 0) fade = 0;
				fade = 1 - fade;
			}
			
			_volumeAdjust = radial*fade;
			updateTransform();
		}
		
		//@desc		The basic class destructor, stops the music and removes any leftover events
		override public function destroy():void
		{
			if(active)
				stop();
		}
		
		//@desc		An internal function used to help organize and change the volume of the sound
		internal function updateTransform():void
		{
			_transform.volume = FlxG.getMuteValue()*FlxG.volume*_volume*_volumeAdjust;
			if(_channel != null)
				_channel.soundTransform = _transform;
		}
		
		//@desc		An internal helper function used to help Flash resume playing a looped sound
		//@param	event		An Event object
		protected function looped(event:Event=null):void
		{
		    if (_channel == null)
		    	return;
	        _channel.removeEventListener(Event.SOUND_COMPLETE,looped);
	        _channel = null;
			play();
		}
		
		//@desc		An internal helper function used to help clean up and re-use finished sounds
		//@param	event		An Event object
		protected function stopped(event:Event=null):void
		{
			if(!_looped)
	        	_channel.removeEventListener(Event.SOUND_COMPLETE,stopped);
	        else
	        	_channel.removeEventListener(Event.SOUND_COMPLETE,looped);
	        _channel = null;
	        active = false;
		}
	}
}
