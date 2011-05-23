package org.flixel
{

	/**
	 * <code>FlxEmitter</code> is a lightweight particle emitter.
	 * It can be used for one-time explosions or for
	 * continuous fx like rain and fire.  <code>FlxEmitter</code>
	 * is not optimized or anything; all it does is launch
	 * <code>FlxParticle</code> objects out at set intervals
	 * by setting their positions and velocities accordingly.
	 * It is easy to use and relatively efficient,
	 * relying on <code>FlxGroup</code>'s RECYCLE POWERS.
	 * 
	 * @author	Adam Atomic
	 */
	public class FlxEmitter extends FlxGroup
	{
		/**
		 * The X position of the top left corner of the emitter in world space.
		 */
		public var x:Number;
		/**
		 * The Y position of the top left corner of emitter in world space.
		 */
		public var y:Number;
		/**
		 * The width of the emitter.  Particles can be randomly generated from anywhere within this box.
		 */
		public var width:Number;
		/**
		 * The height of the emitter.  Particles can be randomly generated from anywhere within this box.
		 */
		public var height:Number;
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
		 * It is totally safe to directly toggle this.
		 */
		public var on:Boolean;
		/**
		 * How often a particle is emitted (if emitter is started with Explode == false).
		 */
		public var frequency:Number;
		/**
		 * How long each particle lives once it is emitted.
		 * Set lifespan to 'zero' for particles to live forever.
		 */
		public var lifespan:Number;
		/**
		 * How much each particle should bounce.  1 = full bounce, 0 = no bounce.
		 */
		public var bounce:Number;
		/**
		 * Set your own particle class type here.
		 * Default is <code>FlxParticle</code>.
		 */
		public var particleClass:Class;
		/**
		 * Internal helper for deciding how many particles to launch.
		 */
		protected var _quantity:uint;
		/**
		 * Internal helper for the style of particle emission (all at once, or one at a time).
		 */
		protected var _explode:Boolean;
		/**
		 * Internal helper for deciding when to launch particles or kill them.
		 */
		protected var _timer:Number;
		/**
		 * Internal counter for figuring out how many particles to launch.
		 */
		protected var _counter:uint;
		/**
		 * Internal point object, handy for reusing for memory mgmt purposes.
		 */
		protected var _point:FlxPoint;
		
		/**
		 * Creates a new <code>FlxEmitter</code> object at a specific position.
		 * Does NOT automatically generate or attach particles!
		 * 
		 * @param	X		The X position of the emitter.
		 * @param	Y		The Y position of the emitter.
		 * @param	Size	Optional, specifies a maximum capacity for this emitter.
		 */
		public function FlxEmitter(X:Number=0, Y:Number=0, Size:Number=0)
		{
			super(Size);
			x = X;
			y = Y;
			width = 0;
			height = 0;
			minParticleSpeed = new FlxPoint(-100,-100);
			maxParticleSpeed = new FlxPoint(100,100);
			minRotation = -360;
			maxRotation = 360;
			gravity = 0;
			particleClass = null;
			particleDrag = new FlxPoint();
			frequency = 0.1;
			lifespan = 3;
			bounce = 0;
			_quantity = 0;
			_counter = 0;
			_explode = true;
			on = false;
			_point = new FlxPoint();
		}
		
		/**
		 * Clean up memory.
		 */
		override public function destroy():void
		{
			minParticleSpeed = null;
			maxParticleSpeed = null;
			particleDrag = null;
			particleClass = null;
			_point = null;
			super.destroy();
		}
		
		/**
		 * This function generates a new array of particle sprites to attach to the emitter.
		 * 
		 * @param	Graphics		If you opted to not pre-configure an array of FlxSprite objects, you can simply pass in a particle image or sprite sheet.
		 * @param	Quantity		The number of particles to generate when using the "create from image" option.
		 * @param	BakedRotations	How many frames of baked rotation to use (boosts performance).  Set to zero to not use baked rotations.
		 * @param	Multiple		Whether the image in the Graphics param is a single particle or a bunch of particles (if it's a bunch, they need to be square!).
		 * @param	Collide			Whether the particles should be flagged as not 'dead' (non-colliding particles are higher performance).  0 means no collisions, 0-1 controls scale of particle's bounding box.
		 * 
		 * @return	This FlxEmitter instance (nice for chaining stuff together, if you're into that).
		 */
		public function makeParticles(Graphics:Class, Quantity:uint=50, BakedRotations:uint=16, Multiple:Boolean=false, Collide:Number=0.8):FlxEmitter
		{
			maxSize = Quantity;
			
			var totalFrames:uint = 1;
			if(Multiple)
			{ 
				var sprite:FlxSprite = new FlxSprite();
				sprite.loadGraphic(Graphics,true);
				totalFrames = sprite.frames;
				sprite.destroy();
			}

			var randomFrame:uint;
			var particle:FlxParticle;
			var i:uint = 0;
			while(i < Quantity)
			{
				if(particleClass == null)
					particle = new FlxParticle();
				else
					particle = new particleClass();
				if(Multiple)
				{
					randomFrame = FlxG.random()*totalFrames;
					if(BakedRotations > 0)
						particle.loadRotatedGraphic(Graphics,BakedRotations,randomFrame);
					else
					{
						particle.loadGraphic(Graphics,true);
						particle.frame = randomFrame;
					}
				}
				else
				{
					if(BakedRotations > 0)
						particle.loadRotatedGraphic(Graphics,BakedRotations);
					else
						particle.loadGraphic(Graphics);
				}
				if(Collide > 0)
				{
					particle.width *= Collide;
					particle.height *= Collide;
					particle.centerOffsets();
				}
				else
					particle.allowCollisions = FlxObject.NONE;
				particle.exists = false;
				add(particle);
				i++;
			}
			return this;
		}
		
		/**
		 * Called automatically by the game loop, decides when to launch particles and when to "die".
		 */
		override public function update():void
		{
			if(on)
			{
				if(_explode)
				{
					on = false;
					var i:uint = 0;
					var l:uint = _quantity;
					if((l <= 0) || (l > length))
						l = length;
					while(i < l)
					{
						emitParticle();
						i++;
					}
					_quantity = 0;
				}
				else
				{
					_timer += FlxG.elapsed;
					while((frequency > 0) && (_timer > frequency) && on)
					{
						_timer -= frequency;
						emitParticle();
						if((_quantity > 0) && (++_counter >= _quantity))
						{
							on = false;
							_quantity = 0;
						}
					}
				}
			}
			super.update();
		}
		
		/**
		 * Call this function to turn off all the particles and the emitter.
		 */
		override public function kill():void
		{
			on = false;
			super.kill();
		}
		
		/**
		 * Call this function to start emitting particles.
		 * 
		 * @param	Explode		Whether the particles should all burst out at once.
		 * @param	Lifespan	How long each particle lives once emitted. 0 = forever.
		 * @param	Frequency	Ignored if Explode is set to true. Frequency is how often to emit a particle. 0 = never emit, 0.1 = 1 particle every 0.1 seconds, 5 = 1 particle every 5 seconds.
		 * @param	Quantity	How many particles to launch. 0 = "all of the particles".
		 */
		public function start(Explode:Boolean=true,Lifespan:Number=0,Frequency:Number=0.1,Quantity:uint=0):void
		{
			revive();
			visible = true;
			on = true;
			
			_explode = Explode;
			lifespan = Lifespan;
			frequency = Frequency;
			_quantity += Quantity;
			
			_counter = 0;
			_timer = 0;
		}
		
		/**
		 * This function can be used both internally and externally to emit the next particle.
		 */
		public function emitParticle():void
		{
			var particle:FlxParticle = recycle(FlxParticle) as FlxParticle;
			particle.lifespan = lifespan;
			particle.elasticity = bounce;
			particle.reset(x - (particle.width>>1) + FlxG.random()*width, y - (particle.height>>1) + FlxG.random()*height);
			particle.visible = true;
			
			if(minParticleSpeed.x != maxParticleSpeed.x)
				particle.velocity.x = minParticleSpeed.x + FlxG.random()*(maxParticleSpeed.x-minParticleSpeed.x);
			else
				particle.velocity.x = minParticleSpeed.x;
			if(minParticleSpeed.y != maxParticleSpeed.y)
				particle.velocity.y = minParticleSpeed.y + FlxG.random()*(maxParticleSpeed.y-minParticleSpeed.y);
			else
				particle.velocity.y = minParticleSpeed.y;
			particle.acceleration.y = gravity;
			
			if(minRotation != maxRotation)
				particle.angularVelocity = minRotation + FlxG.random()*(maxRotation-minRotation);
			else
				particle.angularVelocity = minRotation;
			if(particle.angularVelocity != 0)
				particle.angle = FlxG.random()*360-180;
			
			particle.drag.x = particleDrag.x;
			particle.drag.y = particleDrag.y;
			particle.onEmit();
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
		 * Change the emitter's midpoint to match the midpoint of a <code>FlxObject</code>.
		 * 
		 * @param	Object		The <code>FlxObject</code> that you want to sync up with.
		 */
		public function at(Object:FlxObject):void
		{
			Object.getMidpoint(_point);
			x = _point.x - (width>>1);
			y = _point.y - (height>>1);
		}
	}
}
