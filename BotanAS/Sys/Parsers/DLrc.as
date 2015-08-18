package BotanAS.Sys.Parsers {
	//De-Lyrics(DLrc) written by tgckpg

	public class DLrc {

		// Constants:
		// Public Properties:
		// Private Properties:
		private var $arr:Array = [];

		// Initialization:
		public function DLrc($str:String = ""):void {
			if(!$str)return;
			deLrcs($str);
		}

		// Public Methods:
		public function getLrc():Array {
			return $arr;
		}

		//toMS utilities convert \d\d:\d\d\.\d\d to millisecond.
		public function toMs($str:String):int {
			var $n:Array = $str.match(/\d{1,2}/g);
			switch($n.length) {
				case 1:
					//valid second-only format
					return $n[0]*1000;
				break;
				case 2:
					//valid 00:00 format
					return $n[0]*60000 + $n[1]*1000;
				break;
				case 3:
					//valid 00:00.00 format
					return $n[0]*60000 + $n[1]*1000 + $n[2]*10;
				break;
			}
			//No match, not valid time-stamp format.
			return 0;
		}
		
		public function deLrcs($str:String):DLrc {
			if($arr[0])$arr = [];
			var $st:Array = $str.match(/(\[\d{1,2}\:\d{1,2}\.\d{1,2}\])+/g);
			for(var $i:String in $st) {
				var $s:String = $str.slice($str.indexOf($st[$i]), $str.indexOf($st[Number($i) + 1])).replace(/[\r\n]+/,'').split($st[$i])[1];
				if($st[$i].length > 10) {
					var $t:Array = $st[$i].match(/(\[\d{1,2}\:\d{1,2}\.\d{1,2}\])+?/g);
					for(var $j:String in $t)
						$arr[$arr.length] = [toMs($t[$j]), $s];
				} else $arr[$arr.length] = [toMs($st[$i]), $s];
			}
			$arr.sort(function ($a:Array ,$b:Array):Number{return $a[0] - $b[0]});
			return this;
		}
	}

}