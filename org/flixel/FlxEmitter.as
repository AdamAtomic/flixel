package org.flixel
{
	import flash.geom.Point;
	
	//@desc		A simple particle system class
	public class FlxEmitter extends FlxCore
	{
		public var minVelocity:Point;
		public var maxVelocity:Point;
		private var _minRotation:Number;
		private var _maxRotation:Number;
		private var _gravity:Number;
		private var _drag:Number;
		private var _delay:Number;
		private var _timer:Number;
		private var _sprites:FlxArray;
		private var _particle:uint;
		
		//@desc		Constructor
		//@param	X				The X position of the emitter
		//@param	Y				The Y position of the emitter
		//@param	Width			The width of the emitter (particles are emitted from a random position inside this box)
		//@param	Height			The height of the emitter
		//@param	Sprites			A pre-configured FlxArray of FlxSprite objects for the emitter to use (optional)
		//@param	Delay			A negative number defines the lifespan of the particles that are launched all at once.  A positive number tells it how often to fire a new particle.
		//@param	MinVelocityX	The minimum X velocity of the particles
		//@param	MaxVelocityX	The maximum X velocity of the particles (every particle will have a random X velocity between these values)
		//@param	MinVelocityY	The minimum Y velocity of the particles
		//@param	MaxVelocityY	The maximum Y velocity of the particles (every particle will have a random Y velocity between these values)
		//@param	MinRotation		The minimum angular velocity of the particles
		//@param	MaxRotation		The maximum angular velocity of the particles (you guessed it)
		//@param	Gravity			How much gravity should affect the particles
		//@param	Drag			Sets both the X and Y "Drag" or deceleration on the particles
		//@param	Graphics		If you opted to not pre-configure an array of FlxSprite objects, you can simply pass in a particle image or sprite sheet (ignored if you pass in an array)
		//@param	Quantity		The number of particles to generate when using the "create from image" option (ignored if you pass in an array)
		//@param	Multiple		Whether the image in the Graphics param is a single particle or a bunch of particles (if it's a bunch, they need to be square!)
		public function FlxEmitter(X:Number, Y:Number, Width:uint, Height:uint, Sprites:FlxArray=null, Delay:Number=-1, MinVelocityX:Number=-100, MaxVelocityX:Number=100, MinVelocityY:Number=-100, MaxVelocityY:Number=100, MinRotation:Number=-360, MaxRotation:Number=360, Gravity:Number=500, Drag:Number=0, Graphics:Class=null, Quantity:uint=0, Multiple:Boolean=false, Parent:FlxLayer=null)
		{
			super();
			
			visible = false;
			x = X;
			y = Y;
			width = Width;
			height = Height;
			
			minVelocity = new Point(MinVelocityX,MinVelocityY);
			maxVelocity = new Point(MaxVelocityX,MaxVelocityY);
			_minRotation = MinRotation;
			_maxRotation = MaxRotation;
			_gravity = Gravity;
			_drag = Drag;
			_delay = Delay;
			
			var i:uint;
			if(Graphics != null)
			{
				_sprites = new FlxArray();
				for(i = 0; i < Quantity; i++)
				{
					if(Multiple)
						(_sprites.add(new FlxSprite(Graphics,0,0,true)) as FlxSprite).randomFrame();
					else
						_sprites.add(new FlxSprite(Graphics));
				}
				for(i = 0; i < _sprites.length; i++)
				{
					if(Parent == null)
						FlxG.state.add(_sprites[i]);
					else
						Parent.add(_sprites[i]);
				}
			}
			else
				_sprites = Sprites;
			
			kill();
			if(_delay > 0)
				reset();
		}
		
		//@desc		Called automatically by the game loop, decides when to launch particles and when to "die"
		override public function update():void
		{
			_timer += FlxG.elapsed;
			if(_delay < 0)
			{
				if(_timer > -_delay) { kill(); return; }
				if(_sprites[0].exists) return;
				for(var i:uint = 0; i < _sprites.length; i++) emit();
				return;
			}
			while(_timer > _delay) { _timer -= _delay; emit(); }
		}
		
		//@desc		Call this function to reset the emitter (if you used a negative delay, calling this function "Explodes" the emitter again)
		public function reset():void
		{
			active = true;
			_timer = 0;
			_particle = 0;
		}
		
		//@desc		This function can be used both internally and externally to emit the next particle
		public function emit():void
		{
			var s:FlxSprite = _sprites[_particle];
			s.exists = true;
			s.x = x - (s.width>>1);
			if(width != 0) s.x += Math.random()*width;
			s.y = y - (s.height>>1);
			if(height != 0) s.y += Math.random()*height;
			s.velocity.x = minVelocity.x;
			if(minVelocity.x != maxVelocity.x) s.velocity.x += Math.random()*(maxVelocity.x-minVelocity.x);
			s.velocity.y = minVelocity.y;
			if(minVelocity.y != maxVelocity.y) s.velocity.y += Math.random()*(maxVelocity.y-minVelocity.y);
			s.acceleration.y = _gravity;
			s.angularVelocity = _minRotation;
			if(_minRotation != _maxRotation) s.angularVelocity += Math.random()*(_maxRotation-_minRotation);
			if(s.angularVelocity != 0) s.angle = Math.random()*360-180;
			s.drag.x = _drag;
			s.drag.y = _drag;
			_particle++;
			if(_particle >= _sprites.length)
				_particle = 0;
			s.onEmit();
		}
		
		//@desc		Call this function to turn off all the particles and the emitter
		override public function kill():void
		{
			active = false;
			for(var i:uint = 0; i < _sprites.length; i++)
				_sprites[i].exists = false;
		}
	}
}
