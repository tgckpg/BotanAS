package BotanAS.UI.BasicTools.Miscellaneous {
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.ProgressEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import flash.system.Security;

	//import flash.net.URLLoader;
	public class Image extends Sprite {
		// Constants:
		// Public Properties:
		public var $graph:Sprite = new Sprite();
		// Private Properties:
		private var
		$loader:Loader = new Loader()
		, $output:TextField = new TextField()
		, $limW:Number = 0
		, $limH:Number = 0
		, $method:Number = 0
		
		, urlPattern:RegExp = /^http:\/\/([a-z][a-z0-9\-]+(\.|\-*\.))+[a-z]{2,6}/i
		
		, echo:Function = function(...msg:*):void { }
		;

		// Initialization:
		public function Image($link:URLRequest, $w:Number = NaN, $h:Number = NaN, $m:String = 'Fill', echo:Function = null):void {
			if(isNaN($limW) && isNaN($limH)) {
				return;
			}
			if(echo is Function) {
				this.echo = echo;
			}
			
			
			var found:Object =  urlPattern.exec($link.url);
			Security.loadPolicyFile(found[0] + "/crossdomain.xml");
			
			this.$limW = $w;
			this.$limH = $h;
			if($m == 'center')
				this.$method = 2;
			else if($m == 'Fill')
				this.$method = 1;
				
			else this.$method = 0;
			$loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCmp);
			$loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProg);
			$loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, err);
			$loader.load($link);
			drawUI();
		}

		// Public Methods:
		// Protected Methods:
		protected function drawUI():void {
			this.graphics.beginFill(0xFFFFFF, .5);
			this.graphics.drawRect(0, 0, $limW, $limH);
			this.graphics.endFill();
			out('Loading...');
			addChild($output);
			addChild($graph);
		}
		protected function onCmp($e:Event):void {
			removeChild($output);
			$output = null;
			try
			{
				reSize($loader.content);
			}
			catch(e:Error)
			{
				echo(e.message);
			}
		}

		protected function err($e:IOErrorEvent):void {
			dispatchEvent(new Event(Event.COMPLETE));
			removeChild($output);
			$output = new TextField();
			$output.x = $output.y = 0;
			$output.text = $e.text;
			$output.selectable = false;
			$output.wordWrap = true;
			$output.width = $limW;
			$output.height = $limH;
			dispatchEvent(new Event("ERROR"));
			addChild($output);
		}

		private function out($str:String):void {
			echo($str);
			$output.text = $str;
			$output.autoSize = TextFieldAutoSize.LEFT;
			$output.x = $limW - $output.width;
			$output.y = $limH - $output.height;
		}

		private function onProg($e:ProgressEvent):void {
			out("Loading..." + Math.floor($e.bytesLoaded/1024) + " KB");
		}

		protected function reSize($s:DisplayObject):void {
			try
			{
				var $scaleFact:Number
				, $w:Number = $s.width
				, $h:Number = $s.height
				, $canvas:BitmapData = new BitmapData($limW, $limH, false, 0xFFFFFFFF)
				, $matrix:Matrix = new Matrix()
				, $bmp:Bitmap;
				if($method != 2) {
					if($w > $limW || $h > $limH) {
						if($w - $h > 0) {
							$scaleFact = $method ? $limH/$h : $limW/$w;
						} else {
							$scaleFact = $method ? $limW/$w : $limH/$h;
							$method = $method ? 0:1;
						}
						$method && ($w *= $scaleFact);
						$method || ($h *= $scaleFact);
						$matrix.scale($scaleFact, $scaleFact);
						$matrix.translate($method ? .5*($limW - $w) : 0, $method ? 0:.5*($limH - $h));
					}
				} else {
					$matrix.translate(.5*($limW - $w), .5*($limH - $h));
				}

				$canvas.draw($s, $matrix);
				$bmp = new Bitmap($canvas);
				$loader = null;
				$s = null;
				dispatchEvent(new Event(Event.COMPLETE));
				$graph.addChild($bmp);
				dispatchEvent(new Event("READY"));
				echo("Event dispatched");
			}
			catch(e:Error)
			{
				echo(e.message);
			}
		}

	}
}