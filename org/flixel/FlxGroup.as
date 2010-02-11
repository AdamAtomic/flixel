package org.flixel
{
	/**
	 * This is an organizational class that can update and render a bunch of <code>FlxObject</code>s.
	 * NOTE: Although <code>FlxGroup</code> extends <code>FlxObject</code>, it will not automatically
	 * add itself to the global collisions quad tree, it will only add its members.
	 */
	public class FlxGroup extends FlxObject
	{
		/**
		 * Array of all the <code>FlxObject</code>s that exist in this layer.
		 */
		public var members:Array;
		/**
		 * Helpers for moving/updating group members.
		 */
		protected var _last:FlxPoint;
		protected var _first:Boolean;

		/**
		 * Constructor
		 */
		public function FlxGroup()
		{
			super();
			_group = true;
			members = new Array();
			_last = new FlxPoint();
			_first = true;
		}
		
		/**
		 * Adds a new <code>FlxObject</code> subclass (FlxSprite, FlxBlock, etc) to the list of children
		 *
		 * @param	Object			The object you want to add
		 * @param	ShareScroll		Whether or not this FlxCore should sync up with this layer's scrollFactor
		 *
		 * @return	The same <code>FlxCore</code> object that was passed in.
		 */
		public function add(Object:FlxObject,ShareScroll:Boolean=false):FlxObject
		{
			members.push(Object);
			if(ShareScroll)
				Object.scrollFactor = scrollFactor;
			return Object;
		}
		
		/**
		 * Replaces an existing <code>FlxObject</code> with a new one.
		 * 
		 * @param	OldObject	The object you want to replace.
		 * @param	NewObject	The new object you want to use instead.
		 * 
		 * @return	The new object.
		 */
		public function replace(OldObject:FlxObject,NewObject:FlxObject):FlxObject
		{
			var index:int = members.indexOf(OldObject);
			if((index < 0) || (index >= members.length))
				return null;
			members[index] = NewObject;
			return NewObject;
		}
		
		/**
		 * Removes an object from the group.
		 * 
		 * @param	The <code>FlxObject</code> you want to remove.
		 * 
		 * @return	The removed object.
		 */
		public function remove(Object:FlxObject):FlxObject
		{
			var index:int = members.indexOf(Object);
			if((index < 0) || (index >= members.length))
				return null;
			members[index] = null;
			return Object;
		}
		
		/**
		 * Call this function to retrieve the first object with exists == false in the group.
		 * This is handy for recycling in general, e.g. respawning enemies.
		 * 
		 * @return	A <code>FlxObject</code> currently flagged as not existing.
		 */
		public function getFirstAvail():FlxObject
		{
			var ml:uint = members.length;
			for(var i:uint = 0; i < ml; i++)
			{
				if(!(members[i] as FlxObject).exists)
					return members[i] as FlxObject;
			}
			return null;
		}
		
		/**
		 * Finds the first object with exists == false and calls reset on it.
		 * 
		 * @param	X	The new X position of this object.
		 * @param	Y	The new Y position of this object.
		 * 
		 * @return	Whether a suitable <code>FlxObject</code> was found and reset.
		 */
		public function resetFirstAvail(X:Number=0, Y:Number=0):Boolean
		{
			var o:FlxObject = getFirstAvail();
			if(o == null)
				return false;
			o.reset(X,Y);
			return true;
		}
		
		/**
		 * Call this function to retrieve the first object with exists == true in the group.
		 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
		 * 
		 * @return	A <code>FlxObject</code> currently flagged as existing.
		 */
		public function getFirstExtant():FlxObject
		{
			var ml:uint = members.length;
			for(var i:uint = 0; i < ml; i++)
			{
				if((members[i] as FlxObject).exists)
					return members[i] as FlxObject;
			}
			return null;
		}
		
		/**
		 * Call this function to retrieve the first object with dead == false in the group.
		 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
		 * 
		 * @return	A <code>FlxObject</code> currently flagged as not dead.
		 */
		public function getFirstAlive():FlxObject
		{
			var ml:uint = members.length;
			for(var i:uint = 0; i < ml; i++)
			{
				if(!(members[i] as FlxObject).dead)
					return members[i] as FlxObject;
			}
			return null;
		}
		
		/**
		 * Call this function to retrieve the first object with dead == true in the group.
		 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
		 * 
		 * @return	A <code>FlxObject</code> currently flagged as dead.
		 */
		public function getFirstDead():FlxObject
		{
			var ml:uint = members.length;
			for(var i:uint = 0; i < ml; i++)
			{
				if((members[i] as FlxObject).dead)
					return members[i] as FlxObject;
			}
			return null;
		}
		
		/**
		 * Call this function to find out how many members of the group are not dead.
		 * 
		 * @return	The number of <code>FlxObject</code>s flagged as not dead.  Returns -1 if group is empty.
		 */
		public function countLiving():int
		{
			var count:int = -1;
			var ml:uint = members.length;
			for(var i:uint = 0; i < ml; i++)
			{
				if(!(members[i] as FlxObject).dead)
				{
					if(count < 0)
						count = 0;
					count++;
				}
			}
			return count;
		}
		
		/**
		 * Call this function to find out how many members of the group are dead.
		 * 
		 * @return	The number of <code>FlxObject</code>s flagged as dead.  Returns -1 if group is empty.
		 */
		public function countDead():int
		{
			var count:int = -1;
			var ml:uint = members.length;
			for(var i:uint = 0; i < ml; i++)
			{
				if((members[i] as FlxObject).dead)
				{
					if(count < 0)
						count = 0;
					count++;
				}
			}
			return count;
		}
		
		/**
		 * Returns a member at random from the group.
		 * 
		 * @return	A <code>FlxObject</code> from the members list.
		 */
		public function getRandom():FlxObject
		{
			return members[FlxU.floor(FlxU.random()*members.length)] as FlxObject;
		}
		
		/**
		 * Internal function, helps with the moving/updating of group members.
		 */
		protected function saveOldPosition():void
		{
			if(_first)
			{
				_first = false;
				_last.x = 0;
				_last.y = 0;
				return;
			}
			_last.x = x;
			_last.y = y;
		}
		
		/**
		 * Internal function that actually goes through and updates all the group members.
		 * Depends on <code>saveOldPosition()</code> to set up the correct values in <code>_last</code> in order to work properly.
		 */
		protected function updateMembers():void
		{
			var mx:Number;
			var my:Number;
			var moved:Boolean = false;
			if((x != _last.x) || (y != _last.y))
			{
				moved = true;
				mx = x - _last.x;
				my = y - _last.y;
			}
			var c:FlxObject;
			var l:uint = members.length;
			for(var i:uint = 0; i < l; i++)
			{
				c = members[i] as FlxObject;
				if((c != null) && c.exists)
				{
					if(moved)
					{
						c.x += mx;
						c.y += my;
					}
					if(c.active)
						c.update();
				}
			}
		}
		
		/**
		 * Automatically goes through and calls update on everything you added,
		 * override this function to handle custom input and perform collisions.
		 */
		override public function update():void
		{
			saveOldPosition();
			updateMotion();
			updateMembers();
			updateFlickering();
		}
		
		/**
		 * Internal function that actually loops through and renders all the group members.
		 */
		protected function renderMembers():void
		{
			var c:FlxObject;
			var l:uint = members.length;
			for(var i:uint = 0; i < l; i++)
			{
				c = members[i] as FlxObject;
				if((c != null) && c.exists && c.visible) c.render();
			}
		}
		
		/**
		 * Automatically goes through and calls render on everything you added,
		 * override this loop to control render order manually.
		 */
		override public function render():void
		{
			renderMembers();
		}
		
		/**
		 * Internal function that actually loops through and destroys each member.
		 */
		protected function destroyMembers():void
		{
			var l:uint = members.length;
			for(var i:uint = 0; i < l; i++)
				(members[i] as FlxObject).destroy();
			members.length = 0;
		}
		
		/**
		 * Override this function to handle any deleting or "shutdown" type operations you might need,
		 * such as removing traditional Flash children like Sprite objects.
		 */
		override public function destroy():void
		{
			destroyMembers();
			super.destroy();
		}
		
		/**
		 * If the group's position is reset, we want to reset all its members too.
		 * 
		 * @param	X	The new X position of this object.
		 * @param	Y	The new Y position of this object.
		 */
		override public function reset(X:Number,Y:Number):void
		{
			saveOldPosition();
			super.reset(X,Y);
			var mx:Number;
			var my:Number;
			var moved:Boolean = false;
			if((x != _last.x) || (y != _last.y))
			{
				moved = true;
				mx = x - _last.x;
				my = y - _last.y;
			}
			var c:FlxObject;
			var l:uint = members.length;
			for(var i:uint = 0; i < l; i++)
			{
				c = members[i] as FlxObject;
				if((c != null) && c.exists)
				{
					if(moved)
					{
						c.x += mx;
						c.y += my;
					}
				}
			}
		}
	}
}
