//Global Motion System(GMotions, also GMs) written by tgckpg.
package BotanAS.Sys {
	import fl.motion.BezierEase;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.*;
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import flash.utils.getTimer;

	public class GMotions {

		//Constants:
		//Public properties:
		public var fps:uint = 60
		, debug_child:String = ""
		;
		public const $GMC$:Boolean = true;
		//Private properties:
		private namespace debug;
		private namespace production;
		private const eHD:Shape = new Shape();
		private var objectList:Object = {}
		, debug_d:int = 0
		, debug_t:int = 0
		, debug_a:int = 0
		
		, debugStat:Namespace = debug

		, globalTime:int = getTimer()
		
		, echo:Function = function (...msg:*):void { trace(msg); }
		;

		//Initialization:
		public function GMotions(echo:Function = null):void {
			if(echo as Function) {
				this.echo = echo;
				echo("  {GMotions}");
				
			}
			eHD.addEventListener(Event.ENTER_FRAME, playWorld);
			//Delay timer
			objectList.$ = [function ():void {
				for ( var i:int = 1; i < objectList.$.length; i ++ ) {
					if( objectList.$[i] )
					if( this.globalTime > objectList.$[i][1]) {
						objectList.$[i][0]();
						delete objectList.$[i];
					}
				}
				this.globalTime = getTimer();
			}];
			super();
		}

		//Public Methods:
		public function curveTween(target:*, prop:*, easeType:*, newValue:*, duration:*, 
								   delay:* = 0, oldValue:* = NaN, dS:* = null, iT:Boolean = false, dT:Boolean = false):void {
			function insideListener():void {
				var est:* = checkExistance(tnm, prop);
				if(!(est is Boolean)) {
					for(var p:String in prop) {
						if(est[p])
							managePropertiesValues(tnm, prop[p], {oldValue:oldValue as Array ? oldValue[p] : oldValue
								,newValue:newValue as Array  ? newValue[p] : newValue
								,easeType:easeType as Array  ? easeType [p] : easeType
								,fms:duration as Array  ? int(fps*duration[p]) : int(fps*duration)
								,dSets:dS as Array  ? dS[p] : dS});
						else managePropertiesValues(tnm, prop[p], {oldValue:oldValue as Array ? oldValue[p] : oldValue
								,newValue:newValue as Array  ? newValue[p] : newValue
								,easeType:easeType as Array  ? easeType [p] : easeType
								,fms:duration as Array  ? int(fps*duration[p]) : int(fps*duration)
								,dSets:dS as Array  ? dS[p] : dS});
					}
				} else {
					// create an object in an array, conveniece for removing garbage collection.
					var eit:* = Boolean(objectList[tnm]);
					if(!eit)
						objectList[tnm] = [undefined, {}];
					objectList[tnm][2] = iT;
					objectList[tnm][3] = dT;
					if(prop as Array)
						for(p in prop)
							managePropertiesValues(tnm, prop[p], {oldValue:oldValue as Array ? oldValue[p] : oldValue
								,newValue:newValue as Array  ? newValue[p] : newValue
								,easeType:easeType as Array  ? easeType [p] : easeType
								,fms:duration as Array  ? int(fps*duration[p]) : int(fps*duration)
								,dSets:dS as Array  ? dS[p] : dS});
					else managePropertiesValues(tnm, prop, {oldValue:oldValue, newValue:newValue, easeType:easeType, fms:int(fps*duration), dSets:dS});
					if(!eit)bindGear(target);
				}
			}
			var tnm:String = debugStat::findCompleteName(target);
			var queueId:int;
			dS || (dS = {});
			dS.dT = dS.dT as Boolean;
			dS.iT = dS.iT as Boolean;
			if (delay > 0) {
				objectList.$[objectList.$.length] = [insideListener, getTimer() + delay * 1000];
				queueId = objectList.$.length;
			} else insideListener();
			
			target.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void {
				delete objectList[tnm];
				if(queueId)
				delete objectList.$[queueId - 1];
				e.target.removeEventListener(e.type, arguments.callee);
			});
		}
/*
		public function terminateTween(target:*, prop:* = null):Number {
			var tnm:String = debugStat::findCompleteName(target);
			return 1;
		}

		public function pauseTween(target:*, prop:* = null):Number {
			var tnm:String = debugStat::findCompleteName(target);
			return 1;
		}

		public function resumeTween(target:*, prop:* = null):Number {
			var tnm:String = debugStat::findCompleteName(target);
			return 1;
		}
*/
		public function regFrameFunction(target:*, f:Function):void {
			var id:String = debugStat::findCompleteName(target);
			target.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void {
				delete objectList[id];
				e.target.removeEventListener(e.type, arguments.callee);
			});
			if(target.stage) {
				objectList[id] = [f];
			} else {
				target.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
					objectList[id] = [f];
					e.target.removeEventListener(e.type, arguments.callee);
				});
			}
		}
		
		public function regEaseFunction(target:*, easeType:int, time:Number, regFunction:Function):void {
			var id:String = debugStat::findCompleteName(target);
			try {
				// Test if the function is valid
				regFunction(0);
			} catch (e:ArgumentError) {
				echo("regFunction must match the requirement \"function(i:Number)\" .");
				return;
			}
			var wrapper:Function = function():void {
				if(objectList[id][1] ++ < objectList[id][2]) {
					regFunction(getEaseValue(easeType, objectList[id][1], objectList[id][2]));
				} else {
					delete objectList[id];
					target.dispatchEvent(new Event("EASE_COMPLETE"));
				}
			}
			// [0]regFunction, [1]current Frame, [2]Time to frame instance
			objectList[id] = [wrapper, 0, int(fps*time)];
		}

		//***************************************Debug***************************************//
		public function debug_listobL(detailed:Boolean = true):void {
			var listCount:int = 250
			, k:int = 0
			, c:int = 0
			;
			for(var i:String in objectList) {
				c ++;
			}
			echo("Object List Size: " + c);
			echo("Delay queue: " + objectList.$.length);
			if(detailed)
			for(i in objectList) {
				debug_dumpObject(i);
			}
			else
			for(i in objectList) {
				echo("Index(" + i + "):");
			}
		}
		public function debug_dumpObject(i:String):void {
			if(objectList[i]) {
				echo("Index(" + i + "):");
				echo(" ", objectList[i][0]);
				echo("  Properties:");
				for (var j:String in objectList[i][1]) {
					echo("   ", j, ":");
					objectList[i][1][j][0] && echo("     Current frame:  ", objectList[i][1][j][0].constructor, objectList[i][1][j][0]);
					objectList[i][1][j][1] && echo("     Total frame:    ", objectList[i][1][j][1].constructor, objectList[i][1][j][1]);
					objectList[i][1][j][2] && echo("     Old value:      ", objectList[i][1][j][2].constructor, objectList[i][1][j][2]);
					objectList[i][1][j][3] && echo("     New value :     ", objectList[i][1][j][3].constructor, objectList[i][1][j][3]);
					objectList[i][1][j][4] && echo("     Change value:   ", objectList[i][1][j][4].constructor, objectList[i][1][j][4]);
					objectList[i][1][j][5] && echo("     Ease type:      ", objectList[i][1][j][5].constructor, objectList[i][1][j][5]);
					objectList[i][1][j][6] && echo("     Inner dT:       ", objectList[i][1][j][6].constructor, objectList[i][1][j][6]);
					objectList[i][1][j][7] && echo("     Inner iT:       ", objectList[i][1][j][7].constructor, objectList[i][1][j][7]);
					objectList[i][1][j][8] && echo("     Bezier ease:    ", objectList[i][1][j][8].constructor, objectList[i][1][j][8]);
					objectList[i][1][j][9] && echo("     Points:         ", objectList[i][1][j][9].constructor, objectList[i][1][j][9]);
					objectList[i][1][j][10] && echo("     Multipliers:    ", objectList[i][1][j][10].constructor, objectList[i][1][j][10]);
					objectList[i][1][j][11] && echo("     Booleans:       ", objectList[i][1][j][11].constructor, objectList[i][1][j][11]);
					objectList[i][1][j][12] && echo("     Color values:   ", objectList[i][1][j][12].constructor, objectList[i][1][j][12]);
					objectList[i][1][j][13] && echo("     Booleans 2:     ", objectList[i][1][j][13].constructor, objectList[i][1][j][13]);
					objectList[i][1][j][14] && echo("     Color values 2: ", objectList[i][1][j][14].constructor, objectList[i][1][j][14]);
					objectList[i][1][j][15] && echo("     Qualities:      ", objectList[i][1][j][15].constructor, objectList[i][1][j][15]);
					objectList[i][1][j][16] && echo("     Inner:          ", objectList[i][1][j][16].constructor, objectList[i][1][j][16]);
					objectList[i][1][j][17] && echo("     Knockout:       ", objectList[i][1][j][17].constructor, objectList[i][1][j][17]);
					objectList[i][1][j][18] && echo("     Type:           ", objectList[i][1][j][18].constructor, objectList[i][1][j][18]);
					objectList[i][1][j][19] && echo("     HideObject:     ", objectList[i][1][j][19].constructor, objectList[i][1][j][19]);
					objectList[i][1][j][20] && echo("     isInitialized:  ", objectList[i][1][j][20].constructor, objectList[i][1][j][20]);
				}
				echo("  Delete object after tween:    " + objectList[i][2]);
				echo("  Invisible object after tween: " + objectList[i][3]);
			}
		}
		public function debug_virtualRun(i:String):void {
			objectList[i][0]();
		}
		public function debug_cycleOnce():void {
			playWorld(null);
			echo ("Cycle interval:", debug_getLoopTime () );
		}
		public function debug_countobL():int {
			var j:int = 0;
			for(var i:String in objectList) {
				j ++;
			}
			return j;
		}
		public function debug_getDone():int {
			return debug_d;
		}
		public function debug_getTriggered():int {
			return debug_t;
		}
		public function debug_getLoopTime():int {
			return debug_a;
		}
		public function debug_pauseWorld():void {
			eHD.removeEventListener(Event.ENTER_FRAME, playWorld);
		}
		public function debug_playWorld():void {
			eHD.addEventListener(Event.ENTER_FRAME, playWorld);
		}
		//***********************************************************************************//

		//Private Methods:
		//Protected Methods:
		protected function bindGear(target:*):void {
			var tnm:String = debugStat::findCompleteName(target);
			var path:Object = objectList[tnm][1];
			objectList[tnm][0] = function():void {
				for(var i:String in path) {
					if(path[i][0] <= path[i][1]) {
						applyTween (target, i, path[i]);
						path[i][0] ++;
						target.dispatchEvent(new Event('MOTION_'+i+'_TWEEN'));
					} else {
						target.dispatchEvent(new Event('MOTION_'+i+'_COMPLETE'));
						checkInnerControl(target, path[i]);
						delete path[i];
					}
				}
				target.dispatchEvent(new Event('ON_MOTION'));
				if(!i) {
					if(objectList[tnm])
						checkOuterControl(target, objectList[tnm]);
					delete objectList[tnm];
					debug_d ++;
					target.dispatchEvent(new Event('All_Tweened'));
				}
			}
		}

		protected function checkOuterControl(target:*, obj:Array):void {
			if(obj) {
				if(obj[2])target.visible = false;
				if(obj[3])target.parent.removeChild(target);
			} else {
				echo('No such target');
			}
		}

		protected function checkInnerControl(target:*, path:Array):void {
			if(path[7])target.visible = false;
			if(path[6])target.parent.removeChild(target);
		}

		protected function checkExistance(name:String, p:Object):* {
			var tmp:Array = objectList[name];
			if (tmp) {
				if(p as Array) {
					var obj:Object = {};
					for each(var i:String in p) {
						if(tmp[1][i])
							obj[i] = true;
						else obj[i] = false;
					}
					return obj;
				} else {
					if(tmp[1][p])
						return true;
				}
			}
			return false;
		}

		production function findCompleteName(t:*):String {
			if(!t)
				return "";
			return production::findCompleteName(t.parent) + "_" + t.name;
		}
		
		debug function findCompleteName(t:*):String {
			if(!t)
			return "";
			var s:String = subSearch(t);
			if(s.indexOf("_null_root") == 0) {
				t.addEventListener(MouseEvent.MOUSE_OVER, debug_nameChild);
				t.addEventListener(MouseEvent.MOUSE_OUT, debug_nameClear);
			}
			return s;
		}
		
		protected function debug_nameChild(e:Event):void {
			debug_child = production::findCompleteName(e.target);
		}
		
		protected function debug_nameClear(e:Event):void {
			debug_child = '';
		}
		
		
		protected function subSearch(t:*):String {
			if(!t)
				return "";
			return subSearch(t.parent) + "_" + t.name;
		}

		protected function applyTween (target:*, prop:String, obj:Array):void {
			if(obj[5] == 'curve') {
				if(!obj[8]) {
					obj[8] = new BezierEase();
					obj[8].points = obj[9];
				}
				var easeValue:Number = obj[8].getValue(obj[0], 0, 1, obj[1]); //percentage interval[0, 1]
			} else {
				easeValue = getEaseValue(obj[5], obj[0], obj[1]);
				delete obj[8], obj[9];
			}

			var oldValue:* = obj[2], newValue:* = obj[3], multiplier:Array = obj[10];

			//Filters' Array
			switch(prop) {
				case "color" :
					if(!obj[20]) {
						if(oldValue is Number) {
							obj[2] = toRGB(obj[2]);
							oldValue = obj[2];
						} else if(!(oldValue is Array))oldValue = [];
						if(newValue is Number) {
							obj[3] = toRGB(obj[3]);
							newValue = obj[3];
						} else if(!(newValue is Array))newValue = [];
						//newValues
						multiplier || (multiplier = [[], [], [], []]);
						isNaN(multiplier[0][1]) && (multiplier[0][1] = 1);//redMultiplier
						isNaN(multiplier[1][1]) && (multiplier[1][1] = 1);//greenMultiplier
						isNaN(multiplier[2][1]) && (multiplier[2][1] = 1);//blueMultiplier
						isNaN(multiplier[3][1]) && (multiplier[3][1] = 1);//alphaMultiplier

						isNaN(newValue[0]) && (newValue[0] = 0);//redOffset
						isNaN(newValue[1]) && (newValue[1] = 0);//greenOffset
						isNaN(newValue[2]) && (newValue[2] = 0);//blueOffset
						isNaN(newValue[3]) && (newValue[3] = 0);//alphaOffset
						//oldValues
						with(target.transform.colorTransform) {
							isNaN(multiplier[0][0]) && (multiplier[0][0] = redMultiplier);
							isNaN(multiplier[1][0]) && (multiplier[1][0] = greenMultiplier);
							isNaN(multiplier[2][0]) && (multiplier[2][0] = blueMultiplier);
							isNaN(multiplier[3][0]) && (multiplier[3][0] = alphaMultiplier);

							isNaN(oldValue[0]) && (oldValue[0] = redOffset);
							isNaN(oldValue[1]) && (oldValue[1] = greenOffset);
							isNaN(oldValue[2]) && (oldValue[2] = blueOffset);
							isNaN(oldValue[3]) && (oldValue[3] = alphaOffset);
						}
						if(!obj[4]) {
							obj[4] = [];
							for(e = 0; e < 4; e ++)
								obj[4][e] = newValue[e] - oldValue[e];
						}
						obj[10] = multiplier;
						obj[2] = oldValue;//linking oldValue back to obj
						obj[3] = newValue;//linking newValue back to obj

						obj[20] = true;
					}//End Initializations
					target.transform.colorTransform = new ColorTransform(
										multiplier[0][0] + (multiplier[0][1] - multiplier[0][0]) * easeValue
										, multiplier[1][0] + (multiplier[1][1] - multiplier[1][0]) * easeValue
										, multiplier[2][0] + (multiplier[2][1] - multiplier[2][0]) * easeValue
										, multiplier[3][0] + (multiplier[3][1] - multiplier[3][0]) * easeValue
										, oldValue[0] + obj[4][0] * easeValue
										, oldValue[1] + obj[4][1] * easeValue
										, oldValue[2] + obj[4][2] * easeValue
										, oldValue[3] + obj[4][3] * easeValue);
				break;
				default :
					if(prop.indexOf("Filter") != -1) {
						oldValue = (obj[2] ||= []);
						obj[3] ||= [];
						var idx:int
						, e:int
						, oCV:Number// = oldValue[2]
						, o2V:Number// = oldValue[4]
						, filObj:Array = target.filters
						, ca:Array
						, c2:Array
						, f:BitmapFilter
						;
						switch(prop) {
							case "BevelFilter" :
								idx = findFilter(filObj, BevelFilter);
								if(!obj[20]) {
									isNaN(newValue[0]) && (newValue[0] = 4);//distance
									isNaN(newValue[1]) && (newValue[1] = 45);//angle
									isNaN(newValue[2]) && (newValue[2] = 0xFFFFFF);//higlight color
									isNaN(newValue[3]) && (newValue[3] = 1);//higlight alpha
									isNaN(newValue[4]) && (newValue[4] = 0);//shadow color
									isNaN(newValue[5]) && (newValue[5] = 1);//shadow alpha
									isNaN(newValue[6]) && (newValue[6] = 4);//blurX
									isNaN(newValue[7]) && (newValue[7] = 4);//blurY
									isNaN(newValue[8]) && (newValue[8] = 1);//strength
									if(!obj[4])obj[4] = [];
									if(idx == -1) {
										filObj ||= [];
									} else {
										with(filObj[idx]) {
											oldValue[0] = distance;
											oldValue[1] = angle;
											oldValue[2] = highlightColor;
											oldValue[3] = highlightAlpha;
											oldValue[4] = shadowColor;
											oldValue[5] = shadowAlpha;
											oldValue[6] = blurX;
											oldValue[7] = blurY;
											oldValue[8] = strength;
										}
									}

									for(e = 0; e < 9; e ++)
										obj[4][e] = newValue[e] - (oldValue[e] = oldValue[e] ? oldValue[e]:0);
									oCV = oldValue[2]
									o2V = oldValue[4]
									ca = differentiateColors(oCV, newValue[2]);
									c2 = differentiateColors(o2V, newValue[4]);
									obj[11] = ca[0];
									obj[12] = ca[1];
									obj[13] = c2[0];
									obj[14] = c2[1];

									obj[11][0] = obj[11][0] ? obj[12][0] : - obj[12][0];
									obj[11][1] = obj[11][1] ? obj[12][1] : - obj[12][1];
									obj[11][2] = obj[11][2] ? obj[12][2] : - obj[12][2];

									obj[13][0] = obj[13][0] ? obj[14][0] : - obj[14][0];
									obj[13][1] = obj[13][1] ? obj[14][1] : - obj[14][1];
									obj[13][2] = obj[13][2] ? obj[14][2] : - obj[14][2];
									obj[2] = oldValue;//linking oldValue back to obj
									obj[3] = newValue;//linking newValue back to obj

									obj[20] = true;
								}//End Initializations
								idx != -1 && (delete filObj.splice(idx, 1));
								f =	new BevelFilter(
										obj[4][0] ? oldValue[0] + obj[4][0]*easeValue : newValue[0]
										,obj[4][1] ? oldValue[1] + obj[4][1]*easeValue : newValue[1]
										, cC((oCV >> 16 & 0xFF) + obj[11][0] * easeValue
											, (oCV >> 8 & 0xFF) + obj[11][1] * easeValue
											, (oCV & 0xFF) + obj[11][2] * easeValue)
										, obj[4][3] ? oldValue[3] + obj[4][3]*easeValue : newValue[3]
										, cC((o2V >> 16 & 0xFF) + obj[13][0] * easeValue
											, (o2V >> 8 & 0xFF) + obj[13][1] * easeValue
											, (o2V & 0xFF) + obj[13][2] * easeValue)
										, obj[4][5] ? oldValue[5] + obj[4][5]*easeValue : newValue[5]
										, obj[4][6] ? oldValue[6] + obj[4][6]*easeValue : newValue[6]
										, obj[4][7] ? oldValue[7] + obj[4][7]*easeValue : newValue[7]
										, obj[4][8] ? oldValue[8] + obj[4][8]*easeValue : newValue[8]
										, obj[15] || 1, obj[18] as String || "inner", Boolean(obj[17]));
								filObj.push(f);
								target.filters = filObj;
							break;
							case "BlurFilter" :
								idx = findFilter(target.filters, BlurFilter);
								if(!obj[20]) {
									isNaN(newValue[0]) && (newValue[0] = 4);//blurX
									isNaN(newValue[1]) && (newValue[1] = 4);//blurY
									if(!obj[4])
										obj[4] = [];
									if(idx == -1) {
										filObj ||= [];
									} else {
										oldValue[0] = filObj[idx].blurX;
										oldValue[1] = filObj[idx].blurY;
									}
									for(e = 0; e < 3; e ++)
										obj[4][e] = newValue[e] - (oldValue[e] = oldValue[e] ? oldValue[e]:0);
									obj[2] = oldValue;//linking oldValue back to obj
									obj[3] = newValue;//linking newValue back to obj

									obj[20] = true;
								}//End Initializations
								idx != -1 && (delete filObj.splice(idx, 1));
								f =	new BlurFilter(
										obj[4][0] ? oldValue[0] + obj[4][0]*easeValue : newValue[0]
										, obj[4][1] ? oldValue[1] + obj[4][1]*easeValue : newValue[1]
										, obj[15] || 1);
								filObj.push(f);
								target.filters = filObj;
							break;
							case "ColorMatrixFilter" :
							break;
							case "ConewValueolutionFilter" :
							break;
							case "DisplacementMapFilter" :
							break;
							case "DropShadowFilter" :
								idx = findFilter(target.filters, DropShadowFilter);
								if(!obj[20]) {
									isNaN(newValue[0]) && (newValue[0] = 4);//distance
									isNaN(newValue[1]) && (newValue[1] = 45);//angle
									isNaN(newValue[2]) && (newValue[2] = 0);//color
									isNaN(newValue[3]) && (newValue[3] = 1);//alpha
									isNaN(newValue[4]) && (newValue[4] = 4);//blurX
									isNaN(newValue[5]) && (newValue[5] = 4);//blurY
									isNaN(newValue[6]) && (newValue[6] = 1);//strength
									if(!obj[4])
										obj[4] = [];
									if(idx == -1) {
										filObj ||= [];
									} else {
										with(filObj[idx]) {
											oldValue[0] = distance;
											oldValue[1] = angle;
											oldValue[2] = color;
											oldValue[3] = alpha;
											oldValue[4] = blurX;
											oldValue[5] = blurY;
											oldValue[6] = strength;
										}
									}
									for(e = 0; e < 7; e ++)
										obj[4][e] = newValue[e] - (oldValue[e] = oldValue[e] ? oldValue[e]:0);

									oCV = oldValue[2];
									ca = differentiateColors(oCV, newValue[2]);
									obj[11] = ca[0];
									obj[12] = ca[1];

									obj[11][0] = obj[11][0] ? obj[12][0] : - obj[12][0];
									obj[11][1] = obj[11][1] ? obj[12][1] : - obj[12][1];
									obj[11][2] = obj[11][2] ? obj[12][2] : - obj[12][2];
									obj[2] = oldValue;//linking oldValue back to obj
									obj[3] = newValue;//linking newValue back to obj

									obj[20] = true;
								}//End initializations
								idx != -1 &&
								(delete filObj.splice(idx, 1));
								f =	new DropShadowFilter(
										obj[4][0] ? oldValue[0] + obj[4][0]*easeValue : newValue[0]
										,obj[4][1] ? oldValue[1] + obj[4][1]*easeValue : newValue[1]
										, cC((oCV >> 16 & 0xFF) + obj[11][0] * easeValue
											, (oCV >> 8 & 0xFF) + obj[11][1] * easeValue
											, (oCV & 0xFF) + obj[11][2] * easeValue)
										, obj[4][3] ? oldValue[3] + obj[4][3]*easeValue : newValue[3]
										, obj[4][4] ? oldValue[4] + obj[4][4]*easeValue : newValue[4]
										, obj[4][5] ? oldValue[5] + obj[4][5]*easeValue : newValue[5]
										, obj[4][6] ? oldValue[6] + obj[4][6]*easeValue : newValue[6]
										, obj[15] || 1, Boolean(obj[16]), Boolean(obj[17]), Boolean(obj[19]));
								filObj.push(f);
								target.filters = filObj;
							break;
							case "GlowFilter" :
								idx = findFilter(target.filters, GlowFilter);
								if(!obj[20]) {
									if(newValue is Array) {
										isNaN(newValue[0]) && (newValue[0] = 0xFF0000);//color
										isNaN(newValue[1]) && (newValue[1] = 1);//alpha
										isNaN(newValue[2]) && (newValue[2] = 6);//blurX
										isNaN(newValue[3]) && (newValue[3] = 6);//blurY
										isNaN(newValue[4]) && (newValue[4] = 2);//strength
									} else newValue = [newValue, 1, 6, 6, 2];
									if(!(oldValue is Array))
										oldValue = [oldValue, 0, 0, 0, 0];
									if(!obj[4])
										obj[4] = [];
									if(idx == -1) {
											filObj ||= [];
									} else {
										with(filObj[idx]) {
											oldValue[0] = color;
											oldValue[1] = alpha;
											oldValue[2] = blurX;
											oldValue[3] = blurY;
											oldValue[4] = strength;
										}
									}
									for(e = 0; e < 5; e ++)
										obj[4][e] = newValue[e] - (oldValue[e] = oldValue[e] ? oldValue[e]:0);

									oCV = oldValue[0];
									ca = differentiateColors(oCV, newValue[0]);
									obj[11] = ca[0];
									obj[12] = ca[1];

									obj[11][0] = obj[11][0] ? obj[12][0] : - obj[12][0];
									obj[11][1] = obj[11][1] ? obj[12][1] : - obj[12][1];
									obj[11][2] = obj[11][2] ? obj[12][2] : - obj[12][2];
									obj[2] = oldValue;//linking oldValue back to obj
									obj[3] = newValue;//linking newValue back to obj

									obj[20] = true;
								}//End initializations
								oCV = oldValue[0];
								idx != -1 && (delete filObj.splice(idx, 1));
								f =	new GlowFilter(
										cC((oCV >> 16 & 0xFF) + obj[11][0] * easeValue
											, (oCV >> 8 & 0xFF) + obj[11][1] * easeValue
											, (oCV & 0xFF) + obj[11][2] * easeValue)
										, obj[4][1] ? oldValue[1] + obj[4][1]*easeValue : newValue[1]
										, obj[4][2] ? oldValue[2] + obj[4][2]*easeValue : newValue[2]
										, obj[4][3] ? oldValue[3] + obj[4][3]*easeValue : newValue[3]
										, obj[4][4] ? oldValue[4] + obj[4][4]*easeValue : newValue[4]
										, obj[15] || 1, Boolean(obj[16]), Boolean(obj[17]));
								filObj.push(f);
								target.filters = filObj;
							break;
							case "GradientBevelFilter" :
							break;
							case "GradientGlowFilter" :
							break;
							case "ShaderFilter" :
							break;
							default:
								trace('No such filter');
							break;
						}
					} else {
						if(!obj[4]) {
							obj[2]=isNaN(oldValue) ? target[prop] : oldValue;//currentValue to oldValue
							obj[4]=newValue - obj[2];//change value = new value - old value
						}

						var cV:Number = obj[2] + obj[4] * easeValue;
						switch(prop) {
							case "scaleX" :
								(cV > 0) && (target[prop] = cV);
								(cV < 0) && (target[prop] = 0);
							break;
							case "scaleY" :
								(cV > 0) && (target[prop] = cV);
								(cV < 0) && (target[prop] = 0);
							break;
							case "alpha" :
								if(cV > 1)
									target[prop] = 1;
								else if(cV < 0)
									target[prop] = 0;
								else
									target[prop] = cV;
							break;
							default :
								target[prop] = cV;
							break;
						}
					}
				break;
			}
			debug_t ++;
		}

		/*
		var objectList = {instance1: 
		[function s() {}, 
			{x:[0, 0, 100, 0, 13]
			 , y:[0, 0, 100, 0, 13]}, false, false]
			...}
		*/
		protected function managePropertiesValues(n:String, prop:String, values:Object):void {
			if(!objectList[n][1][prop]) {
				//Here's to create default values.
				var path:Object = objectList[n][1];
				path[prop] = [];
				path = path[prop];
				path[7] = false;//<----------|
										//inner Control--|
				path[6] = false;//<----------|
				path[1] = values.fms;
			} else {
				path = objectList[n][1][prop];
				if(values.fms)path[1] = values.fms;
			}
			path[0] = 0;
			path[2] = isNaN(values.oldValue) ? (values.oldValue as Array ? values.oldValue : NaN) : values.oldValue;
			path[4] = null;
			path[3] = values.newValue;
			path[5] = values.easeType;
			path[20] = false;
			if(values.dSets)
				for (var i:String in values.dSets)
					switch(i) {
						case 'Pts':
							path[9] = values.dSets[i];
						break;
						case 'mpr':
							path[10] = values.dSets[i];
						break;
						case 'qlt':
						 	path[15] = values.dSets[i];
						break;
						case 'inr':
							path[16] = values.dSets[i];
						break;
						case 'nkt':
							path[17] = values.dSets[i];
						break;
						case 'tpe':
							path[18] = values.dSets[i];
						break;
						case 'hob':
							path[19] = values.dSets[i];
						break;
					}
		}

		protected function findFilter(arr:Array, filter:Class):int {
			if(!arr.length)return -1;
			for(var i:String in arr)
				if(arr[i] as filter)
					return Number(i);
			return -1;
		}

		protected function differentiateColors(oldValue:*, newValue:*):Array {
			oldValue = toRGB(oldValue);
			newValue = toRGB(newValue);
			return [new Array(newValue[0] > oldValue[0]
							, newValue[1] > oldValue[1]
							, newValue[2] > oldValue[2]
							, newValue[3] > oldValue[3])
					, new Array(Math.abs(newValue[0] - oldValue[0])//R chanel '0'
							, Math.abs(newValue[1] - oldValue[1])//G chanel '1'
							, Math.abs(newValue[2] - oldValue[2])//B chanel '2'
							, Math.abs(newValue[3] - oldValue[3]))];
		}

		protected function toRGB(val:Number):Array {
			if(val < 16777216)
				return [val >> 16 & 0xFF, val >> 8 & 0xFF, val & 0xFF, 0xFF];
			return [val >> 16 & 0xFF, val >> 8 & 0xFF, val & 0xFF, val >> 24 & 0xFF];
		}

		protected function cC(R:Number, G:Number, B:Number, A:Number = NaN):int {
			if(isNaN(A))
				return (R << 16 & 0xFF0000) + (G << 8 & 0xFF00) + (B & 0xFF);
			return (A << 24 & 0xFF000000) + (R << 16 & 0xFF0000) + (G << 8 & 0xFF00) + (B & 0xFF);
		}
		
		private function playWorld(e:Event):void {
			debug_a = getTimer();
			for(var i:String in objectList)
				objectList[i][0]();
			debug_a = getTimer() - debug_a;
		}

		protected function getEaseValue(e:int, t:Number, d:Number):Number {
			if(d == 0)return 1;
			if(t == 0)return 0;
			if(t == d)return 1;
			var s:Number = 1.70158;
			switch (e) {
				case 0://Back
					return (t /= d) * t * ((s + 1) * t - s);
				break;
				case 1://OutBack
					return ((t = t / d - 1) * t * ((s + 1) * t + s) + 1);
				break;
				case 2://InOutBack
					if ((t /= d / 2) < 1)
						return .5 * (t * t * (((s *= (1.525)) + 1) * t - s));
					return .5 * ((t -= 2) * t * (((s *= (1.525)) + 1) * t + s) + 2);
				break;
				case 3://Bounce
					return 1 - getEaseValue(4, d - t, d);
				break;
				case 4://O
					if ((t/=d) < (1/2.75))
						return (7.5625 * t * t);
					else if (t < (2/2.75))
						return (7.5625*(t-=(1.5/2.75))*t + .75);
					else if (t < (2.5/2.75))
						return (7.5625*(t-=(2.25/2.75))*t + .9375);
					else
						return (7.5625*(t-=(2.625/2.75))*t + .984375);
				break;
				case 5://M
					if (t < d / 2)
						return getEaseValue(3, t * 2, d) * 0.5;
					else
						return getEaseValue(4, t * 2 - d, d) * 0.5 + 0.5;
				break;
				case 6://checkInnerControlular
					return - (Math.sqrt(1 - (t /= d) * t) - 1);
				break;
				case 7://O
					return Math.sqrt(1 - (t = t / d - 1) * t);
					break;
				case 8://M
					if ((t /= d / 2) < 1)
						return - .5 * (Math.sqrt(1 - t * t) - 1);
					return .5 * (Math.sqrt(1 - (t -= 2) * t) + 1);
				break;
				case 9://Cubic
					return (t /= d) * t * t;
				break;
				case 10://O
					return ((t = t / d - 1) * t * t + 1);
				break;
				case 11://M
					if ((t /= d / 2) < 1)
						return .5 * t * t * t;
					return .5 * ((t -= 2) * t * t + 2);
				break;
				case 12://Elastic
					t /= d;
					var p:Number = d * 0.3;
					s = p / 4;
					return - Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p);
				break;
				case 13://O
					p = d * 0.3;
					s = p / 4;
					return Math.pow(2,  - 10 * (t / d)) * Math.sin((t - s) * (2 * Math.PI) / p) + 1;
				break;
				case 14://M
					t /= d / 2;
					p = d * (0.3 * 1.5);
					s = p / 4;
					if (t < 1)
						return - 0.5 * (Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p));
					return Math.pow(2, - 10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p) * 0.5 + 1;
				break;
				case 15://Exponential
					return t == 0?0:Math.pow(2, 10 * (t / d - 1));
				break;
				case 16://O
					return t == d?1:(- Math.pow(2,  - 10 * t / d) + 1);
				break;
				case 17://M
					if ((t /= d / 2) < 1)
						return .5 * Math.pow(2, 10 * (t - 1));
					return .5 * ( - Math.pow(2,  - 10 * --t) + 2);
				break;
				case 18://Linear, None
					return t / d;
				break;
				case 19://Regular, Quardurationatic
					return (t /= d) * t;
				break;
				case 20://O
					return - (t /= d) * (t - 2);
				break;
				case 21://M
					if ((t /= d / 2) < 1)
						return .5 * t * t;
					return - .5 * (( --t) * (t - 2) - 1);
				break;
				case 22://Quartic
					return (t /= d) * t * t * t;
				break;
				case 23://O
					return - ((t = t / d - 1) * t * t * t - 1);
				break;
				case 24://M
					if ((t /= d / 2) < 1)
						return .5 * t * t * t * t;
					return - .5 * ((t -= 2) * t * t * t - 2);
				break;
				case 25://Strong, Quintic
					return (t /= d) * t * t * t * t;
				break;
				case 26://O
					return ((t = t / d - 1) * t * t * t * t + 1);
				break;
				case 27://M
					if ((t /= d / 2) < 1)
						return .5 * t * t * t * t * t;
					return .5 * ((t -= 2) * t * t * t * t + 2);
				break;
				case 28://Sine
					return - Math.cos(t / d * (Math.PI / 2)) + 1;
				break;
				case 29://O
					return Math.sin(t / d * (Math.PI / 2));
				break;
				case 30://M
					return - .5 * (Math.cos(Math.PI * t / d) - 1);
				break;
				default :
					trace("No such type:" + e);
				break;
			}
			return NaN;
		}

	}
}