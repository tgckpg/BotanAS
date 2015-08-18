//Produnction Build
package {
	import flash.display.Sprite;
	import flash.display.LoaderInfo;
	import BotanAS.Sys.GMotions;
	import BotanAS.UI.BasicTools.Miscellaneous.CPlayer;
	import BotanAS.Sys.ExtAPI;
	import Build;
	
	[SWF (width='352', height='87', frameRate='60')]
	public class dMiniPlayer extends Sprite {
		protected var GMs:GMotions = new GMotions()
		, _extAPI_:ExtAPI = new ExtAPI
		, echo:Function = function (...msg:*):void { trace(msg); }
		// Build mode, production/debug
		, build:Build = new Build(echo = _extAPI_.getEcho(), false);
		public function dMiniPlayer():void {
			var paramObj:Object = LoaderInfo(this.root.loaderInfo).parameters;
			this.graphics.beginFill(0xFFFFFF);
			this.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			this.graphics.endFill();
			/*/
			var sample:String = "http://tgckpg.nets.hk/res/samples/sample";
			var __player:CPlayer = new CPlayer(GMs, sample + "1.mp3", sample + "1.lrc", sample + "1.jpg", 1, echo);
			/*/
			var __player:CPlayer = new CPlayer(GMs, paramObj['src'], paramObj['lrc'], paramObj['albumArt'], 1, echo);
			//*/
			__player.signBuild(build.build, build.mode);
			addChild(__player);
		}
	}
}