package org.flixel.system
{
	import org.flixel.FlxBasic;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxRect;

	/**
	 * A fairly generic quad tree structure for rapid overlap checks.
	 * FlxQuadTree is also configured for single or dual list operation.
	 * You can add items either to its A list or its B list.
	 * When you do an overlap check, you can compare the A list to itself,
	 * or the A list against the B list.  Handy for different things!
	 */
	public class FlxQuadTree extends FlxRect
	{
		/**
		 * Helps to eliminate false collisions and/or rendering glitches caused by rounding errors
		 */
		static protected const ROUNDING_ERROR:Number = 0.0000001;
		/**
		 * Flag for specifying that you want to add an object to the A list.
		 */
		static public const A_LIST:uint = 0;
		/**
		 * Flag for specifying that you want to add an object to the B list.
		 */
		static public const B_LIST:uint = 1;
		
		/**
		 * Controls the granularity of the quad tree.  Default is 3 (decent performance on large and small worlds).
		 */
		static public var divisions:uint;
		
		/**
		 * Whether this branch of the tree can be subdivided or not.
		 */
		protected var _canSubdivide:Boolean;
		
		/**
		 * These variables refer to the internal A and B linked lists,
		 * which are used to store objects in the leaves.
		 */
		protected var _headA:FlxList;
		protected var _tailA:FlxList;
		protected var _headB:FlxList;
		protected var _tailB:FlxList;

		/**
		 * These variables refer to the potential child quadrants for this node.
		 */
		static protected var _min:uint;
		protected var _nw:FlxQuadTree;
		protected var _ne:FlxQuadTree;
		protected var _se:FlxQuadTree;
		protected var _sw:FlxQuadTree;		
		protected var _l:Number;
		protected var _r:Number;
		protected var _t:Number;
		protected var _b:Number;
		protected var _hw:Number;
		protected var _hh:Number;
		protected var _mx:Number;
		protected var _my:Number;
		
		/**
		 * These objects are used to reduce recursive parameters internally.
		 */
		static protected var _o:FlxObject;
		static protected var _ol:Number;
		static protected var _ot:Number;
		static protected var _or:Number;
		static protected var _ob:Number;
		static protected var _oa:uint;
		static protected var _oc:Function;
		
		/**
		 * Instantiate a new Quad Tree node.
		 * 
		 * @param	X			The X-coordinate of the point in space.
		 * @param	Y			The Y-coordinate of the point in space.
		 * @param	Width		Desired width of this node.
		 * @param	Height		Desired height of this node.
		 * @param	Parent		The parent branch or node.  Pass null to create a root.
		 */
		public function FlxQuadTree(X:Number, Y:Number, Width:Number, Height:Number, Parent:FlxQuadTree=null)
		{
			super(X,Y,Width,Height);
			_headA = _tailA = new FlxList();
			_headB = _tailB = new FlxList();
			
			//DEBUG: draw a randomly colored rectangle indicating this quadrant (may induce seizures)
			//org.flixel.FlxState.screen.stamp(new org.flixel.FlxSprite().makeGraphic(Width,Height,0xffffffff*Math.random()),X+org.flixel.FlxG.scroll.x,Y+org.flixel.FlxG.scroll.y);
			
			//Copy the parent's children (if there are any)
			if(Parent != null)
			{
				var itr:FlxList;
				var ot:FlxList;
				if(Parent._headA.object != null)
				{
					itr = Parent._headA;
					while(itr != null)
					{
						if(_tailA.object != null)
						{
							ot = _tailA;
							_tailA = new FlxList();
							ot.next = _tailA;
						}
						_tailA.object = itr.object;
						itr = itr.next;
					}
				}
				if(Parent._headB.object != null)
				{
					itr = Parent._headB;
					while(itr != null)
					{
						if(_tailB.object != null)
						{
							ot = _tailB;
							_tailB = new FlxList();
							ot.next = _tailB;
						}
						_tailB.object = itr.object;
						itr = itr.next;
					}
				}
			}
			else
				_min = (width + height)/(2*divisions);
			_canSubdivide = (width > _min) || (height > _min);
			
			//Set up comparison/sort helpers
			_nw = null;
			_ne = null;
			_se = null;
			_sw = null;
			_l = x;
			_r = x+width;
			_hw = width/2;
			_mx = _l+_hw;
			_t = y;
			_b = y+height;
			_hh = height/2;
			_my = _t+_hh;
		}
		
		public function destroy():void
		{
			_headA.destroy();
			_headA = null;
			_tailA.destroy();
			_tailA = null;
			_headB.destroy();
			_headB = null;
			_tailB.destroy();
			_tailB = null;

			if(_nw != null)
				_nw.destroy();
			_nw = null;
			if(_ne != null)
				_ne.destroy();
			_ne = null;
			if(_se != null)
				_se.destroy();
			_se = null;
			if(_sw != null)
				_sw.destroy();
			_sw = null;

			_o = null;
			_oc = null;
		}
		
		/**
		 * Call this function to add an object to the root of the tree.
		 * This function will recursively add all group members, but
		 * not the groups themselves.
		 * 
		 * @param	ObjectOrGroup	FlxObjects are just added, FlxGroups are recursed and their applicable members added accordingly.
		 * @param	List			A <code>uint</code> flag indicating the list to which you want to add the objects.  Options are <code>A_LIST</code> and <code>B_LIST</code>.
		 */
		public function add(ObjectOrGroup:FlxBasic, List:uint):void
		{
			_oa = List;
			if(ObjectOrGroup is FlxGroup)
			{
				var i:uint = 0;
				var m:FlxBasic;
				var members:Array = (ObjectOrGroup as FlxGroup).members;
				var l:uint = members.length;
				while(i < l)
				{
					m = members[i++] as FlxBasic;
					if((m != null) && m.exists)
					{
						if(m is FlxGroup)
							add(m,List);
						else if(m is FlxObject)
						{
							_o = m as FlxObject;
							if(_o.exists && _o.solid)
							{
								_ol = _o.x;
								_ot = _o.y;
								_or = _o.x + _o.width;
								_ob = _o.y + _o.height;
								addObject();
							}
						}
					}
				}
			}
			else
			{
				_o = ObjectOrGroup as FlxObject;
				if(_o.exists && _o.solid)
				{
					_ol = _o.x;
					_ot = _o.y;
					_or = _o.x + _o.width;
					_ob = _o.y + _o.height;
					addObject();
				}
			}
		}
		
		/**
		 * Internal function for recursively navigating and creating the tree
		 * while adding objects to the appropriate nodes.
		 */
		protected function addObject():void
		{
			//If this quad (not its children) lies entirely inside this object, add it here
			if(!_canSubdivide || ((_l >= _ol) && (_r <= _or) && (_t >= _ot) && (_b <= _ob)))
			{
				addToList();
				return;
			}
			
			//See if the selected object fits completely inside any of the quadrants
			if((_ol > _l) && (_or < _mx))
			{
				if((_ot > _t) && (_ob < _my))
				{
					if(_nw == null)
						_nw = new FlxQuadTree(_l,_t,_hw,_hh,this);
					_nw.addObject();
					return;
				}
				if((_ot > _my) && (_ob < _b))
				{
					if(_sw == null)
						_sw = new FlxQuadTree(_l,_my,_hw,_hh,this);
					_sw.addObject();
					return;
				}
			}
			if((_ol > _mx) && (_or < _r))
			{
				if((_ot > _t) && (_ob < _my))
				{
					if(_ne == null)
						_ne = new FlxQuadTree(_mx,_t,_hw,_hh,this);
					_ne.addObject();
					return;
				}
				if((_ot > _my) && (_ob < _b))
				{
					if(_se == null)
						_se = new FlxQuadTree(_mx,_my,_hw,_hh,this);
					_se.addObject();
					return;
				}
			}
			
			//If it wasn't completely contained we have to check out the partial overlaps
			if((_or > _l) && (_ol < _mx) && (_ob > _t) && (_ot < _my))
			{
				if(_nw == null)
					_nw = new FlxQuadTree(_l,_t,_hw,_hh,this);
				_nw.addObject();
			}
			if((_or > _mx) && (_ol < _r) && (_ob > _t) && (_ot < _my))
			{
				if(_ne == null)
					_ne = new FlxQuadTree(_mx,_t,_hw,_hh,this);
				_ne.addObject();
			}
			if((_or > _mx) && (_ol < _r) && (_ob > _my) && (_ot < _b))
			{
				if(_se == null)
					_se = new FlxQuadTree(_mx,_my,_hw,_hh,this);
				_se.addObject();
			}
			if((_or > _l) && (_ol < _mx) && (_ob > _my) && (_ot < _b))
			{
				if(_sw == null)
					_sw = new FlxQuadTree(_l,_my,_hw,_hh,this);
				_sw.addObject();
			}
		}
		
		/**
		 * Internal function for recursively adding objects to leaf lists.
		 */
		protected function addToList():void
		{
			var ot:FlxList;
			if(_oa == A_LIST)
			{
				if(_tailA.object != null)
				{
					ot = _tailA;
					_tailA = new FlxList();
					ot.next = _tailA;
				}
				_tailA.object = _o;
			}
			else
			{
				if(_tailB.object != null)
				{
					ot = _tailB;
					_tailB = new FlxList();
					ot.next = _tailB;
				}
				_tailB.object = _o;
			}
			if(!_canSubdivide)
				return;
			if(_nw != null)
				_nw.addToList();
			if(_ne != null)
				_ne.addToList();
			if(_se != null)
				_se.addToList();
			if(_sw != null)
				_sw.addToList();
		}
		
		/**
		 * <code>FlxQuadTree</code>'s other main function.  Call this after adding objects
		 * using <code>FlxQuadTree.add()</code> to compare the objects that you loaded.
		 * 
		 * @param	BothLists	Whether you are doing an A-B list comparison, or comparing A against itself.
		 * @param	Callback	A function with two <code>FlxObject</code> parameters - e.g. <code>myOverlapFunction(Object1:FlxObject,Object2:FlxObject);</code>  If no function is provided, <code>FlxQuadTree</code> will call <code>kill()</code> on both objects.
		 *
		 * @return	Whether or not any overlaps were found.
		 */
		public function overlap(BothLists:Boolean=true,Callback:Function=null):Boolean
		{
			_oc = Callback;
			var c:Boolean = false;
			var itr:FlxList;
			if(BothLists)
			{
				//An A-B list comparison
				_oa = B_LIST;
				if(_headA.object != null)
				{
					itr = _headA;
					while(itr != null)
					{
						_o = itr.object;
						if(_o.exists && _o.solid && overlapNode())
							c = true;
						itr = itr.next;
					}
				}
				_oa = A_LIST;
				if(_headB.object != null)
				{
					itr = _headB;
					while(itr != null)
					{
						_o = itr.object;
						if(_o.exists && _o.solid)
						{
							if((_nw != null) && _nw.overlapNode())
								c = true;
							if((_ne != null) && _ne.overlapNode())
								c = true;
							if((_se != null) && _se.overlapNode())
								c = true;
							if((_sw != null) && _sw.overlapNode())
								c = true;
						}
						itr = itr.next;
					}
				}
			}
			else
			{
				//Just checking the A list against itself
				if(_headA.object != null)
				{
					itr = _headA;
					while(itr != null)
					{
						_o = itr.object;
						if(_o.exists && _o.solid && overlapNode(itr.next))
							c = true;
						itr = itr.next;
					}
				}
			}
			
			//Advance through the tree by calling overlap on each child
			if((_nw != null) && _nw.overlap(BothLists,_oc))
				c = true;
			if((_ne != null) && _ne.overlap(BothLists,_oc))
				c = true;
			if((_se != null) && _se.overlap(BothLists,_oc))
				c = true;
			if((_sw != null) && _sw.overlap(BothLists,_oc))
				c = true;
			
			return c;
		}
		
		/**
		 * An internal function for comparing an object against the contents of a node.
		 * 
		 * @param	Iterator	An optional pointer to a linked list entry (for comparing A against itself).
		 * 
		 * @return	Whether or not any overlaps were found.
		 */
		protected function overlapNode(Iterator:FlxList=null):Boolean
		{
			//Get a valid iterator if we don't have one yet
			if(Iterator == null)
			{
				if(_oa == A_LIST)
					Iterator = _headA;
				else
					Iterator = _headB;
			}
			if(Iterator.object == null)
				return false;

			//Walk the list and check for overlaps
			var c:Boolean = false;
			var co:FlxObject;
			while(Iterator != null)
			{
				co = Iterator.object;
				if( (_o === co) || !co.exists || !co.solid ||
					(_o.x + _o.width  < co.x + ROUNDING_ERROR) ||
					(_o.x + ROUNDING_ERROR > co.x + co.width) ||
					(_o.y + _o.height < co.y + ROUNDING_ERROR) ||
					(_o.y + ROUNDING_ERROR > co.y + co.height) )
				{ }
				else if((_oc == null) || _oc(_o,co))
					c = true;
				Iterator = Iterator.next;
			}
			
			return c;
		}
	}
}
