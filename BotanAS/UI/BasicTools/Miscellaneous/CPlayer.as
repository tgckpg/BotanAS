package BotanAS.UI.BasicTools.Miscellaneous {
	import BotanAS.Sys.Parsers.DLrc;
	import BotanAS.Sys.Engines.MathEngine.Geom.Draw;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	public class CPlayer extends Sprite{
	
		System.useCodePage = true;
		// Constants:
		private const
		  themeColor:Array = [0xFFFFFF, 0x00CCFF, 0xFF0000]
		, barCount:Number = 8
		, barMtp:Number = 32
		, seekWidth:Number = 250
		, seekHeight:Number = 6
		, barHeight:Number = 15
		, albumRect:Number = 75
		, gap:Number = 5;
		// Public Properties:
		// Private Properties:
		private var GMotions:*
		, echo:Function = function(...msg:*):void { }
		, _dRa_:Draw = new Draw()
		, statusText:TextField
		, seekText:TextField
		, loader:URLLoader
		, req:URLRequest
		, lrc_vessel:Sprite
		, lrc_field:Sprite
		, snd_spctrm:Sprite
		, album_art:Sprite
		, mainUI:Sprite
		, stop_btn:Sprite
		, seekbar:Sprite
		, seekpin:Sprite
		, volbar:Sprite
		, volpin:Sprite
		, albumsens:Sprite
		, seeksens:Sprite
		, volsens:Sprite
		, lrc_mask:Shape
		, play_btn:Shape
		, pause_btn:Shape
		, stop_btn_f:Shape
		, seekpinA:Shape
		, seekpinB:Shape
		, seekfill:Shape
		, bufffill:Shape
		, volfill:Shape
		, snd:Sound
		, trans:SoundTransform
		, album_pic:Image
		, tmr:Timer
		, byteArr:ByteArray
		, channel:SoundChannel
		, t_stmp:Vector.<Number>
		, lng:String
		, aurl:String
		, surl:String
		, lurl:String
		, loadTime:Number
		, eV:Number
		, eL:int
		, adj:int
		, lrcLng:int
		, pIndex:int = 0
		, atRest:Boolean = true
		, scrolling:Boolean = false
		;

		// Initialization:
		public function	CPlayer(g:*, soundLink:String, lrcLink:String = null, abALink:String = null, shift:int = 1, echo:Function = null):void {
			if(g['$GMC$'] as Boolean)
			this.GMotions = g;
			else {
				echo('Error:Class "GMotions" is required.');
				return;
			}
			if(echo is Function) {
				this.echo = echo;
			}
			this.surl = soundLink;
			this.lurl = lrcLink;
			this.aurl = abALink;
			this.adj = shift*1000;
			drawUI();
		}

		// Public Methods:
		public function signBuild(number:int, mode:String):void {
			var __build:TextField = new TextField();
			__build.text = "MiniPlayer " + mode + " build " + String(number);
			__build.selectable = false;
			__build.autoSize = TextFieldAutoSize.LEFT;
			__build.setTextFormat(new TextFormat("_sans", 12, 0xDDDDDD));
			__build.x = this.width - __build.width - 3;
			__build.y = 3;
			addChild(__build);
		}
		// Protected Methods:
		protected function drawUI():void {
			statusText = new TextField();
			seekText = new TextField();
			loader = new URLLoader();
			req = new URLRequest();
			lrc_vessel = new Sprite();
			lrc_field = new Sprite();
			snd_spctrm = new Sprite();
			album_art = new Sprite();
			mainUI = new Sprite();
			stop_btn = new Sprite();
			seekbar = new Sprite();
			seekpin = new Sprite();
			volbar = new Sprite();
			volpin = new Sprite();
			albumsens = new Sprite();
			seeksens = new Sprite();
			volsens = new Sprite();
			lrc_mask = new Shape();
			play_btn = new Shape();
			pause_btn = new Shape();
			stop_btn_f = new Shape();
			seekpinA = new Shape();
			seekpinB = new Shape();
			seekfill = new Shape();
			bufffill = new Shape();
			volfill = new Shape();
			snd = new Sound();
			trans = new SoundTransform();
			tmr = new Timer(1000, 1);

		
			var half:Number = .5*albumRect;
			album_art.graphics.lineStyle(2, themeColor[0], 1, false, "normal", "square", "miter");
			album_art.graphics.beginFill(addColor(themeColor[2], 0xDDDDDD));
			album_art.graphics.drawRect(0, 0, albumRect, albumRect);
			albumsens.graphics.beginFill(0, 0);
			albumsens.graphics.drawRect(0, 0, albumRect, albumRect);
			albumsens.graphics.endFill();
			play_btn.graphics.lineStyle(2, themeColor[0], 1, false, "normal", "square", "miter");
			play_btn.graphics.beginFill(themeColor[2], .5);
			_dRa_.drawEquiTriangle(play_btn.graphics, 0, 0, half);
			play_btn.graphics.endFill();
			pause_btn.graphics.lineStyle(2, themeColor[0], 1, false, "normal", "square", "miter");
			pause_btn.graphics.beginFill(themeColor[2], .5);
			pause_btn.graphics.drawRect(-7/18*half, -.5*half, half/3, half);
			pause_btn.graphics.drawRect(half/9, -.5*half, half/3, half);
			pause_btn.graphics.endFill();
			seekbar.graphics.lineStyle(2, themeColor[0], 1, false, "normal", "square", "miter");
			seekbar.graphics.beginFill(0xDDDDDD);
			seekbar.graphics.drawRect(0, 0, seekWidth, seekHeight);
			seekbar.graphics.endFill();
			seekfill.graphics.beginFill(themeColor[2]);
			seekfill.graphics.drawRect(0, 0, seekWidth, seekHeight);
			seekfill.graphics.endFill();
			bufffill.graphics.beginFill(addColor(themeColor[2], 0x666666));
			bufffill.graphics.drawRect(1, 1, seekWidth - 2, seekHeight - 2);
			bufffill.graphics.endFill();
			seekpinA.graphics.lineStyle(2, themeColor[0], 1, false, "normal", "square", "miter");
			seekpinA.graphics.beginFill(themeColor[2]);
			_dRa_.drawEquiTriangle(seekpinA.graphics, NaN, 0, 8);
			seekpinA.graphics.lineTo(0, -seekHeight);
			seekpinA.graphics.endFill();
			seekpinB.graphics.lineStyle(2, themeColor[2], 1, false, "normal", "square", "miter");
			seekpinB.graphics.beginFill(themeColor[0]);
			_dRa_.drawEquiTriangle(seekpinB.graphics, NaN, 0, 8);
			seekpinB.graphics.lineTo(0, -seekHeight);
			seekpinB.graphics.endFill();
			seeksens.graphics.beginFill(0, 0);
			seeksens.graphics.drawRect(0, -gap, seekWidth, seekHeight + 2*gap);
			seeksens.graphics.endFill();
			volfill.graphics.lineStyle(2, themeColor[0], 1, false, "normal", "square", "miter");
			volfill.graphics.beginFill(themeColor[2]);
			volfill.graphics.drawRect(0, 0, gap, -albumRect);
			volfill.graphics.endFill();
			volsens.graphics.beginFill(0, 0);
			volsens.graphics.drawRect(0, 0, gap*2, albumRect);
			volsens.graphics.endFill();

			for (var i:int = 0; i < barCount; i ++) {
				var g:Shape = new Shape();
				g.name = 'l' + String(i);
				g.graphics.beginFill(themeColor[2]);
				g.graphics.drawRect(0, 0, -5, -barHeight);
				g.scaleY = 0;
				g.x = - i * 6;
				snd_spctrm.addChild(g);
				g = new Shape();
				g.name = 'r' + String(i);
				g.graphics.beginFill(themeColor[1]);
				g.graphics.drawRect(0, 0, 5, -barHeight);
				g.scaleY = 0;
				g.x = i * 6 + 1;
				snd_spctrm.addChild(g);
			}

			play_btn.rotation = 90;
			seekpinA.rotation = seekpinB.rotation = 180;
			album_art.x = volbar.x + volsens.width;
			album_art.y = volbar.y = gap;
			play_btn.x = pause_btn.x = play_btn.y = pause_btn.y = albumRect*.5;
			seekbar.x = lrc_vessel.x = statusText.x = album_art.x + album_art.width + gap;
			volfill.x = volpin.x = .5*(volsens.width - volfill.width);
			volfill.y = volsens.height;
			seekbar.y = album_art.y + album_art.height - seekbar.height - gap;
			play_btn.alpha = pause_btn.alpha = seekfill.scaleX = bufffill.scaleX = 0;
			seekpinA.visible = seekpin.visible = false;
			snd_spctrm.x = seekbar.x + seekbar.width - .5*snd_spctrm.width - gap;
			snd_spctrm.y = seekbar.y - gap;

			this.graphics.beginFill(themeColor[0]);
			this.graphics.drawRect(0, 0, seekbar.x + seekWidth + gap*2, album_art.height + gap*2);
			this.graphics.endFill();

			seekText.text = 'Click play to download';
			statusText.text = 'Click to play.';
			statusText.textColor = seekText.textColor = addColor(themeColor[2], 0x444444);
			statusText.selectable = seekText.selectable = false;
			statusText.autoSize = seekText.autoSize = TextFieldAutoSize.LEFT;

			seekText.x = 3;
			statusText.y = gap;
			lrc_vessel.y = statusText.y + statusText.height;
			lrc_mask.x = lrc_vessel.x;
			lrc_mask.y = lrc_vessel.y - gap;
			seekText.y = - seekText.height - gap;

			albumsens.addEventListener(MouseEvent.MOUSE_OVER, albaHandler);
			albumsens.addEventListener(MouseEvent.MOUSE_OUT, albbHandler);
			albumsens.addEventListener(MouseEvent.CLICK, ppHandler);
			seeksens.addEventListener(MouseEvent.MOUSE_OVER, seekHandler);
			seeksens.addEventListener(MouseEvent.MOUSE_OUT, unseekHandler);
			seeksens.addEventListener(MouseEvent.MOUSE_UP, jumpHandler);
			volsens.addEventListener(MouseEvent.MOUSE_UP, unDragVol);
			volsens.addEventListener(MouseEvent.MOUSE_DOWN, dragVol);
			tmr.addEventListener(TimerEvent.TIMER_COMPLETE, albbHandler);
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);

			if(aurl)
			{
				album_pic = new Image(new URLRequest(aurl), albumRect, albumRect, 'Fill', echo);
				album_pic.addEventListener("ERROR", defaultPic);
				album_pic.addEventListener("READY", displayArt);
			}

			album_art.addChild(play_btn);
			album_art.addChild(pause_btn);
			album_art.addChild(albumsens);
			seekpin.addChild(seekText);
			seekpin.addChild(seekpinA);
			seekpin.addChild(seekpinB);
			seekbar.addChild(bufffill);
			seekbar.addChild(seekfill);
			seekbar.addChild(seekpin);
			seekbar.addChild(seeksens);
			lrc_vessel.addChild(lrc_field);
			volbar.addChild(volfill);
			volbar.addChild(volpin);
			volbar.addChild(volsens);

			mainUI.addChild(volbar);
			mainUI.addChild(snd_spctrm);
			mainUI.addChild(album_art);
			mainUI.addChild(seekbar);
			mainUI.addChild(statusText);
			
			this.addChild(lrc_mask);
			this.addChild(lrc_vessel);
			this.addChild(mainUI);
			
			GMotions.curveTween(mainUI, "DropShadowFilter", 24, [2, 45, 0, .75, 4, 4], 1);
			if(!surl) {
				deactivate();
				statusText.text = "No file specified."
			}

		}

		protected function onStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onStage);
			//do something
		}

		protected function play_sound():void {
			if(!channel) {
				try {
					req.url = surl;
					snd.load(req);
					playHandle();
					req.url = lurl;
					if(lurl)loader.load(req);
				} catch (err:Error) {
					echo(err.message);
				}
				loader.addEventListener(Event.COMPLETE, completeHandler);
				loader.addEventListener(IOErrorEvent.IO_ERROR, lrcErrorHandler);
				snd.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				snd.addEventListener("progress", onDloading);
			} else {
				addListeners();
				playHandle(eV * eL);
			}
		}

		protected function scrollLrc(p:Number):void {
			lrc_field.removeEventListener('MOTION_y_COMPLETE', re_sume);
			var s:DisplayObject, g:Number;
			scrolling = false;

			while((pIndex - 2 > 0) && (p + adj < t_stmp[pIndex - 1]))
				pIndex -= 2;
			while((pIndex + 1 < lrcLng) && (p + adj > t_stmp[pIndex + 1]))
				pIndex ++;
			s = lrc_field.getChildByName('t' + String(pIndex));
			g = (t_stmp[pIndex + 1] - p)/1000;

			GMotions.curveTween(lrc_field, 'y', 10, -s.y, g*.65);
			GMotions.curveTween(s, 'GlowFilter', 10, themeColor[0], g -.5, 0, themeColor[2]);
			GMotions.curveTween(s, 'GlowFilter', 9, [themeColor[2], 0, 0, 0], 1, g - 1);
			lrc_field.addEventListener('MOTION_y_COMPLETE', re_sume);
		}

		protected function re_sume(e:Event):void {
			lrc_field.removeEventListener('MOTION_y_COMPLETE', re_sume);
			scrolling = true;
		}

		protected function onDloading(e:Event):void {
			loadTime = snd.bytesLoaded / snd.bytesTotal;
			(snd.bytesLoaded > snd.bytesTotal) && (loadTime = .99);
			eL = Math.ceil(snd.length / (loadTime));
			bufffill.scaleX = loadTime;
			onSoundReady();
			lng = format(snd.length);
			if(loadTime == 1) {
				if(t_stmp)
					t_stmp[t_stmp.length - 1] = snd.length;
				e.target.removeEventListener(e.type, onDloading);
				addEventListener(Event.ENTER_FRAME, onSoundReady);
			}
		}

		protected function onSoundReady(e:Event = null):void {	
		if(channel) {
				var p:int = channel.position
				, float:Number = 0;
				eV = p / eL;
				if(seekpin.visible) {
					seekText.text = format(seekpin.x/seekWidth*eL);
					seekText.autoSize = TextFieldAutoSize.LEFT;
					if(seekpin.x/seekWidth > eV) {
						seekpinA.visible = false;
						seekpinB.visible = true;
					} else {
						seekpinA.visible = true;
						seekpinB.visible = false;
					}
				}
				//SeekBar, Diplay text
				statusText.text = format(channel.position) + "/" + lng;
				statusText.autoSize = TextFieldAutoSize.LEFT;
				seekfill.scaleX = eV;
				//*Bar chart
				byteArr = new ByteArray();
				try {
					SoundMixer.computeSpectrum(byteArr, true, 0);
					//Left Channel
					for (var i:int = 0; i < 256; i ++) {
						float = byteArr.readFloat();
						(float < 0) && (float *= -1);
						if(i % barMtp == 0) {
							var f:DisplayObject = snd_spctrm.getChildByName('l' + String(i/barMtp));
						}
						(float > f.scaleY) && (f.scaleY = float);
					}
					//Right Channel
					for (i = 0; i < 256; i ++) {
						float = byteArr.readFloat();
						(float < 0) && (float *= -1);
						if(i % barMtp == 0)
							f = snd_spctrm.getChildByName('r' + String(i/barMtp));
						(float > f.scaleY) && (f.scaleY = float);
					}
					for(i = 0; i < barCount; i ++) {
						f = snd_spctrm.getChildByName('l' + String(i));
						f.scaleY *= .85;
						f = snd_spctrm.getChildByName('r' + String(i));
						f.scaleY *= .85;
					}
				} catch (e:Error) {
					
				}
				//*///LRC
				if(scrolling)
				if(pIndex + 1 < lrcLng) {
					var s:DisplayObject = lrc_field.getChildByName('t' + String(pIndex))
					, g:Number = (t_stmp[pIndex + 1] - p)/1000;
					if(p + adj > t_stmp[pIndex]) {
						GMotions.curveTween(lrc_field, 'y', 'curve', -s.y, g, 0, NaN
										, {Pts:[new Point(.1, 1), new Point(1, .6)]});
						//FadeIn
						GMotions.curveTween(s, 'GlowFilter', 10, themeColor[2], g -.5, 0, themeColor[0]);
						//FadeOut
						GMotions.curveTween(s, 'GlowFilter', 9, [themeColor[2], 0, 0, 0], 1, g - 1);
						pIndex ++;
					}
				}
			}//End If
		}

		protected function completeHandler(e:Event):void {
			var dat:Array = new DLrc(e.target.data).getLrc()
			, py:Number = 0;
			t_stmp = new Vector.<Number>(dat.length + 1, true);
			loader.removeEventListener(Event.COMPLETE, completeHandler);
			loader = null;
			req = null;

			for (var i:String in dat) {
				var t:TextField = new TextField();
				t.name = 't' + i;
				t.text = dat[i][1] || "";
				t_stmp[i] = dat[i][0];
				t.textColor = themeColor[0];
				t.selectable = false;
				t.autoSize = TextFieldAutoSize.LEFT;
				t.y = t.height + py;
				py = t.y;
				lrc_field.addChild(t);
			}
			dat = null;
			lrc_mask.graphics.beginFill(0, 0);
			lrc_mask.graphics.drawRect(0, 0, lrc_field.width, 20 + 4*gap);
			lrc_mask.graphics.endFill();
			lrc_field.mask = lrc_mask;
			lrcLng = t_stmp.length;
			scrolling = true;
		}

		protected function soundCompleteHandler(e:Event):void {
			removeListeners();
			ppHandler();
			seekfill.scaleX = 0;
			statusText.text = "00:00/" + lng;
			pIndex = 0;
			eV = 0;
		}

		protected function jumpHandler(e:Event):void {
			if(channel) {
				var s:Number = seekpin.x/seekWidth*eL;
				lrcLng && scrollLrc(s);
				channel.stop();
				if(atRest){
					playHandle(s);
					onSoundReady();
					channel.stop();
				} else {
					playHandle(s);
				}
			}
		}

		protected function ppHandler(e:Event = null):void {
			if(atRest) {
				atRest = false;
				play_sound();
				GMotions.curveTween(pause_btn, 'alpha', 10, 1, .2);
				if(play_btn.alpha)GMotions.curveTween(play_btn, 'alpha', 9, 0, .2);
				addListeners();
			} else {
				atRest = true;
				GMotions.curveTween(play_btn, 'alpha', 10, 1, .2);
				if(pause_btn.alpha)GMotions.curveTween(pause_btn, 'alpha', 9, 0, .2);
				if(channel)channel.stop();
				removeListeners();
			}
			tmr.start();
		}

		protected function albaHandler(e:Event):void {
			if(atRest) {
				play_btn.alpha = 1
				if(pause_btn.alpha)GMotions.curveTween(pause_btn, 'alpha', 10, 0, .5);
			} else {
				pause_btn.alpha = 1
				if(play_btn.alpha)GMotions.curveTween(play_btn, 'alpha', 10, 0, .5);
			}
			tmr.start();
		}

		protected function albbHandler(e:Event):void {
			tmr.reset();
			if(pause_btn.alpha)GMotions.curveTween(pause_btn, 'alpha', 10, 0, .5);
			if(play_btn.alpha)GMotions.curveTween(play_btn, 'alpha', 10, 0, .5);
		}

		protected function seekHandler(e:Event):void {
			seekpin.startDrag(true, new Rectangle(0, 0, seekWidth, 0));
			seekpin.visible = true;
			Mouse.hide();
		}

		protected function unseekHandler(e:Event):void {
			seekpin.stopDrag();
			seekpin.visible = false;
			Mouse.show();
		}

		protected function format(l:Number):String {
			l = Math.floor(l/1000);
			var m:int = 0;
			while(60 < l) {
				l -= 60;
				m ++;
			}
			return addZero(m) + ":" + addZero(l);
		}

		protected function removeListeners():void {
			if(loadTime == 1) removeEventListener(Event.ENTER_FRAME, onSoundReady);
			else removeEventListener(Event.ENTER_FRAME, onDloading);
		}

		protected function addListeners():void {
			if(loadTime == 1) addEventListener(Event.ENTER_FRAME, onSoundReady);
			else addEventListener(Event.ENTER_FRAME, onDloading);
		}

		protected function playHandle(_pos:uint = 0):void {
			if(channel)channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			channel = snd.play(_pos);
			changeVol();
			channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
		}

		protected function addZero(n:Number):String {
			if(n < 10)
				return "0" + String(n);
			return String(n);
		}

		protected function errorHandler(e:IOErrorEvent):void {
			deactivate();
			statusText.text = "File not found.";
		}
		protected function lrcErrorHandler(e:IOErrorEvent):void {
				var t:TextField = new TextField();
				t.text = "Lyric file not found.";
				t.textColor = 0xCCCCCC;
				t.selectable = false;
				t.autoSize = TextFieldAutoSize.LEFT;
				lrc_field.addChild(t);
		}

		protected function changeVol(e:Event = null):void {
			volfill.scaleY = (1 - volpin.y / albumRect);
			trans.volume = volfill.scaleY;
			if(channel)channel.soundTransform = trans;
		}

		protected function dragVol(e:Event):void {
			volpin.startDrag(true, new Rectangle(0, 0, 0, albumRect));
			volsens.addEventListener(MouseEvent.MOUSE_MOVE, changeVol);
			//volsens.addEventListener(MouseEvent.MOUSE_OUT, unDragVol);
		}

		protected function unDragVol(e:Event):void {
			volpin.stopDrag();
			volsens.removeEventListener(MouseEvent.MOUSE_MOVE, changeVol);
			//volsens.removeEventListener(MouseEvent.MOUSE_OUT, unDragVol);
		}
		
		protected function defaultPic(e:Event):void {
			album_pic = new Image(new URLRequest("http://file.astropenguin.net/blog/layout-images/disc_s.png"), albumRect, albumRect);
			displayArt(e);
		}
		
		protected function displayArt(e:Event):void {
			echo("DOWNHERE");
			album_art.addChild(album_pic);
			album_art.setChildIndex(album_pic, 0);
		}
		
		protected function toRGB(val:Number):Array {
			if(val < 16777216)
				return [val >> 16 & 0xFF, val >> 8 & 0xFF, val & 0xFF, 0xFF];
			return [val >> 16 & 0xFF, val >> 8 & 0xFF, val & 0xFF, val >> 24 & 0xFF];
		}
		
		protected function addColor(c1:uint, c2:uint):uint {
			var a:Array = toRGB(c1)
			, b:Array = toRGB(c2);
			a[0] = (a[0] += b[0]) < 255 ? a[0]:255;
			a[1] = (a[1] += b[1]) < 255 ? a[1]:255;
			a[2] = (a[2] += b[2]) < 255 ? a[2]:255;
			return (a[0] << 16) + (a[1] << 8) + a[2];
		}
		
		protected function deactivate():void {
			GMotions.curveTween(album_art, 'color', 9, 0xDDDDDD, .2, 0, addColor(themeColor[2], 0xDDDDDD));
			GMotions.curveTween(volfill, 'color', 9, 0xDDDDDD, .2, 0, themeColor[2]);
			GMotions.curveTween(pause_btn, 'alpha', 9, 0, .2);
			GMotions.curveTween(mainUI, "DropShadowFilter", 24, [0, 0, 0, 0, 0, 0], 1);
			this.removeEventListener(Event.ENTER_FRAME, onDloading);
			albumsens.removeEventListener(MouseEvent.MOUSE_OVER, albaHandler);
			albumsens.removeEventListener(MouseEvent.MOUSE_OUT, albbHandler);
			albumsens.removeEventListener(MouseEvent.CLICK, ppHandler);
			seeksens.removeEventListener(MouseEvent.MOUSE_OVER, seekHandler);
			seeksens.removeEventListener(MouseEvent.MOUSE_OUT, unseekHandler);
			seeksens.removeEventListener(MouseEvent.MOUSE_UP, jumpHandler);
			volsens.removeEventListener(MouseEvent.MOUSE_UP, unDragVol);
			volsens.removeEventListener(MouseEvent.MOUSE_DOWN, dragVol);
			tmr.removeEventListener(TimerEvent.TIMER_COMPLETE, albbHandler);
		}

	}
}