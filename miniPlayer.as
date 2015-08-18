//Produnction Build
package {
	import flash.display.Sprite;
	import flash.display.LoaderInfo;
	import BotanAS.Sys.GMotions;
	import BotanAS.UI.BasicTools.Miscellaneous.CPlayer;
	import Build;
	[SWF (width='352', height='87', frameRate='60')]
	public class miniPlayer extends Sprite {
		protected var GMs:GMotions = new GMotions()
		, build:Build = new Build();
		public function miniPlayer():void {
			var paramObj:Object = LoaderInfo(this.root.loaderInfo).parameters;
			this.graphics.beginFill(0xFFFFFF);
			this.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			this.graphics.endFill();
			var __player:CPlayer = new CPlayer(GMs, paramObj['src'], paramObj['lrc'], paramObj['albumArt']);
			__player.signBuild(build.build, build.mode);
			addChild(__player);
		}
	}
}