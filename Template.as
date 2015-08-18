package {
	// Basic Document Outline
	import flash.display.Sprite;

	import BotanAS.Sys.ExtAPI;

	[SWF (width='1024', height='576', frameRate='60')]
	public class Template extends Sprite{

		private var _extAPI_:ExtAPI = new ExtAPI
		, echo:Function = function (...msg:*):void { trace(msg); }
		// Build Counter
		, build:Build = new Build(echo = _extAPI_.getEcho())

		;

		public function Template():void {
			// Codes goes here.
		}

	}
}