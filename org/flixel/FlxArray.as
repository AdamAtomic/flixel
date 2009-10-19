package org.flixel
{
	//@desc		This class wraps the normal Flash array and adds a couple of extra functions...
	dynamic public class FlxArray extends Array
	{
		//@desc		Constructor
		public function FlxArray()
		{
			super();
		}

		//@desc		Picks an entry at random from an array
		//@param	Arr		The array you want to pick the object from
		//@return	Any object
		static public function getRandom(A:Array):Object
		{
			return A[int(Math.random()*length)];
		}
		
		//@desc		Find the first entry in the array that doesn't "exist"
		//@return	Anything based on FlxCore (FlxSprite, FlxText, FlxBlock, etc)
		public function getNonexist():FlxCore
		{
			if(this.length <= 0) return null;
			var i:uint = 0;
			do
			{
				if(!(this[i] as FlxCore).exists)
					return this[i];
			} while (++i < this.length);
			return null;
		}
		
		//@desc		Add an object to this array
		//@param	Obj		The object you want to add to the array
		//@return	Just returns the object you passed in in the first place
		public function add(Obj:Object):Object
		{
			for(var i:uint = 0; i < this.length; i++)
				if(this[i] == null)
					return this[i] = Obj;
			return this[this.push(Obj)-1];
		}
		
		//@desc		Remove any object from this array
		//@param	Core	The object you want to remove from this array
		public function remove(Obj:Object,Splice:Boolean=false):void
		{
			removeAt(indexOf(Obj),Splice);
		}
		
		//@desc		Remove any object from this array
		//@param	Index	The entry in the array that you want to remove
		public function removeAt(Index:uint,Splice:Boolean=false):void
		{
			if(Splice)
				this.splice(Index,1);
			else
				this[Index] = null;
		}
		
		//@desc		Kills the specified FlxCore-based object (FlxSprite, FlxText, etc) in this array
		//@param	Core	The object you want to kill
		public function kill(Core:FlxCore):void
		{
			killAt(indexOf(Core));
		}
		
		//@desc		Kills the specified FlxCore-based object (FlxSprite, FlxText, etc) in this array
		//@param	Index	The entry in the array that you want to kill
		public function killAt(Index:uint):void
		{
			if(this[Index] is FlxCore) this[Index].kill();
		}
		
		//@desc		Pops every entry out of the array
		public function clear():void
		{
			this.length = 0;
		}
	}
}