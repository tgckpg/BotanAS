package BotanAS.Sys {
	// This classs handles all resources that need to load externally

	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoaderDataFormat;
	import flash.media.Sound;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.system.LoaderContext;

	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.EventDispatcher;

	public class GLoader extends EventDispatcher {

		// Constant for GLoaderInfo to identify this class
		public const
		  $GLC$:Boolean = true
		// Max threads available
		, maxThreads:int = 5
		;

		//// Namespaces
		// These control the setRes function behave when onFin is called
		private namespace initOn;
		private namespace initOff;

		private var 
		//// Globals
		// Namespace
		  initState:Namespace
		// Represent the currents instance
		, gRequest:URLRequest
		, gLoader:Loader
		, gULoader:URLLoader
		, gSound:Sound
		, gThread:int

		// Echo function for debugging
		, echo:Function = function (...msg:*):void { trace(msg); }

		//// Vectors
		// Provides loading info
		, info:Vector.<String>
		// Roots for loading resources, see function "initLoadComplete"
		, roots:Vector.< Vector.<String> >
		// Resources list for loading
		, loadQue:Vector.< Vector.<String> >

		//// Multithread
		// Threads
		, URLLoaders:Vector.<URLLoader>
		, Loaders:Vector.<Loader>
		, Sounds:Vector.<Sound>
		// Current resources list on loaging
		, activeLoading:Vector.< Vector.<String> >
		// Is Thread using
		, isRunning:Vector.<Boolean>
		// See function "determineLoader"
		, activeThreads:Vector.<int>
		// Array that given
		, resArray:Array

		// Individual loadRes variables
		, resPool:Array = []

		// This is a special variables that reference to current active loader
		, whichLoaderInfo:Vector.<Object>
		;

		public function GLoader(id:String, loadCue:String = null, resourcesArray:Array = null, echo:Function = null):void {
			if(echo as Function) {
				this.echo = echo;
				echo ("  {GLoader}");
			}
			
			initialize();
			
			resArray ||= resourcesArray;
			gRequest.url ||= loadCue;

			// Update gULoader for loading
			if(assignLoader(2) == 99) {
				var res:Vector.<String> = new Vector.<String>(4, true);
				res[0] = id;
				res[1] = loadCue;
				res[2] = '';
				res[3] = 'loadCue';
				loadQue[loadQue.length] = res;
			}
		}

		public function getLoadInfo():Vector.<String> {
			return info;
		}

		public function load(loadCue:String = null, resourcesArray:Array = null, echo:Function = null):void {
			try {
				resArray ||= resourcesArray;
				gRequest.url ||= loadCue;

				if(!resArray)
				throw new Error ("Resourcces Array must be set.");
				if(!gRequest.url)
				throw new Error ("Loader cue must be set.");

				gULoader.load(gRequest);
			} catch (e:Error) {
				echo(e);
			}
		}
		
		
		public function loadRes(url:String, id:String, useRoots:Boolean = false):void {
		// This function will be called after each resources is loaded and processed (setRes)
			var 
			  usingWhat:int
			, activeIndex:int
			, currRes:Vector.<String>
			;
			try {
				gRequest.url = (useRoots ? getRootForRes(url) : "") + url;
				// Check what loader is going to be used
				usingWhat = determineLoader(url);
				// currRes init
				currRes = new Vector.<String>(4, true);
				currRes[0] = id;
				currRes[1] = gRequest.url;
				currRes[2] = "";
				currRes[3] = "resPool";
				if( ( activeIndex = assignLoader(usingWhat) ) == 99 ) {
				// Suspense this loading process
					loadQue[loadQue.length] = currRes;
					return;
				}
				// Put currRes into activeLoading
				activeLoading[activeIndex] = currRes;
				// Create push
				switch(usingWhat) {
					// Case 0 for Loader, 1 for sound, 2 for URLLoader, 3 for swf
					case 0:
						// Handles jpg, png and gif

						gLoader.load(gRequest);
					break;
					case 1:

						gSound.load(gRequest);
					break;
					case 2:
						// Handles texts, and all other files

						// Set the dataFormat
						gULoader.dataFormat = determineLoadFormat(currRes[1]);
						gULoader.load(gRequest);
					break;
					case 3:
						gLoader.load(gRequest);
					break;
				}
			} catch (e:Error) {
				echo (e, e.getStackTrace());
			}
		}
		
		protected function initialize():void {
		//// Initializations, statements see above
			URLLoaders ||= new Vector.<URLLoader>(maxThreads, true);
			Loaders ||= new Vector.<Loader>(maxThreads, true);
			Sounds ||= new Vector.<Sound>(maxThreads, true);
			activeLoading ||= new Vector.< Vector.<String> >(maxThreads, true);
			isRunning ||= new Vector.<Boolean>(maxThreads, true);
			activeThreads ||= new Vector.<int>(maxThreads, true);
			gRequest ||= new URLRequest;
			info ||= new Vector.<String>(maxThreads, true);
			// initState On
			initState ||= initOn;

			// activeThreads switches
			activeThreads.forEach(initActiveThread);

			// Settings
			gRequest.requestHeaders.push(new URLRequestHeader("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"));
			gRequest.requestHeaders.push(new URLRequestHeader("Accept-Language", "en-US,en;q=0.8"));
			gRequest.requestHeaders.push(new URLRequestHeader("Cache-Control", "max-age=0"));
			gRequest.requestHeaders.push(new URLRequestHeader("Content-Type", "application/x-www-form-urlencoded"));
		}
		
		protected function assignLoader(type:int):int {
			// This function assign the loader the Global loader instance
			// , and controls the availability of threads 
			// Check for available threads
			for ( var i:int = 0; i < maxThreads; i ++ ) {
				// Check if the thread is available.
				if(!isRunning[i]) {
					// Max this thread locked
					isRunning[i] = true;
					// This function releasing the thread when the loader is finished loading
					var onGoing:Function = function (e:Event):void {
						// Transit to setProgressInfo
						initState::setProgressInfo(String( Math.floor( 100*(e.target.bytesLoaded/e.target.bytesTotal) ) ), i);
						dispatchEvent(new Event("onGoing"));
					}
					, onFin:Function = function (e:Event) :void {
						// Assign current thread Index that finished loading
						// and set the "is loader active" to false
						isRunning[gThread = i] = false;
						// Transit to setRes
						initState::setRes(e);
						// Dispatch an event once loading is complete
						dispatchEvent(new Event("ThreadReleased"));
						e.target.removeEventListener(Event.COMPLETE, onFin);
						e.target.removeEventListener(ProgressEvent.PROGRESS, onGoing);
					}
					;
					switch ( activeThreads[i] = type ) {
						case 0:
							// Create Loader if it is not initialized
							Loaders[i] ||= new Loader;
							// Reference the loader to Global Loader instance.
							gLoader = Loaders[i];
							Loaders[i].contentLoaderInfo.addEventListener(Event.COMPLETE, onFin);
							Loaders[i].contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onGoing);
						break;
						case 1:
							// Create if it does not exist
							Sounds[i] = new Sound;
							Sounds[i].addEventListener(Event.COMPLETE, onFin);
							Sounds[i].addEventListener(ProgressEvent.PROGRESS, onGoing);
							gSound = Sounds[i];
							break;
						case 2:
							// Same as above
							URLLoaders[i] ||= new URLLoader;
							gULoader = URLLoaders[i];
							URLLoaders[i].addEventListener(Event.COMPLETE, onFin);
							URLLoaders[i].addEventListener(ProgressEvent.PROGRESS, onGoing);
							URLLoaders[i].addEventListener(IOErrorEvent.IO_ERROR, handleError);
							URLLoaders[i].addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError);
						break;
						case 3:
							// swfs are special contents that contains classes and definition
							// , so it need a new loader to handle it.
							// By considering the loadByte method is too resources drifting
							// this method is rejected.
							
							Loaders[i] = new Loader;
							// This immediately unlink the loader when complete
							Loaders[i].contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event):void {
								//Renew the loader
								Loaders[i] = new Loader;
								e.target.removeEventListener(e.type, arguments.callee);
							});
							Loaders[i].contentLoaderInfo.addEventListener(Event.COMPLETE, onFin);
							Loaders[i].contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onGoing);
							gLoader = Loaders[i];
						break;
					}
					return i;
				}
			}
			// if none available.
			return 99;
		}
		
		protected function handleError(e:Event):void {
			var _e:Event;
			if( (_e = (e as IOErrorEvent)) )
			echo(_e);
			if( (_e = (e as SecurityErrorEvent)) )
			echo(_e);
			
		}

		protected function startLoad(e:Event = null):void {
		// This function will be called after each resources is loaded and processed (setRes)
			var 
			  usingWhat:int
			, activeIndex:int
			, currRes:Vector.<String>
			;
			// Remove the listener if set
			e && removeEventListener("ThreadReleased", startLoad);
			if(loadQue.length) {
				try {
					// Pickup resource definition
					currRes = loadQue.pop();
					// If noroot "currRes[2]" is set, skip the getRootForRes function
					if(currRes[1]) {
						gRequest.url = (currRes[2] ? "" : getRootForRes(currRes[1])) + currRes[1];
					} else {
						// If this is a sub-node, that means it is a　resources used by some classes
						// Just push it to res array and start over
						var res:Vector.<Object> = new Vector.<Object>(2, true);
						// id
						res[0] = XML(currRes[3]).name();
						// XML
						res[1] = currRes[3];
						// Push
						resArray[resArray.length] = res;
						// Start over
						startLoad();
						return;
					}
					// Check what loader is going to be used
					usingWhat = determineLoader(currRes[1]);
					if( ( activeIndex = assignLoader(usingWhat) ) == 99 ) {
					// Suspense this loading process
						// Push back the resources cue
						loadQue[loadQue.length] = currRes;
						// Once a thread is released, load again
						addEventListener("ThreadReleased", startLoad);
						return;
					}
					// Put currRes into activeLoading
					activeLoading[activeIndex] = currRes;

					// Create push
					switch(usingWhat) {
						// Case 0 for Loader, 1 for sound, 2 for URLLoader, 3 for swf
						case 0:
							// Handles jpg, png and gif

							gLoader.load(gRequest);
						break;
						case 1:

							gSound.load(gRequest);
						break;
						case 2:
							// Handles texts, and all other files

							// Set the dataFormat
							gULoader.dataFormat = determineLoadFormat(currRes[1]);
							gULoader.load(gRequest);
						break;
						case 3:
							gLoader.load(gRequest);
						break;
					}
				} catch (e:Error) {
					echo (e);
				}
				// Start over
				startLoad();
			} else {
				//// All resources' set, cleaning up
				// Unlink Variables
				//loadQue = null;
				gRequest.url = "";
			}
		}

		initOff function setRes(e:Event):void {
		// This function duplicates loaded data and push it into resources array that had been given
			var res:Vector.<Object> = new Vector.<Object>(activeLoading[gThread].length - 1, true);
			// Resources id
			res[0] = activeLoading[gThread][0];
			switch (activeThreads[gThread]) {
				case 0:
					// Clone bitmap and push the Bitmap object
					res[1] = new Bitmap(Bitmap(e.target.content).bitmapData.clone());
				break;
				case 1:
					// Push sounds object
					res[1] = e.target;
					e.target.removeEventListener(e.type, arguments.callee);
				break;
				case 2:
					res[1] = e.target.data;
					// Reset the dataFormat to TEXT
					e.target.dataFormat = URLLoaderDataFormat.TEXT;
				break;
				case 3:
					res[1] = e.target;
					e.target.removeEventListener(e.type, arguments.callee);
				break;
			}
			// if res length is 3, then switches is set
			if(res.length == 3) {
				var f:String = activeLoading[gThread][3];
				if(f == "resPool") {
					// Put it into resPool
					resPool[resPool.length] = res;
				} else if(f == "loadCue") {
					// initialize loadCue
					initOn::setRes(e);
				} else {
					res[2] = f;
					resArray[resArray.length] = res;
				}
			} else {
				// Push it
				resArray[resArray.length] = res;
			}
			// Check if all resources are loaded
			if(isAllLoaded()) {
			//// Clean up and re-initialize
				cleanUp();
				initialize();
				// off-init due to re-initialization
				initState = initOff;
				// Dispatch a COMPLETE event
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function cleanUp():void {
			//// Unlink Variables
			URLLoaders = null;
			Loaders = null;
			Sounds = null;
			gLoader = null;
			gULoader = null;
			gSound = null;
			initState = null;
			gThread = NaN;
			info = null;
			//roots = null;
			activeLoading = null;
			isRunning = null;
			activeThreads = null;
			resArray = null;
			whichLoaderInfo = null;
		}
		
		private function isAllLoaded():Boolean {
			if(loadQue && loadQue.length)
				return false;
			for each(var i:Boolean in isRunning) {
				if(i)return false;
			}
			return true;
		}
		
		initOn function setRes(e:Event):void {
			try {
				// initState off
				initState = initOff;

				var loadCue:XML = new XML(gULoader.data)
				, resources:XMLList = loadCue.child("resources").children()
				, resRoot:XMLList
				;

				// If resRoot is present, its length will be greater than 0
				if(( resRoot = loadCue.child("ResRoot") ).length()) {
					// Then initialize roots
					roots = new Vector.< Vector.<String> >;
					// Get resource root node
					for each(var res:XML in resRoot.child("res")) {
						// A wrapper of each group of strings
						var wrapper:Vector.<String> = new Vector.<String>;
						// First element must be res path
						wrapper[0] = res.attribute("path")[0];
						// Get matching types
						for each (var type:XML in res.child("type")) {
							// Put it after res path
							wrapper[wrapper.length] = type.attribute("val")[0];
						}
						// Register wrapper in to roots
						roots[roots.length] = wrapper;
					}
				}

				loadQue = new Vector.< Vector.<String> >;
				for each ( res in resources ) {
					//[Name, path]
					
					var cue:Vector.<String> = res.children().length() ? new Vector.<String>(4, true) : new Vector.<String>(3, true);
					// Name
					cue[0] = ( res.name() );
					// path
					cue[1] = res.attribute("src")[0];
					// Using "i" and an empty string due to string restriction (Vector.<String>)
					cue[2] = res.attribute("noroot").length() ? "1":"";
					// Reference the LoadCue
					res.children().length() && (cue[3] = res.toXMLString());
					loadQue[loadQue.length] = cue;
				}

			} catch (e:Error) {
				echo (e, e.getStackTrace());
			}
			// Start loading
			startLoad();
		}

		initOn function setProgressInfo(progress:String, i:int): void {
		// Set loading info
			info[0] = "Load cue... " + progress;
		}

		initOff function setProgressInfo(progress:String, i:int): void {
		// Set loading info
			info[i] = activeLoading[i][0] + "... " + progress;
		}

		private function determineLoader(name:String):int {
		// Return 0 if using Loader, 1 if using Sound, 2 if using URLLoader.
			switch(getFileExtension(name)) {
				case "gif":
					return 0;
				break;
				case "png":
					return 0;
				break;
				case "jpg":
					return 0;
				break;
				case "mp3":
					return 1;
				break;
				case "swf":
					return 3;
				break;
				default:
					return 2;
			}
		}

		private function determineLoadFormat(name:String):String {
		// This is a temperary appraoch to format switching
		// It will soon be changed to format casting.
			switch (getFileExtension(name)) {
				case "txt":
					return URLLoaderDataFormat.TEXT;
				break;
				case "css":
					return URLLoaderDataFormat.TEXT;
				break;
				case "htm":
					return URLLoaderDataFormat.TEXT;
				break;
				case "lrc":
					return URLLoaderDataFormat.TEXT;
				break;
				case "as":
					return URLLoaderDataFormat.TEXT;
				break;
				case "html":
					return URLLoaderDataFormat.TEXT;
				break;
				default:
					return URLLoaderDataFormat.BINARY;
			}
		}

		private function getRootForRes(name:String):String {
		// This function returns the root of specific resource type
			var type:String;
			// Get the file extension
			type = getFileExtension(name);
			// If matched
			if(type)
			// Loop over roots
			for each(var root:Vector.<String> in roots) {
				// Start aside from path
				for (var t:int = 1; t < root.length; t ++) {
					if(root[t] == type)
					// return the path
					return root[0];
				}
			}
			// Else return empty string
			return "";
		}
		
		private function initActiveThread(item:int, index:int, vector:Vector.<int>):void {
			vector[index] = 99;
		}

		private function getFileExtension(name:String):String {
			return name.match(/\.[\w\d]+$/)[0].slice(1);
		}

		public function loadXML(path:String, handler:Function, errhandle:Function, method:String = "GET", order:String = null):void {
		// ----->>>>>>>> Await to verify
			try {
				gRequest.method = method;
				if (order) {
					gRequest.data = order;
				}
				gRequest.url = path;
				gLoader.addEventListener(Event.COMPLETE, handler);
				gLoader.load(gRequest);
			} catch(e:Error) {
				errhandle(e);
			}
		}

	}
}
