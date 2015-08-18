package BotanAS.Sys {
	public class Utilities {

		public function Utilities():void {	}

		public function dumpObj($obj:Object):String {
			var dump:String = "";
			for (var $i:String in $obj) {
				dump += (dump?", ":"") + $i + "::" + (dumpObj($obj[$i]) || $obj[$i]);
			}
			return dump;
		}
		
	}
}