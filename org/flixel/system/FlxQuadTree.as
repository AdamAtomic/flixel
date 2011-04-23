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
		 * Flag for specifying that you want to add an object to the A list.
		 */
		static public const A_LIST:uint = 0;
		/**
		 * Flag for specifying that you want to add an object to the B list.
		 */
		static public const B_LIST:uint = 1;
		
		/**
		 * Controls the granularity of the quad tree.  Default is 6 (decent performance on large and small worlds).
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
		static protected var _om:Boolean;
		static protected var _op:Function;
		static protected var _on:Function;
		
		static protected var _ohx:Number;
		static protected var _ohy:Number;
		static protected var _ohw:Number;
		static protected var _ohh:Number;
		
		static protected var _cox:Number;
		static protected var _coy:Number;
		static protected var _cow:Number;
		static protected var _coh:Number;
		
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
		
		/**
		 * Clean up memory.
		 */
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
			_op = null;
			_on = null;
		}

		/**
		 * Load objects and/or groups into the quad tree, and register notify and processing callbacks.
		 * 
		 * @param ObjectOrGroup1	Any object that is or extends FlxObject or FlxGroup.
		 * @param ObjectOrGroup2	Any object that is or extends FlxObject or FlxGroup.  If null, the first parameter will be checked against itself.
		 * @param NotifyCallback	A function with the form <code>myFunction(Object1:FlxObject,Object2:FlxObject):void</code> that is called whenever two objects are found to overlap in world space, and either no ProcessCallback is specified, or the ProcessCallback returns true. 
		 * @param ProcessCallback	A function with the form <code>myFunction(Object1:FlxObject,Object2:FlxObject):Boolean</code> that is called whenever two objects are found to overlap in world space.  The NotifyCallback is only called if this function returns true.  See FlxObject.separate(). 
		 */
		public function load(ObjectOrGroup1:FlxBasic, ObjectOrGroup2:FlxBasic=null, NotifyCallback:Function=null, ProcessCallback:Function=null):void
		{
			add(ObjectOrGroup1, A_LIST);
			if(ObjectOrGroup2 != null)
			{
				add(ObjectOrGroup2, B_LIST);
				_om = true;
			}
			else
				_om = false;
			_on = NotifyCallback;
			_op = ProcessCallback;
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
							if(_o.exists && _o.allowCollisions)
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
				if(_o.exists && _o.allowCollisions)
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
		public function execute():Boolean
		{
			var c:Boolean = false;
			var itr:FlxList;
			if(_om)
			{
				//An A-B list comparison
				_oa = B_LIST;
				if(_headA.object != null)
				{
					itr = _headA;
					while(itr != null)
					{
						_o = itr.object;
						if(_o.exists && _o.allowCollisions && overlapNode())
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
						if(_o.exists && _o.allowCollisions)
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
						if(_o.exists && _o.allowCollisions && overlapNode(itr.next))
							c = true;
						itr = itr.next;
					}
				}
			}
			
			//Advance through the tree by calling overlap on each child
			if((_nw != null) && _nw.execute())
				c = true;
			if((_ne != null) && _ne.execute())
				c = true;
			if((_se != null) && _se.execute())
				c = true;
			if((_sw != null) && _sw.execute())
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
				if((_o === co) || !co.exists || !co.allowCollisions)
				{
					Iterator = Iterator.next;
					continue;
				}
				
				//calculate bulk hull for _o
				_ohx = (_o.x < _o.last.x)?_o.x:_o.last.x;
				_ohy = (_o.y < _o.last.y)?_o.y:_o.last.y;
				_ohw = _o.x - _o.last.x;
				_ohw = _o.width + ((_ohw>0)?_ohw:-_ohw);
				_ohh = _o.y - _o.last.y;
				_ohh = _o.height + ((_ohh>0)?_ohh:-_ohh);
				
				//calculate bulk hull for co
				_cox = (co.x < co.last.x)?co.x:co.last.x;
				_coy = (co.y < co.last.y)?co.y:co.last.y;
				_cow = co.x - co.last.x;
				_cow = co.width + ((_cow>0)?_cow:-_cow);
				_coh = co.y - co.last.y;
				_coh = co.height + ((_coh>0)?_coh:-_coh);
				
				//check for intersection of the two hulls
				if((_ohx + _ohw > _cox) && (_ohx < _cox + _cow) && (_ohy + _ohh > _coy) && (_ohy < _coy + _coh))
				{
					//Execute callback functions if they exist
					if((_op == null) || _op(_o,co))
						c = true;
					if(c && (_on != null))
						_on(_o,co);
				}
				Iterator = Iterator.next;
			}
			
			return c;
		}
	}
}
