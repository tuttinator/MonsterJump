﻿package {		import flash.display.MovieClip;	import PlatformMC;		public class PlatformContainerMC extends MovieClip {				public var platformArray:Array = new Array(30);		// The PlatformContainer is divided up into blocks		// of 30 per row and 8 per column				public function PlatformContainerMC() {						for (var i:int = 0; i < 30; i++)			{				// The platformArray of rows has 8 columns				platformArray[i] = new Array(8);				for (var j:int = 0; j < 8; j++)				{					platformArray[i][j] = new PlatformMC();					// each block holds an anonymous instance of a PlatformMC					platformArray[i][j].x = j * 50;					platformArray[i][j].y = i * 20;					// decide whether or not to add to the stage					if (Math.random() >= 0.75) {						addChild(platformArray[i][j]);					}				}			}											}				public function initialisePlatforms($collisionArea) {							for (var i:int = 0; i < this.numChildren;i ++) 			{				var child = getChildAt(i);				//trace(child.hasOwnProperty("collisionArea")); 				if (child.hasOwnProperty("collisionArea")) 				{					child.collisionArea = $collisionArea;				}			}		}			}	}