package BotanAS.Sys.Engines.MathEngine.Geom {
	import flash.geom.Point;
	import flash.display.Graphics;

	public class Draw {

		// Constants:
		private const c:Calcs = new Calcs();
		// Public Properties:
		// Private Properties:
		private var echo:Function = function (...msg:*):void { }

		// Initialization:
		public function Draw(echo:Function = null):void {
			if(echo as Function) {
				this.echo = echo;
				echo("  {Draw}");
				
			}
		}

		// Public Methods:
		public function drawEquiTriangle(graph:Graphics, x:Number, y:Number, s:Number):void {
			var h:Number = 2*c.getHerons(s, s, s)/s;
			var r:Number = c.getTriInCirR(s, s, s);
			if(isNaN(x) && isNaN(y)){
				x = s/2;
				y = r;
			} else if(isNaN(x)){
				x = 0;
				y = h - r;
			} else if(isNaN(y)){
				x = -s/2;
				y = r;
			}
			graph.moveTo(x, (y += r) - h);
			graph.lineTo(x + (s /= 2), y);
			graph.lineTo(x - s, y);
			graph.lineTo(x, y - h);
		}
		
		public function drawRandomRect(graph:Graphics, __x:Number, __y:Number, w:Number, h:Number, noiseRange:Number):Vector.<Point> {
			var i:Point = getRandXYInRange(noiseRange)
			, j:Number = i.x + __x
			, k:Number = i.y + __y
			, pointsDrawn:Vector.<Point> = new Vector.<Point>(4, true)
			;
			graph.moveTo(j, k);
			pointsDrawn[0] = new Point(j, k);
			
			graph.lineTo((i = getRandXYInRange(noiseRange)).x + __x + w, i.y + __y);
			pointsDrawn[1] = new Point(i.x + __x + w, i.y + __y);
			
			graph.lineTo((i = getRandXYInRange(noiseRange)).x + __x + w, i.y + __y + h);
			pointsDrawn[2] = new Point(i.x + __x + w, i.y + __y + h);
			
			graph.lineTo((i = getRandXYInRange(noiseRange)).x + __x, i.y + __y + h);
			pointsDrawn[3] = new Point(i.x + __x, i.y + __y + h);
			
			graph.lineTo(j, k);
			return pointsDrawn;
		}
		
		public function drawRing(graph:Graphics, __x:Number, __y:Number, innerR:Number, outerR:Number):void {
			graph.drawCircle(__x, __y, innerR);
			graph.drawCircle(__x, __y, outerR);
		}
		
		public function drawMessCircle(graph:Graphics, __x:Number, __y:Number, r:Number, gradient:int = 100):void {
			var j:Point;
			graph.moveTo(__x, __y);
			for (var i:int = 0; i < gradient; i ++) {
				graph.lineTo((j = getRandXYInRange(r)).x + __x, j.y + __y);
			}
			graph.lineTo(__x, __y);
		}
		
		public function getRandXYInRange(range:Number):Point {
			var i:Number = c.getRandom(-range, range)
			, j:Number = c.getRandom(-Math.PI, Math.PI)
			, k:Point = new Point(Math.cos(j), Math.sin(j));
			k.x *= i;
			k.y *= i;
			return k;
		}


		// Protected Methods:
	}

}