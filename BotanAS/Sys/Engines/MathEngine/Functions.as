package BotanAS.Sys.Engines.MathEngine{

	public class Functions {

		// Constants:
		// Public Properties:
		// Private Properties:
		private var $cCache:Array = []
		, $cCount:Array = []
		, $cache:Boolean
		, $cEvery:uint
		, $tcalled:int = 0
		, $ciflt:int;
		// Public Methods:
		public function Functions($c:Boolean = true, $cleanEvery:uint = 50, $cleanIfLessThan:uint = 10):void {
			this.$cache = $c;
			this.$cEvery = $cleanEvery;
			this.$ciflt = $cleanIfLessThan;
		}

		public function factorial($n:uint):Number {
			var $cCount:Number = 1;
			for (var $i:int = $n; 1 < $i; $i --) {
				$cCount *=  $i;
			}
			return $cCount;
		}

		public function binCoef($n:uint, $k:Number = NaN):* {
			countCalled($n);
			if(this.$cache) {
				if(!this.$cCache[$n]) {
					if(isNaN($k))
					return row($n);
					else
					return row($n)[$k];
				}
				if(isNaN($k))
				return this.$cCache[$n];
				else
				return this.$cCache[$n][$k];
			} else {
				if(isNaN($k))
				return row($n);
				else
				return row($n)[$k];
			}
		}

		public function getPasTri($h:int):Array {
			var $t:Array = [];
			for (var $r:int = 0; $r <= $h; $r ++) {
				$t[$t.length] = binCoef($r);
			}
			return $t;
		}

		public function set $cacheBinomial(nv:Boolean):void {
			this.$cache = nv;
		}

		public function clearCaches():void {
			this.$cCache.length = 0;
		}

		// Protected Methods:
		protected function row($n:uint, $k:Number = NaN):Object {
			if(isNaN($k)) {
				var $arr:Vector.<Number> = new Vector.<Number>
				, $row:Vector.<Number> = new Vector.<Number>($n, true)
				, $l:int = $n*.5;
				$arr[0] = 1;
				if($n == 0)
					return $arr;
				for(var $i:int = 0; $i < $l; $i ++) {
					$arr[$i + 1] = row($n - 1, $i) + row($n - 1, $i + 1);
				}
				if($n % 2 == 0) {
					var $arr2:Vector.<Number> = $arr.concat();
					$arr2.length --;
					$row = $arr.concat($arr2.reverse());
				} else {
					$row = $arr.concat($arr.concat().reverse());
				}
				if(this.$cache)
				this.$cCache[$n] = $row;
				return $row;
			}
			if($k > $n) {
				return 0;
			}
			if($k != 0 && $k != $n) {
				if(this.$cache) {
					if(!this.$cCache[$n - 1])
					row($n - 1);
					return this.$cCache[$n - 1][$k - 1] + this.$cCache[$n - 1][$k];
				}
				return row($n - 1, $k - 1) + row($n - 1, $k);
			}
			return 1;
		}

		protected function countCalled($row:uint):void {
			if(this.$cCount[$row] is Number) {
				this.$cCount[$row] ++;
			} else {
				this.$cCount[$row] = 0;
			}
			this.$cEvery < (this.$tcalled ++) && clean();
		}

		protected function clean():void {
			for (var $i:int = 0; $i < this.$cCount.length; $i ++) {
				this.$cCount[$i] as Number < this.$ciflt && delete this.$cCount[$i];
				this.$cCount[$i] is Number && (this.$cCount[$i] = 0);
			}
			this.$tcalled = 0;
		}

	}
}