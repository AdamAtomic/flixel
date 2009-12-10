package org.flixel.data
{
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.events.Event;

	public class FlxKong extends Sprite
	{
		public var API:*;
		
		public function FlxKong() { }
		
		public function init():void
		{
			var paramObj:Object = LoaderInfo(root.loaderInfo).parameters;
			var api_url:String = paramObj.api_path || "http://www.kongregate.com/flash/API_AS3_Local.swf";
			//FlxG.log("API path: "+api_url); //DEBUG
			
			//Load the API
			var request:URLRequest = new URLRequest(api_url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,APILoaded);
			loader.load(request);
			this.addChild(loader);
		}
		
		private function APILoaded(event:Event):void
		{
		    API = event.target.content;
		    API.services.connect();
		
		    /*DEBUG
		    FlxG.log(API.services);
		    FlxG.log(API.user);
		    FlxG.log(API.scores);
		    FlxG.log(API.stats);
		    //*/
		}
	}
}