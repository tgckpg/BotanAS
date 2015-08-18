package BotanAS.UI.BasicTools.Miscellaneous{
	// import BotanAS.Sys.Parsers.XMLs;

	import flash.display.Sprite
	import flash.display.Shape
	import flash.events.Event
	import flash.geom.Point
	import flash.utils.Timer
	import flash.events.TimerEvent
	import flash.events.MouseEvent

	public class DrawText extends Sprite{

		// Constants:
		private const cubeR:Number = 400;

		// Public Properties:
		
		// Resize multiplier
		public var rzMr:Number = 30
		// snapshot
		, snap:Number = 8;

		// Private Properties:
		private var rcDrw:Array = []
		, rcPth:Array = []
		, rcPts:Array
		, line:Shape
		, container:Sprite = new Sprite()
		, gap:Timer = new Timer(0)
		, currPos:uint = 0
		, posAdjst:Number = 0
		, cube:Shape = new Shape()
		, screen:*
		
		// Echo function for debugging
		, echo:Function = function (...msg:*):void { trace(msg); }

		// , _xmls:XMLs = new XMLs()
		, _gMs_:*
		;

		// Initialization:
		public function DrawText(g:*, target:*, echo:Function = null) {
			if(echo as Function) {
				this.echo = echo;
				echo ("  {DrawText}");
			}
			
			if(g['$GMC$'] as Boolean) {
				this._gMs_ = g;
			} else {
				echo('Error:Class "GMotions" is required.');
				return;
			}
			this.screen = target;
			addEventListener(Event.REMOVED_FROM_STAGE, deActivate);
		}

		// Public Methods:
		public function activate():void{
			cube.graphics.lineStyle(1, 0xFF0000);
			cube.graphics.beginFill(0xFFFFFF);
			cube.graphics.drawRect(-cubeR/2,-cubeR/2,cubeR,cubeR);
			cube.x = stage.stageWidth/2;
			cube.y = stage.stageHeight/2;
			cube.alpha=.2;
			addChild(cube);
			addChild(container);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, downEventHandler);
		}

		public function deActivate(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, deActivate);
			cube.graphics.clear();
			removeChild(cube);
			removeChild(container);
			stage.removeEventListener(MouseEvent.MOUSE_UP, upEventHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveEventHandler);
		}

		public function getData():String {
			
			// 1st level: rcDrw[x] block character
			// 2nd level: rcDrw[x][y] character stroke
			// 3rd level: rcDrw[x][y][z] point cloud
			
			var i:int = 0
			, j:int = 0
			, k:int = 0
			, l:int = rcDrw.length
			, m:int = 0
			, n:int = 0
			
			// Captured point offset
			, ox:int = 0.5*(stage.stageWidth - cubeR)
			, oy:int = 0.5*(stage.stageHeight - cubeR)
			
			, s:String = "[";
			;
			
			for(i = 0; i < l; i ++)
			{
				m = rcDrw[i].length;
				s += "\n	" + (0 < i ? ",\n	[" : "[");
				
				for(j = 0; j < m; j ++)
				{
					n = rcDrw[i][j].length;
					
					s += "\n		" + (0 < j ? ", [ " : "[ ");
					
					for(k = 0; k < n; k ++)
					{
						s += (0 < k ? ", [" : "[") + String(rcDrw[i][j][k].x - ox) + ", " + String(rcDrw[i][j][k].y - oy) + "]";
					}
					
					s += " ]";
				}
				s += "\n	]";
			}
			s += "\n]";
			
			return s;
		}
		

		protected function compressSnapShot():void {
			var tempPaths:Array = [];
			for (var i:int = 0; rcPth.length > i; i++) {
				rcPts = [];
				for (var e:int = 0; rcPth[i].length > e; e += snap) {
					rcPts.push(rcPth[i][e]);
				}
				if (e + 1 != rcPth[i].length) {
					rcPts.push(rcPth[i][rcPth[i].length - 1]);
				}
				tempPaths.push(rcPts);
			}
			rcDrw.push(tempPaths);
			tempPaths = rcPts = null;
			rcPth = [];
		}

		protected function playBack():void {
			var drawing:Sprite = new Sprite()
			, rline:Shape
			, currPath:uint = 0
			, currPoint:uint = 1
			, currDrawing:Array = rcDrw[currPos];

			drawing.scaleX = drawing.scaleY = rzMr/cubeR;
			function startscribble(e:Event):void {
				if (currDrawing.length > currPath) {
					if (currDrawing[currPath].length > currPoint) {
						if (currPoint == 1) {
							rline = new Shape();
							rline.graphics.lineStyle(1, 0x000000);
							rline.graphics.moveTo(currDrawing[currPath][0].x, currDrawing[currPath][0].y);
							drawing.addChild(rline);
						}
						rline.graphics.lineTo(currDrawing[currPath][currPoint].x, currDrawing[currPath][currPoint].y);
						currPoint ++;
					} else {
						currPoint = 1;
						currPath ++;
					}
				} else {
					removeEventListener(Event.ENTER_FRAME, startscribble);
				}
			}
			drawing.x = currPos*rzMr;//temp value
			this.screen.addChild(drawing);
			currPos ++;
			addEventListener(Event.ENTER_FRAME, startscribble);
		}

		protected function traceOut(e:Event):void {
			compressSnapShot();
			playBack();
			_gMs_['curveTween'](cube, "alpha", 10, .2, 1);
			removeChild(container);
			container = new Sprite();
			addChild(container);
		}

		protected function moveEventHandler(e:Event):void {
			if (cube.hitTestPoint(mouseX,mouseY)) {
				line.graphics.lineTo(mouseX, mouseY);
				rcPts.push(new Point(mouseX, mouseY));
			}
		}

		protected function upEventHandler(e:Event):void {
			gap=new Timer(1200,1);
			gap.start();
			rcPth.push(rcPts);
			gap.addEventListener(TimerEvent.TIMER_COMPLETE, traceOut);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveEventHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, upEventHandler);
		}

		protected function downEventHandler(e:Event):void {
			if (cube.hitTestPoint(mouseX,mouseY)) {
				gap.reset();
				line = new Shape();
				_gMs_['curveTween'](cube, "alpha", 10, 1, 1);
				rcPts = [];
				line.graphics.lineStyle(1, 0);
				line.graphics.moveTo(mouseX, mouseY);
				rcPts.push(new Point(mouseX, mouseY));
				stage.addEventListener(MouseEvent.MOUSE_UP, upEventHandler);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, moveEventHandler);
				container.addChild(line);
			}
		}

	}
}