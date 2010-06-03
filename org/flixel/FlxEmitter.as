package org.flixel
{
	import org.flixel.data.FlxParticle;

	/**
	 * <code>FlxEmitter</code> is a lightweight particle emitter.
	 * It can be used for one-time explosions or for
	 * continuous fx like rain and fire.  <code>FlxEmitter</code>
	 * is not optimized or anything; all it does is launch
	 * <code>FlxSprite</code> objects out at set intervals
	 * by setting their positions and velocities accordingly.
	 * It is easy to use and relatively efficient, since it
	 * automatically redelays its sprites and/or kills
	 * them once they've been launched.
	 */
	public class FlxEmitter extends FlxGroup
	{
		/**
		 * The minimum possible velocity of a particle.
		 * The default value is (-100,-100).
		 */
		public var minParticleSpeed:FlxPoint;
		/**
		 * The maximum possible velocity of a particle.
		 * The default value is (100,100).
		 */
		public var maxParticleSpeed:FlxPoint;
		/**
		 * The X and Y drag component of particles launched from the emitter.
		 */
		public var particleDrag:FlxPoint;
		/**
		 * The minimum possible angular velocity of a particle.  The default value is -360.
		 * NOTE: rotating particles are more expensive to draw than non-rotating ones!
		 */
		public var minRotation:Number;
		/**
		 * The maximum possible angular velocity of a particle.  The default value is 360.
		 * NOTE: rotating particles are more expensive to draw than non-rotating ones!
		 */
		public var maxRotation:Number;
		/**
		 * Sets the <code>acceleration.y</code> member of each particle to this value on launch.
		 */
		public var gravity:Number;
		/**
		 * Determines whether the emitter is currently emitting particles.
		 */
		public var on:Boolean;
		/**
		 * This variable has different effects depending on what kind of emission it is.
		 * During an explosion, delay controls the lifespan of the particles.
		 * During normal emission, delay controls the time between particle launches.
		 * NOTE: In older builds, polarity (negative numbers) was used to define emitter behavior.
		 * THIS IS NO LONGER THE CASE!  FlxEmitter.start() controls that now!
		 */
		public var delay:Number;
		/**
		 * The number of particles to launch at a time.
		 */
		public var quantity:uint;
		/**
		 * Checks whether you already fired a particle this frame.
		 */
		public var justEmitted:Boolean;
		/**
		 * The style of particle emission (all at once, or one at a time).
		 */
		protected var _explode:Boolean;
		/**
		 * Internal helper for deciding when to launch particles or kill them.
		 */
		protected var _timer:Number;
		/**
		 * Internal marker for where we are in <code>_sprites</code>.
		 */
		protected var _particle:uint;
		/**
		 * Internal counter for figuring out how many particles to launch.
		 */
		protected var _counter:uint;
		
		/**
		 * Creates a new <code>FlxEmitter</code> object at a specific position.
		 * Does not automatically generate or attach particles!
		 * 
		 * @param	X			The X position of the emitter.
		 * @param	Y			The Y position of the emitter.
		 */
		public function FlxEmitter(X:Number=0, Y:Number=0)
		{
			super();
			
			x = X;
			y = Y;
			width = 0;
			height = 0;
			
			minParticleSpeed = new FlxPoint(-100,-100);
			maxParticleSpeed = new FlxPoint(100,100);
			minRotation = -360;
			maxRotation = 360;
			gravity = 400;
			particleDrag = new FlxPoint();
			delay = 0;
			quantity = 0;
			_counter = 0;
			_explode = true;
			exists = false;
			on = false;
			justEmitted = false;
		}
		
		/**
		 * This function generates a new array of sprites to attach to the emitter.
		 * 
		 * @param	Graphics		If you opted to not pre-configure an array of FlxSprite objects, you can simply pass in a particle image or sprite sheet.
		 * @param	Quantity		The number of particles to generate when using the "create from image" option.
		 * @param	BakedRotations	How many frames of baked rotation to use (boosts performance).  Set to zero to not use baked rotations.
		 * @param	Multiple		Whether the image in the Graphics param is a single particle or a bunch of particles (if it's a bunch, they need to be square!).
		 * @param	Collide			Whether the particles should be flagged as not 'dead' (non-colliding particles are higher performance).  0 means no collisions, 0-1 controls scale of particle's bounding box.
		 * @param	Bounce			Whether the particles should bounce after colliding with things.  0 means no bounce, 1 means full reflection.
		 * 
		 * @return	This FlxEmitter instance (nice for chaining stuff together, if you're into that).
		 */
		public function createSprites(Graphics:Class, Quantity:uint=50, BakedRotations:uint=16, Multiple:Boolean=true, Collide:Number=0, Bounce:Number=0):FlxEmitter
		{
			members = new Array();
			var r:uint;
			var s:FlxSprite;
			var tf:uint = 1;
			var sw:Number;
			var sh:Number;
			if(Multiple)
			{
				s = new FlxSprite();
				s.loadGraphic(Graphics,true);
				tf = s.frames;
			}
			var i:uint = 0;
			while(i < Quantity)
			{
				if((Collide > 0) && (Bounce > 0))
					s = new FlxParticle(Bounce) as FlxSprite;
				else
					s = new FlxSprite();
				if(Multiple)
				{
					r = FlxU.random()*tf;
					if(BakedRotations > 0)
						s.loadRotatedGraphic(Graphics,BakedRotations,r);
					else
					{
						s.loadGraphic(Graphics,true);
						s.frame = r;
					}
				}
				else
				{
					if(BakedRotations > 0)
						s.loadRotatedGraphic(Graphics,BakedRotations);
					else
						s.loadGraphic(Graphics);
				}
				if(Collide > 0)
				{
					sw = s.width;
					sh = s.height;
					s.width *= Collide;
					s.height *= Collide;
					s.offset.x = (sw-s.width)/2;
					s.offset.y = (sh-s.height)/2;
					s.solid = true;
				}
				else
					s.solid = false;
				s.exists = false;
				s.scrollFactor = scrollFactor;
				add(s);
				i++;
			}
			return this;
		}
		
		/**
		 * A more compact way of setting the width and height of the emitter.
		 * 
		 * @param	Width	The desired width of the emitter (particles are spawned randomly within these dimensions).
		 * @param	Height	The desired height of the emitter.
		 */
		public function setSize(Width:uint,Height:uint):void
		{
			width = Width;
			height = Height;
		}
		
		/**
		 * A more compact way of setting the X velocity range of the emitter.
		 * 
		 * @param	Min		The minimum value for this range.
		 * @param	Max		The maximum value for this range.
		 */
		public function setXSpeed(Min:Number=0,Max:Number=0):void
		{
			minParticleSpeed.x = Min;
			maxParticleSpeed.x = Max;
		}
		
		/**
		 * A more compact way of setting the Y velocity range of the emitter.
		 * 
		 * @param	Min		The minimum value for this range.
		 * @param	Max		The maximum value for this range.
		 */
		public function setYSpeed(Min:Number=0,Max:Number=0):void
		{
			minParticleSpeed.y = Min;
			maxParticleSpeed.y = Max;
		}
		
		/**
		 * A more compact way of setting the angular velocity constraints of the emitter.
		 * 
		 * @param	Min		The minimum value for this range.
		 * @param	Max		The maximum value for this range.
		 */
		public function setRotation(Min:Number=0,Max:Number=0):void
		{
			minRotation = Min;
			maxRotation = Max;
		}
		
		/**
		 * Internal function that actually performs the emitter update (called by update()).
		 */
		protected function updateEmitter():void
		{
			if(_explode)
			{
				_timer += FlxG.elapsed;
				if((delay > 0) && (_timer > delay))
				{
					kill();
					return;
				}
				if(on)
				{
					on = false;
					var i:uint = _particle;
					var l:uint = members.length;
					if(quantity > 0)
						l = quantity;
					l += _particle;
					while(i < l)
					{
						emitParticle();
						i++;
					}
				}
				return;
			}
			if(!on)
				return;
			_timer += FlxG.elapsed;
			while((_timer > delay) && ((quantity <= 0) || (_counter < quantity)))
			{
				_timer -= delay;
				emitParticle();
			}
		}
		
		/**
		 * Internal function that actually goes through and updates all the group members.
		 * Overridden here to remove the position update code normally used by a FlxGroup.
		 */
		override protected function updateMembers():void
		{
			var o:FlxObject;
			var i:uint = 0;
			var l:uint = members.length;
			while(i < l)
			{
				o = members[i++] as FlxObject;
				if((o != null) && o.exists && o.active)
					o.update();
			}
		}
		
		/**
		 * Called automatically by the game loop, decides when to launch particles and when to "die".
		 */
		override public function update():void
		{
			justEmitted = false;
			super.update();
			updateEmitter();
		}
		
		/**
		 * Call this function to start emitting particles.
		 * 
		 * @param	Explode		Whether the particles should all burst out at once.
		 * @param	Delay		You can set the delay (or lifespan) here if you want.
		 * @param	Quantity	How many particles to launch.  Default value is 0, or "all the particles".
		 */
		public function start(Explode:Boolean=true,Delay:Number=0,Quantity:uint=0):void
		{
			if(members.length <= 0)
			{
				FlxG.log("WARNING: there are no sprites loaded in your emitter.\nAdd some to FlxEmitter.members or use FlxEmitter.createSprites().");
				return;
			}
			_explode = Explode;
			if(!_explode)
				_counter = 0;
			if(!exists)
				_particle = 0;
			exists = true;
			visible = true;
			active = true;
			dead = false;
			on = true;
			_timer = 0;
			if(quantity == 0)
				quantity = Quantity;
			else if(Quantity != 0)
				quantity = Quantity;
			if(Delay != 0)
				delay = Delay;
			if(delay < 0)
				delay = -delay;
			if(delay == 0)
			{
				if(Explode)
					delay = 3;	//default value for particle explosions
				else
					delay = 0.1;//default value for particle streams
			}
		}
		
		/**
		 * This function can be used both internally and externally to emit the next particle.
		 */
		public function emitParticle():void
		{
			_counter++;
			var s:FlxSprite = members[_particle] as FlxSprite;
			s.visible = true;
			s.exists = true;
			s.active = true;
			s.x = x - (s.width>>1) + FlxU.random()*width;
			s.y = y - (s.height>>1) + FlxU.random()*height;
			s.velocity.x = minParticleSpeed.x;
			if(minParticleSpeed.x != maxParticleSpeed.x) s.velocity.x += FlxU.random()*(maxParticleSpeed.x-minParticleSpeed.x);
			s.velocity.y = minParticleSpeed.y;
			if(minParticleSpeed.y != maxParticleSpeed.y) s.velocity.y += FlxU.random()*(maxParticleSpeed.y-minParticleSpeed.y);
			s.acceleration.y = gravity;
			s.angularVelocity = minRotation;
			if(minRotation != maxRotation) s.angularVelocity += FlxU.random()*(maxRotation-minRotation);
			if(s.angularVelocity != 0) s.angle = FlxU.random()*360-180;
			s.drag.x = particleDrag.x;
			s.drag.y = particleDrag.y;
			_particle++;
			if(_particle >= members.length)
				_particle = 0;
			s.onEmit();
			justEmitted = true;
		}
		
		/**
		 * Call this function to stop the emitter without killing it.
		 * 
		 * @param	Delay	How long to wait before killing all the particles.  Set to 'zero' to never kill them.
		 */
		public function stop(Delay:Number=3):void
		{
			_explode = true;
			delay = Delay;
			if(delay < 0)
				delay = -Delay;
			on = false;
		}
		
		/**
		 * Change the emitter's position to the origin of a <code>FlxObject</code>.
		 * 
		 * @param	Object		The <code>FlxObject</code> that needs to spew particles.
		 */
		public function at(Object:FlxObject):void
		{
			x = Object.x + Object.origin.x;
			y = Object.y + Object.origin.y;
		}
		
		/**
		 * Call this function to turn off all the particles and the emitter.
		 */
		override public function kill():void
		{
			super.kill();
			on = false;
		}
	}
}
