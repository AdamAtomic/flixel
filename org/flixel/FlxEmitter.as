package org.flixel
{

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
		public var x:Number;
		public var y:Number;
		public var width:Number;
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
		public var bounce:Number;
		public var particleClass:Class;
		/**
		 * Internal helper for deciding how many particles to launch.
		 */
		protected var _quantity:uint;
		/**
		 * The style of particle emission (all at once, or one at a time).
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
		protected var _point:FlxPoint;
		
		/**
		 * Creates a new <code>FlxEmitter</code> object at a specific position.
		 * Does not automatically generate or attach particles!
		 * 
		 * @param	X			The X position of the emitter.
		 * @param	Y			The Y position of the emitter.
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
			
			var tf:uint = 1;
			if(Multiple)
			{ 
				var s:FlxSprite = new FlxSprite();
				s.loadGraphic(Graphics,true);
				tf = s.frames;
				s.destroy();
			}

			var r:uint;
			var p:FlxParticle;
			var i:uint = 0;
			while(i < Quantity)
			{
				if(particleClass == null)
					p = new FlxParticle();
				else
					p = new particleClass();
				if(Multiple)
				{
					r = FlxG.random()*tf;
					if(BakedRotations > 0)
						p.loadRotatedGraphic(Graphics,BakedRotations,r);
					else
					{
						p.loadGraphic(Graphics,true);
						p.frame = r;
					}
				}
				else
				{
					if(BakedRotations > 0)
						p.loadRotatedGraphic(Graphics,BakedRotations);
					else
						p.loadGraphic(Graphics);
				}
				if(Collide > 0)
				{
					p.width *= Collide;
					p.height *= Collide;
					p.centerOffsets();
				}
				else
					p.allowCollisions = FlxObject.NONE;
				p.exists = false;
				add(p);
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
					if((l <= 0) || (l > members.length))
						l = members.length;
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
			var p:FlxParticle = recycle(FlxParticle) as FlxParticle;
			p.lifespan = lifespan;
			p.elasticity = bounce;
			p.reset(x - (p.width>>1) + FlxG.random()*width, y - (p.height>>1) + FlxG.random()*height);
			p.visible = true;

			if(minParticleSpeed.x != maxParticleSpeed.x)
				p.velocity.x = minParticleSpeed.x + FlxG.random()*(maxParticleSpeed.x-minParticleSpeed.x);
			else
				p.velocity.x = minParticleSpeed.x;
			if(minParticleSpeed.y != maxParticleSpeed.y)
				p.velocity.y = minParticleSpeed.y + FlxG.random()*(maxParticleSpeed.y-minParticleSpeed.y);
			else
				p.velocity.y = minParticleSpeed.y;
			p.acceleration.y = gravity;
			
			if(minRotation != maxRotation)
				p.angularVelocity = minRotation + FlxG.random()*(maxRotation-minRotation);
			else
				p.angularVelocity = minRotation;
			if(p.angularVelocity != 0)
				p.angle = FlxG.random()*360-180;
			
			p.drag.x = particleDrag.x;
			p.drag.y = particleDrag.y;
			p.onEmit();
		}
		
		/**
		 * Change the emitter's position to the origin of a <code>FlxObject</code>.
		 * 
		 * @param	Object		The <code>FlxObject</code> that needs to spew particles.
		 */
		public function at(Object:FlxObject):void
		{
			Object.getMidpoint(_point);
			x = _point.x - (width>>1);
			y = _point.y - (height>>1);
		}
		
		/**
		 * Call this function to turn off all the particles and the emitter.
		 */
		override public function kill():void
		{
			on = false;
			super.kill();
		}
	}
}
