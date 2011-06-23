﻿package com.calebtutty {		import flash.display.MovieClip;	import com.calebtutty.PlatformMC;	import com.calebtutty.BaseBackgroundMC;	import flash.xml.XMLDocument;	import flash.net.URLRequest;	import flash.net.URLLoader;	import flash.events.Event;		public class PlatformContainerMC extends MovieClip {				private var collisionArea:MovieClip;	// a reference to the collisionArea of the player												// to be passed to each platform		private var yAxisOffset:int = 0;		// the y Offset that the Platform container is off												// from the game container		private var baseBackgroundMC:MovieClip = new BaseBackgroundMC();	// this background moves		public var platformArray:Array = new Array();	// this array holds the actual platforms		private var lastPlatformAdded:int = 0;			// this hold the last platform added								public function PlatformContainerMC($playerMC:MovieClip) {			collisionArea = $playerMC.collisionAreaMC; 	// initialise the collisionArea														// as the smaller movieclip inside														// playerMC						addChild(baseBackgroundMC);					// add the moving background						addInitialPlatforms();						// add the initial platforms (platform0.xml)					}				public function reset()		{			for each (var platform in platformArray) // cycle through the array			{				if(this.contains(platform[0]))	// check that platforms are children of the platformContainer				{					removeChild(platform[0]); // remove all platforms				}								}						platformArray.length = 0;						lastPlatformAdded = 0;						yAxisOffset = 0;						addChild(baseBackgroundMC);					// add the moving background back			addInitialPlatforms();						// add the initial platforms (platform0.xml)					}				public function _PlatformContainerMC()		//simulating a destructor		{			removeChild(baseBackgroundMC);			}				public function addInitialPlatforms()		{						var platformXMLString:URLRequest = new URLRequest("assets/xml/platform0.xml");					// load the xml file			var xmlPlatformLoader:URLLoader = new URLLoader(platformXMLString);					// create a URLLoader instance			xmlPlatformLoader.addEventListener(Event.COMPLETE, createPlatforms);				// when completely loaded, call the createPlatforms method					}				public function addPlatforms($yAxisOffset:int = 0)		{			yAxisOffset = $yAxisOffset; // assign the yAxisOffset to the variable passed in						var randomSwitch:int = Math.round(Math.random()*4) + 1;			// generate a random number to indicate which set of platforms to load						trace("Loading platforms from XML file: #" + randomSwitch);			// trace statement to let you know which file loaded						var platformXMLString:URLRequest;			// create the URLRequest instance in the scope of this function						switch (randomSwitch)		// select the corresponding random platform pattern xml file			{				case 1:				platformXMLString = new URLRequest("assets/xml/platform1.xml");				break;				case 2:				platformXMLString = new URLRequest("assets/xml/platform2.xml");				break;				case 3:				platformXMLString = new URLRequest("assets/xml/platform3.xml");				break;				case 4:				platformXMLString = new URLRequest("assets/xml/platform4.xml");				break;				case 5:				platformXMLString = new URLRequest("assets/xml/platform5.xml");				break;			}						//platformXMLString = new URLRequest("assets/xml/platform3.xml");			// For testing purposes, I overrode the variable with one xml file												var xmlPlatformLoader:URLLoader = new URLLoader(platformXMLString);			// create an instance of URLLoader			xmlPlatformLoader.addEventListener(Event.COMPLETE, createPlatforms);			// when loading complete pass to the create Platforms method					}				public function createPlatforms(e:Event)		{						// translate the XML data into an XML list			var platformListXML:XML = XML(e.target.data); // gets the data attribute from the target			var platformsList:XMLList = platformListXML.platform; // uses an XMLList for the for each syntactic sugar						for each (var platformEntry:XML in platformsList)			{				//This array contains the actual PlatformMC() object, x and y co-ordinates and "type"				platformArray.push(new Array(new PlatformMC(), platformEntry.attribute("x"), platformEntry.attribute("y"), platformEntry.attribute("type"), platformEntry.attribute("id"), platformEntry.attribute("hasSpecial"), platformEntry.attribute("hasEnemy")));				// the 'name' of the PlatformMC instance is the actual first entry of the nested array row			}						var i:int = 0; // this variable is to cycle through the platforms			// an issue arose when reusing this code to generate new platforms. The following loop			// will cycle through every platform, meaning that you would have seen platforms that			// you were standing on shift position when this method was recalled with the 'next level'			// and a new XML file.						// Note also: XML positions of platforms in platform1.xml - platform5.xml require negative			// y values, or this would insert platforms below the top of the screen (origin point).						for each (var platform in platformArray) // cycle through the array			{				if(i > lastPlatformAdded)	// check that we aren't repositioning existing platforms				{					platform[0].x = int(platform[1]);	// place platformMC instance on x axis					platform[0].y = int(platform[2]) - int(yAxisOffset);					// place platformMC instance on y axis, with the yAxisOffset					platform[0].platformType = platform[3];						// assign the platformType variable for the instance (calls a getter / setter)					platform[0].id = platform[4];					// assign the id variable for testing purposes										platform[0].createSpecialsMC(platform[5]);	// add any specials (e.g. springs, jetpacks) to the platform					platform[0].addEnemy(platform[6]); // add any EnemyMCs (if hasEnemy > 0)																				//trace(yAxisOffset);	// for testing purposes check the offset is working fine										addChild(platform[0]);	// place platform MC on the stage										lastPlatformAdded++; // increment the count of the lastPlatformAdded				}				i++;	// increment the loop			}						initialisePlatforms(collisionArea);	// initialise the collisionArea in the platforms		}						public function initialisePlatforms($collisionArea:MovieClip) {							for (var i:int = 0; i < this.numChildren;i ++) 	// cycle through the children of this container			{				var child = getChildAt(i);	// get each child				//trace(child.hasOwnProperty("collisionArea")); 				if (child.hasOwnProperty("collisionArea")) 	// if the child has the property of collisionArea				{					child.collisionArea = $collisionArea;	// assign it to the collisionArea MovieClip reference					//trace("x: " + child.x + " y: " + child.y);										if(child.specialsMC != null)					{						child.specialsMC.collisionArea = $collisionArea;					}					if(child.enemyMC != null)					{						child.enemyMC.collisionArea = $collisionArea;					}									}			}		}						public function removeOffScreenPlatforms(platformContainerOffsetOnYAxis:int)		{			// this function removes all the offscreen platforms, so the player can't fall on them,			// and for memory management						//trace("removeOffScreenPlatforms: " + (600 - platformContainerOffsetOnYAxis));						for each (var platform in platformArray)		// cycle through platforms in platformArray			{									//600 is the height of the stage and thus the maximum positive value, 									//then it goes into the negatives				if(platform[0].y > (600 - platformContainerOffsetOnYAxis)) 				{					for (var i:int = 0; i < this.numChildren;i ++) // cycle through all children of this container					{						var child = getChildAt(i);	// get each child						if (child == platform[0]) 	// check to see if the child is the same as the object in the array						{							platform[0].onScreen = false; 	// set the onScreen property as false															// which will use the setter as a destructor															// for any required cleanup																						removeChild(platform[0]);		//remove from stage														//trace("Removed platform that fell below the bottom of the screen");														//technically, for memory management purposes, the actual row in the							// array should be popped.						}					}				}							}		}			}	}