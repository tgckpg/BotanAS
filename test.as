package {
	// Basic Document Outline
	import flash.display.Sprite;
	import BotanAS.Sys.ExtAPI;
	import Build;

	import flash.display.LoaderInfo;
	import BotanAS.Sys.GMotions;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Shape;
	


	[SWF (width='1024', height='576', frameRate='60')]
	public class test extends Sprite {

		protected var _extAPI_:ExtAPI = new ExtAPI
		, echo:Function = function (...msg:*):void { trace(msg); }
		// Build Counter
		, build:Build = new Build(echo = _extAPI_.getEcho())		;
/////////////////////////////////////////////Tests begins here

		private var p:Sprite = new Sprite;
		protected var GMs:GMotions = new GMotions(echo)
		
		;
		
		public function test():void {
			var paramObj:Object = LoaderInfo(this.root.loaderInfo).parameters;
			for (var i:String in paramObj) {
				//echo (i, paramObj[i]);
			}
			addChild(p);
		}


/////////////////////////////////////////////Tests ends here
	}
}