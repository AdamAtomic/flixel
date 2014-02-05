package org.flixel
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	/**
	 * The <code>FlxSpriteGraphicLoader</code> class allows graphics and animations
	 * to be loaded into a <code>FlxSprite</code> with their properties defined
	 * in an embedded XML asset.  This enables sprite sheet and animation details to be
	 * kept outside of code and easily updated in a controlled fashion.
	 * An XML descriptor can be embedded into a variable
	 * or constant as follows:
	 * <code><pre>
	 * [Embed(source="resource/example.xml", mimeType="application/octet-stream")]
	 * private static const ExampleDescriptor : Class;</code></pre>
	 * 
	 * An XML descriptor must adhear to the following schema:
	 *<code><pre>
	 *&ltsprite&gt
	 *	&ltanimated&gttrue&lt/animated&gt
	 *	&ltreverse&gttrue&lt/reverse&gt
	 *	&ltunique&gtfalse&lt/unique&gt
	 *	&ltrotations&gt0&lt/rotations&gt
	 *	&ltframe&gt-1&lt/frame&gt
	 *	&ltantiAliasing&gtfalse&lt/antiAliasing&gt
	 *	&ltautoBuffer&gtfalse&lt/autoBuffer&gt
	 *	&ltcell width='30' height='11'/&gt
	 *	&ltanimations&gt
	 *		&ltanimation name='walk'&gt
	 *			&ltframerate&gt30&lt/framerate&gt
	 * 			&ltlooped&gttrue&lt/looped&gt
	 * 			&ltframes from='0' to='18'/&gt
	 * 		&lt/animation&gt
	 *	&lt/animations&gt
	 *&lt/sprite&gt
	 *</pre></code>
	 * 
	 * Note that all tags in the descriptor are optional, but the attributes of included tags are not.
	 * You can add as many <b>animation</b> tags to the <b>animations</b> tag as you wish.  You can also add as many
	 * <b>frames</b> tags to any <b>animation</b> tag as you wish.  Once loaded, animations are idendified by their
	 * <i>name</i> attribute.
	 * Also note that if the <b>rotations</b> tag is not omitted and &gt 0 then <code>FlxSprite.loadRotatedGraphic</code> is called,
	 * otherwise <code>FlxSprite.loadGraphic</code> is called, and unnecessary parameters are ignored.
	 * Any combination of Graphic and Descriptor can be used.
	 * 
	 * @see org.flixel.FlxSprite#loadGraphic()
	 * @see org.flixel.FlxSprite#loadRotatedGraphic()
	 * @see org.flixel.FlxSprite#addAnimation()
	 * 
	 * @author Paul Moore
	 */
	public class FlxSpriteGraphicLoader
	{
		/** cached descriptors that don't need to be re-parsed */
		private static const cache:Dictionary = new Dictionary(true);
		
		/**
		 * Loads a graphic and animations into a sprite.
		 * 
		 * @param FlxSprite the sprite to load the graphic and animations into
		 * @param Graphic the embedded graphic class to load
		 * @param Descriptor the embedded XML that describes the graphic
		 */ 
		public static function load (Sprite:FlxSprite, Graphic:Class, Descriptor:Class):void
		{
			var info:Info = cache[Descriptor] as Info;
			if (info == null)
			{
				var bytes:ByteArray = new Descriptor() as ByteArray;
				var data:String = bytes.readUTFBytes(bytes.length);
				var xml:XML = new XML(data);
				info = parseInfo(xml);
				cache[Descriptor] = info;
			}
			if (info.rotations > 0)
				Sprite.loadRotatedGraphic(Graphic, info.rotations, info.frame, info.antiAliasing, info.antiAliasing);
			else
				Sprite.loadGraphic(Graphic, info.animated, info.reverse, info.width, info.height, info.unique);
			for each (var animation : Animation in info.animations)
				Sprite.addAnimation(animation.name, animation.frames, animation.frameRate, animation.looped);
		}
		
		/**
		 * Parses the XML descriptor.
		 * 
		 * @param descriptor the XML to parse
		 * @return the sprite sheet info
		 */
		private static function parseInfo (descriptor : XML) : Info
		{
			var info : Info = new Info(descriptor.animated, descriptor.reverse, descriptor.cell.@width, descriptor.cell.@height, descriptor.unique, descriptor.rotations, descriptor.frame, descriptor.antiAliasing, descriptor.autoBuffer);
			for each (var animation : XML in descriptor.animations.animation)
			{
				var frames : Array = new Array();
				for each (var frameRange : XML in animation.frames)
				{
					var from : uint = animation.frames.@from;
					var to : uint = animation.frames.@to;
					while (from <= to)
					{
						frames.push(from);
						from++;
					}
				}
				info.animations.push(new Animation(animation.@name, frames, animation.framerate, animation.looped));
			}
			return info;
		}
	}
}

/**
 * A struct containing parameter information to be passed to the loadGraphic, loadRotatedGraphic, and addAnimation methods.
 */
class Info
{
	public var animated : Boolean;
	public var reverse : Boolean;
	public var width : uint;
	public var height : uint;
	public var unique : Boolean;
	public var rotations : uint;
	public var frame : int;
	public var antiAliasing : Boolean;
	public var autoBuffer : Boolean;
	public var animations : Array;
	
	public function Info (animated:Boolean = false, reverse:Boolean = false, width:uint = 0, height:uint = 0, unique:Boolean = false, rotations:uint = 16, frame:int = -1, antiAliasing:Boolean = false, autoBuffer:Boolean = false, animations:Array = null)
	{
		this.animated = animated;
		this.reverse = reverse;
		this.width = width;
		this.height = height;
		this.unique = unique;
		this.rotations = rotations, this.frame = frame;
		this.antiAliasing = antiAliasing;
		this.autoBuffer = autoBuffer;
		
		if (animations == null)
		{
			this.animations = new Array();
		}
	}
}

/**
 * A struct containing the information required to build an animation.
 */
class Animation
{
	public var name : String;
	public var frameRate : uint;
	public var looped : Boolean;
	public var frames : Array;
	
	public function Animation (name : String, frames : Array, frameRate : uint, looped : Boolean)
	{
		this.name = name;
		this.frames = frames;
		this.frameRate = frameRate;
		this.looped = looped;
	}
}
