package BotanAS.Sys.Engines.EffectEngine {
	import flash.display.Sprite;
	import flash.events.Event;

	public class Sparkle extends Sprite {
		private const easings:Array =
		[0, 1, 1, 2, 6, 7, 8, 9, 10
		, 11, 15, 16, 17
		, 18, 18, 18, 18, 18, 19
		, 20, 21, 22, 23, 24, 25
		, 26, 27, 28, 29, 30];

		public var particleCount:int = 20
		, particleRange:Number = 15
		, spreadRange:Number = 100
		, initRange:Number = 10
		;

		private var _gMs_:*;

		public function Sparkle(g:*):void {
			if(g['$GMC$'] as Boolean)
			this._gMs_ = g;
			else {
				trace('Error:Class "GMotions" is required.');
				return;
			}
		}

		public function bang(__x:Number, __y:Number):void {
			for(var __i:int = 0; __i < particleCount; __i ++) {
				var __p:Sprite = new Sprite();
				__p.graphics.beginFill(0xFFFFFF);
				__p.graphics.drawCircle(int(Math.random()*particleRange), int(Math.random()*particleRange), int(Math.random()*particleRange));
				__p.graphics.endFill();
				__p.x = __p.y = -4000;
				this.addChild(__p);
				
				_gMs_.curveTween(__p
												 , ['x', 'y', 'rotation', 'scaleX', 'scaleY', 'GlowFilter', 'BlurFilter']
												 // ease types
												 , [easings[int(Math.random()*easings.length)]
														, easings[int(Math.random()*easings.length)], 18, 10, 10, 10, 10]
												// Properties
												 , [__x + (2*Math.random() - 1)*spreadRange
														, __y + (2*Math.random() - 1)*spreadRange
														, 1440*(2*Math.random() - 1)
														, 0
														, 0
														, [Math.random()*0xFFFFFF, 1, 10, 10, 1], [3, 3]]
												// Duration
												 , Math.random() + 1/3
												// Delay
												 , 0
												// init values
												 , [__x + (2*Math.random() - 1)*initRange
														, __y + (2*Math.random() - 1)*initRange
														, 0, 1, 1, [Math.random()*0xFFFFFF, 1, 20, 20, 1], [1, 1]]
												 , null
												 , false
												// Delete after tween
												 , true
											 );
				__p = null;
			}
		}
		
		public function plainBang(__x:Number, __y:Number, color:uint = 0xFFFFFF):void {
			for(var __i:int = 0; __i < particleCount; __i ++) {
				var __p:Sprite = new Sprite();
				__p.graphics.beginFill(color);
				__p.graphics.drawCircle(int(Math.random()*particleRange), int(Math.random()*particleRange), int(Math.random()*particleRange));
				__p.graphics.endFill();
				__p.x = __p.y = -4000;
				this.addChild(__p);
				
				_gMs_.curveTween(__p
												 , ['x', 'y', 'rotation', 'scaleX', 'scaleY']
												 // ease types
												 , [easings[int(Math.random()*easings.length)]
														, easings[int(Math.random()*easings.length)], 18, 10, 10]
												// Properties
												 , [__x + (2*Math.random() - 1)*spreadRange
														, __y + (2*Math.random() - 1)*spreadRange
														, 1440*(2*Math.random() - 1)
														, 0
														, 0]
												// Duration
												 , Math.random() + 1/3
												// Delay
												 , 0
												// init values
												 , [__x + (2*Math.random() - 1)*initRange
														, __y + (2*Math.random() - 1)*initRange
														, 0, 1, 1]
												 , null
												 , false
												// Delete after tween
												 , true
											 );
				__p = null;
			}
		}

	}
}
