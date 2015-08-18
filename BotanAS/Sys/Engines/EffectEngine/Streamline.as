package BotanAS.Sys.Engines.EffectEngine {
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	
	import BotanAS.Sys.Engines.MathEngine.Geom.Calcs;

	public class Streamline extends Sprite {
		
		public var distDev:Vector.<Number>
		, lineShape:Vector.<Shape>
		, criticY:Number = 0
		;
	
		private const chaosTimer:int = 60;
		

		private var
		stageW:Number = 1024
		, stageH:Number = 576
		, _gMs_:*
		
		, rShape:Shape = new Shape
		, dotCount:uint = 2
		, xCount:uint = 50
		, chaosStepper:int = 0
		, screenSlice:Number = stageW/(xCount - 1)
		
		, intY:Vector.< Vector.<Number> >
		, d:Vector.<Number>
		, lineDir:Vector.<Number>
		, chaosFactor:Vector.<Number>
		, currentFactor:Vector.<Number>

		// Echo function for debugging
		, echo:Function = function (...msg:*):void { trace(msg); }
		, calc:Calcs = new Calcs
		, colorTiles:Vector.<uint> = new Vector.<uint>
		;

		public function Streamline(g:*, echo:*, lineCount:uint = 2):void {
			if(g['$GMC$'] as Boolean)
			this._gMs_ = g;
			else {
				echo('Error:Class "GMotions" is required.');
				return;
			}
			if(echo as Function) {
				this.echo = echo;
				echo ("  {Streamline}");
			}
			
			dotCount = lineCount;
			
			// Initialize vectors
			chaosFactor = new Vector.<Number>(2, true);
			currentFactor = new Vector.<Number>(2, true);
			lineShape = new Vector.<Shape>(dotCount, true);
			distDev = new Vector.<Number>(dotCount, true);
			intY = new Vector.< Vector.<Number> >(2*dotCount, true);
			d = new Vector.<Number>(2*dotCount, true);

			init();
		}

		private function init():void {
			initIntY();
			initColorTiles();
			initLines();
			updateChaos();
			addChild(rShape);
		}
		
		public function startStream():void {
			_gMs_.regFrameFunction(rShape, drawLines);
		}
		
		public function stopStream():void {
			if(rShape.parent) {
				removeChild(rShape);
			}
		}
		
		private function initLines():void {
			// Place shapes
			var avgS:Number = stageH/(dotCount + 1);
			for (var i:int = 0; i < dotCount; i ++) {
				// Initialize deviation variable
				distDev[i] = 0;
				d[i] = .9;
				d[dotCount + i] = .9;
				//d[i] = calc.getRandom(.8, .95);
				//d[dotCount + i] = calc.getRandom(.8, .95);
				addChild(lineShape[i] = new Shape);
				lineShape[i].y = avgS*(dotCount - i);
				_gMs_.curveTween(lineShape[i], "DropShadowFilter", 0, [7, 90, 0, .75, 10, 10], 0);
			}
		}
		
		private function initColorTiles():void {
			// Dark Oragne
			colorTiles[0] = 0xF87217;
			// Lawn Green
			colorTiles[1] = 0x87F717;
			// Turquoise
			colorTiles[2] = 0x52F3FF;
			// Dark Orchid
			colorTiles[3] = 0x8B31C7;
			// Violet Red
			colorTiles[4] = 0xF6358A;
			// Royal Blue
			colorTiles[5] = 0x306EFF;
		}

		private function flushY():void {
		// This function all elements right once
			for each(var i:Vector.<Number> in intY) {
				for (var j:int = i.length - 1; j > 0; j --) {
					i[j] = i[j - 1];
				}
			}
		}
		
		private function updateChaos():void {
			// y = a sin bx
			// chaosFactor: a[0, 100], b[0, 4PI]
			chaosFactor[0] = 50*Math.random() + 50;
			chaosFactor[1] = Math.random()*Math.PI/90;
		}

		private function drawLines():void {
			flushY();
			
			// currentFactor refers to a, b, c
			currentFactor[0] = currentFactor[0]*0.9 + 0.1*chaosFactor[0];
			currentFactor[1] = currentFactor[1]*0.99 + 0.01*chaosFactor[1];

			// Main sine wave
			criticY = intY[0][0] = currentFactor[0] * Math.sin( Math.PI/90 * (rShape.rotation ++) );
			for(var i:int = 0, j:int; i < 2*dotCount - 1; i ++) {
				intY[i + 1][0] = intY[i + 1][0]*d[i] + (1 - d[i])*intY[i][0];
			}
			// Waves that referenced by main wave
			for (i = 0, j = 0; i < 2*dotCount; i += 2, j ++) {
				var s:Shape = lineShape[j];
				s.graphics.clear();
				s.graphics.beginFill(colorTiles[j], 1);
				// Draw from right to left, top to bottom
				s.graphics.moveTo(stageW, intY[i][0] - distDev[j]);
				for (var k:int = 1; k < xCount; k ++) {
					s.graphics.lineTo(stageW - screenSlice*k, intY[i][k] - distDev[j]);
				}
				// Bottom line
				for (k = k - 1; k > 0; k --) {
					s.graphics.lineTo(screenSlice*(xCount - k - 1), intY[i + 1][k] + distDev[j]);
				}
				s.graphics.lineTo(screenSlice*(xCount - 1), intY[i + 1][0] + distDev[j]);
				s.graphics.lineTo(stageW, intY[i][0] - distDev[j]);
			}

			if((chaosStepper ++) > chaosTimer) {
				updateChaos();
				chaosStepper = 0;
			}
		}
		
		private function initIntY():void {
			for (var i:int = 0; i < intY.length; i ++) {
				intY[i] = new Vector.<Number>(xCount, true);
				for (var j:int = 0; j < xCount; j ++) {
					intY[i][j] = 0;
				}
			}
		}

	}
}
