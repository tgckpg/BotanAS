package BotanAS.Sys.Engines.MathEngine.Geom {

	public class Calcs {

		// Constants:
		// Public Properties:
		// Private Properties:
		private var echo:Function = function (...msg:*):void { }

		// Initialization:
		public function Calcs(echo:Function = null):void {
			if(echo as Function) {
				this.echo = echo;
				echo("  {Calcs}");
			}
		}
		// Public Methods:
		public function getHerons(a:Number, b:Number, c:Number):Number {
			var s:Number = .5*(a + b + c);
			return Math.sqrt(s*(s - a)*(s - b)*(s - c));
		}

		public function getTriInCirR(a:Number, b:Number, c:Number):Number {
			return 2 * getHerons(a, b, c)/(a + b + c);
		}
		
		public function getRandom(from:Number, to:Number):Number {
			return Math.abs(from - to)*Math.random() + (from < to ? from : to);
		}
		
		// Protected Methods:
	}

}