package org.flixel.data
{
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.events.Event;

	/**
	 * This class provides basic high scores and achievements via Kongregate's game API.
	 */
	public class FlxKong extends Sprite
	{
		/**
		 * Stores the Kongregate API object.
		 * 
		 * @default null
		 */
		public var API:*;
		
		/**
		 * Constructor.
		 */
		public function FlxKong()
		{
			API = null;
		}
		
		/**
		 * Actually initializes the FlxKong object.  Highly recommend calling this
		 * inside your first game state's <code>update()</code> function to ensure
		 * that all the necessary Flash stage stuff is loaded.
		 */
		public function init():void
		{
			var paramObj:Object = LoaderInfo(root.loaderInfo).parameters;
			var api_url:String = paramObj.api_path || "http://www.kongregate.com/flash/API_AS3_Local.swf";
			
			//Load the API
			var request:URLRequest = new URLRequest(api_url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,APILoaded);
			loader.load(request);
			this.addChild(loader);
		}
		
		/**
		 * Fired when the Kongregate API finishes loading into the API object.
		 */
		protected function APILoaded(event:Event):void
		{
		    API = event.target.content;
		    API.services.connect();
		}
	}
}