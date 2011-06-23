﻿package com.calebtutty {	/* Main Game Logic */	import flash.display.MovieClip;	import flash.text.TextField;	import flash.text.TextFormat;	import flash.text.TextFormatAlign;	import flash.text.TextFieldAutoSize;  	import flash.events.*;	import flash.utils.Timer;	import flash.utils.setInterval;	import flash.utils.clearInterval;	import flash.ui.Keyboard;	import flash.display.Stage;	import flash.net.URLRequest;	import flash.media.Sound;	import flash.media.SoundChannel;	import flash.media.SoundTransform;	import com.calebtutty.StaticBackgroundMC;	import com.calebtutty.PlatformContainerMC;	import com.calebtutty.PlayerMC;	import com.calebtutty.GameVars;	import com.greensock.TimelineLite;	import com.greensock.TweenLite;		public class GameContainerMC extends MovieClip {				public var playerMC:PlayerMC;								// player movieclip		public var platformContainerMC:PlatformContainerMC;			// container movieclip holding platforms		private var staticBackgroundMC:MovieClip = new StaticBackgroundMC();	// static (non-moving) background		// initialisation variables		private var nextLevel:Boolean = false;			private var platformContainerOffsetOnYAxis:Number = 0;		private var level:int = 1;		private var theGameHasStarted:Boolean = false;		private var count:int = 4;								// countdown variable (3,2,1 GO)		private var gameOver:Boolean = false;		private var rateOfMovement:int = 1;						// normally 1px per frame																// springs, etc may move things faster				private var lastHitPlatformReference:MovieClip;			// reference to the last platform hit				// textfields and formats		private var countdownTXT:TextField = new TextField();		private var highScoreTXT:TextField = new TextField();		private var scoreTXT:TextField = new TextField();		private var lastGameScoreTXT:TextField = new TextField();		private var gameDefaultFormat:TextFormat = new TextFormat();		private var countdownTextFormat:TextFormat = new TextFormat();				// movieclips used		// button-type elements		private var startGameMC:MovieClip = new StartGameMC();		private var instructionsButtonMC:MovieClip = new InstructionsButtonMC();		private var playAgainMC:MovieClip = new PlayAgainMC();		private var pauseAndPlayButtonMC:MovieClip;		//other movieclip elements		public var pausedBackgroundMC:MovieClip;		private var countdownDisplayMC:MovieClip = new MovieClip();				// timer for countdown		private var gameStartCountdown:Timer = new Timer(1000, 4);				// timer for sound fade out		private var soundFadeOutTimer:Timer = new Timer(100,50);		private var fadeOutIncrement = 0.1;				// sounds, soundchannel objects and         private var channel:SoundChannel = new SoundChannel();		private var sfxChannel:SoundChannel = new SoundChannel();		private var introMusic:Sound = new Sound();		private var loopMusic:Sound = new Sound();		private var jumpingSound:Sound = new Sound();		private var springSound:Sound = new Sound();		private var gameOverSound:Sound = new Sound();		private var soundTransformObject = new SoundTransform(1, 0.0);				public function GameContainerMC() {						// load sounds			introMusic.load(new URLRequest("assets/sound/intro.mp3"));			loopMusic.load(new URLRequest("assets/sound/soundtrack.mp3"));			jumpingSound.load(new URLRequest("assets/sound/pop.mp3"));					gameOverSound.load(new URLRequest("assets/sound/fireworks.mp3"));			springSound.load(new URLRequest("assets/sound/boing.mp3"));									addChild(staticBackgroundMC);		// add the static backgroudn						playerMC = new PlayerMC();			// create the player object			platformContainerMC = new PlatformContainerMC(playerMC); 	// construct the platform container																		// with a reference to the player			addChild(platformContainerMC);	// add to stage			addChild(playerMC);				// add to stage									// Setting up display elements			scoreTXT.y = 15;					// position and style score text field			scoreTXT.x = 250;			scoreTXT.width = 250;			scoreTXT.selectable = false; 			scoreTXT.autoSize = TextFieldAutoSize.LEFT;									gameDefaultFormat.color = 0x444444;   	// Giving the format a hex decimal color code  			gameDefaultFormat.size = 21;  			// Adding some bigger text size  			gameDefaultFormat.font = "Rockwell";	// Font (may need to be embedded)			gameDefaultFormat.align = TextFormatAlign.RIGHT;	//give alignment						scoreTXT.defaultTextFormat = gameDefaultFormat;		// set format as default			scoreTXT.text = "Score: 0";							// initial value			addChild(scoreTXT);					// add to stage																	countdownTextFormat.color = 0x444444;	// Giving the format a hex decimal color code			countdownTextFormat.size = 96;			// make this text huge			countdownTextFormat.font = "Blox (BRK)"; //Font will need to be embedded			countdownTextFormat.align = TextFormatAlign.CENTER;		// center this						countdownTXT.defaultTextFormat = countdownTextFormat;	// give format			countdownTXT.text = "3";			// set initial value			countdownDisplayMC.addChild(countdownTXT);		// add to stage									pausedBackgroundMC = new PausedBackgroundMC();		// create the Paused screen movieclip			pauseAndPlayButtonMC = new PauseButtonMC();		// create pause button			addChild(pauseAndPlayButtonMC);					// add to stage			pauseAndPlayButtonMC.x = GameVars.singletonInstance.stageWidth - 15;	// get the stageWidth from the singleton instance variabels			pauseAndPlayButtonMC.y = 5;						pauseAndPlayButtonMC.addEventListener(MouseEvent.MOUSE_UP, pauseGame);	// add eventlistener for the pause button						resetGame();		// reset the game (initial)						startGameMC.x = -547;		// position startGame button			startGameMC.y = 352;						addChild(startGameMC);		// add to stage						instructionsButtonMC.x = -547;		// position the instructionsButton			instructionsButtonMC.y = 413;						addChild(instructionsButtonMC);		// add to stage						startGameMC.addEventListener(MouseEvent.MOUSE_UP, startGame);	// add eventlistener						// eventlisteners for the instructions panel.			// these functions move the GameContainer around x and y axes			// which change the view port of what you can see ('different screens')						instructionsButtonMC.addEventListener(MouseEvent.MOUSE_UP, viewInstructions);			staticBackgroundMC.backToMainScreenMC.addEventListener(MouseEvent.MOUSE_UP, returnToMainScreen);			staticBackgroundMC.backAndUpToMainScreenMC.addEventListener(MouseEvent.MOUSE_UP, returnToMainScreen);			staticBackgroundMC.nextInstructionsScreenMC.addEventListener(MouseEvent.MOUSE_UP, nextInstructionsScreen);			staticBackgroundMC.previousInstructionsScreenMC.addEventListener(MouseEvent.MOUSE_UP, viewInstructions);						trace("Game container constructed");		}				public function resetGame():void {			playerMC.stopJumping();			// stop jumping			playerMC.x = 200;				// position player			playerMC.y = 400;			platformContainerMC.x = 0;		// position platform container			platformContainerMC.y = 0;			platformContainerOffsetOnYAxis = 0;		// set offset as 0				// reintialise values			count = 4;								level = 1;			nextLevel = false;			theGameHasStarted = false;			gameStartCountdown.reset();			GameVars.singletonInstance.isPaused = false;			gameOver = false;			GameVars.singletonInstance.score = 0;			scoreTXT.text = "Score: " + GameVars.singletonInstance.score.toString();					}				private function newGame(e:MouseEvent)		{			resetGame();			// reset game method of this class			playerMC.reset();		// reset player			platformContainerMC.reset();	// reset platform container			startGame(e);		// start game		}				private function startGame(e:MouseEvent)		{		//	e.target.parent.parent.addStageEventListeners();						addEventListener(Event.ENTER_FRAME, tick);		// add the listener for the ENTER_FRAME function			TweenLite.to(this, 2, {x:0, y:0});			start();	// countdown seems more immediate if you are tweening into it and it's already started		}				private function start()		{			gameStartCountdown.addEventListener(TimerEvent.TIMER, countdownDisplay);	// add eventlistener			gameStartCountdown.addEventListener(TimerEvent.TIMER_COMPLETE, letsGetThisPartyStarted); // let's get this party started, when the countdown is up			gameStartCountdown.start();	// start the countdown						soundTransformObject.volume = 1;	// crank up the sound			channel.soundTransform = soundTransformObject;	// apply the volume change from the soundTransform object						channel = introMusic.play();		// play the introMusic and use the channel object to control it			channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);	// when intro is done let's get the main music loop happening.		}				private function soundCompleteHandler(e:Event)		{			trace("soundCompleteHandler");			channel = loopMusic.play();		// play the loop music			channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);		// when it's complete, play this loop again.				}				private function viewInstructions(e:MouseEvent)		{			TweenLite.to(this, 2, {x:738, y:-600});	// tween movements to new screen		}				private function returnToMainScreen(e:MouseEvent)		{			TweenLite.to(this, 2, {x:738, y:0});	// tween movements to new screen		}				private function nextInstructionsScreen(e:MouseEvent)		{			TweenLite.to(this, 2, {x:386, y:-600});		// tween movements to new screen				}						private function tick(event:Event):void {						if(!gameOver)		// check if the game is over or not			{				detectCollisions();				// 1.) detect collisions				movePlatformContainer();		// 2.) move the platform container				manageGameBoundaries();			// 3.) manage the game boundaries				playerMC.jump();				// 4.) get the player to perform a jump, if conditions are met				playerMC.accelerate();			// 5.) apply gravity / friction to velocity changes												if(theGameHasStarted && !GameVars.singletonInstance.isPaused)	// check that the game has started and the game isn't paused				{					// ================================================================== //					// To add more difficulty, the platformContainer is constantly moving //					// ================================================================== //					platformContainerMC.y = platformContainerMC.y + rateOfMovement;		// add the rateOfMovement					playerMC.y = playerMC.y + rateOfMovement;		// also move player					platformContainerOffsetOnYAxis = platformContainerOffsetOnYAxis + rateOfMovement;	// keep track of the offset										GameVars.singletonInstance.score = Math.round(platformContainerOffsetOnYAxis / 10 );	// score is the offset divided by 10					//trace(GameVars.singletonInstance.score);					scoreTXT.text = "Score: " + GameVars.singletonInstance.score.toString();	// add score to textfield				}										}					}				public function countdownDisplay(e:TimerEvent)		{			addChild(countdownDisplayMC);	// add countdown						countdownTXT.x = -48;			// position countdown textfield			countdownTXT.y = -48;						countdownDisplayMC.x = 200;		// position countdown movieclip			countdownDisplayMC.y = 300;						//trace(countdownTXT.text);						switch(count)			{				case 4:					countdownTXT.text = "#";			// font uses # for 3 in special style				break;				case 3:					countdownTXT.text = "@";			// font uses @ for 2 in special style				break;				case 2:					countdownTXT.text = "!";			// font uses ! for 1 in special style				break;			}						TweenLite.to(countdownDisplayMC, 1, {scaleX:4, scaleY:4, alpha:0, onComplete:cleanupCountdown});			// tween opacity, scale and on complete clean up			trace(count);			count--;	// decrement the count		}				public function letsGetThisPartyStarted(e:TimerEvent)		{			addChild(countdownDisplayMC);		// add countdown display			countdownTXT.text = "GO";			// add the text "GO" for the end of countdown			TweenLite.to(countdownDisplayMC, 1, {scaleX:4, scaleY:4, alpha:0, onComplete:cleanupCountdown});			// tween opacity, scale and on complete clean up			trace("Let's get this party started called");			theGameHasStarted = true; // set variable to move container, etc					}				public function cleanupCountdown()		{			trace("cleanupCountdown()");			countdownDisplayMC.scaleX = 1;	// clean up movieclip containing textfield			countdownDisplayMC.scaleY = 1;			countdownDisplayMC.alpha = 1;			removeChild(countdownDisplayMC);	// remove from stage		}				public function detectCollisions():void {						// On every frame this function is called to cycle through all of the platformMC instances			// which are children of the platformContainerMC						if(lastHitPlatformReference != null)	// if the last detection was not a platform			{							if(!lastHitPlatformReference.collisionTest())	// check it again				{					lastHitPlatformReference = null;	// if not touching THAT platform					trace("not touching a platform");	// the player must have jumped off it				}			}						for (var i:int = 0; i < platformContainerMC.numChildren; i++)			{				// this for loop cycles through the number of children the platformContainerMC has				var child = platformContainerMC.getChildAt(i);												if (child.hasOwnProperty("collisionArea")) 				{					// if the child of the platformContainerMC has a property of collision area then forms this check					if(child.collisionTest() && playerMC.jumpState!="going up" && playerMC.isOffScreen != true && !playerMC.isDead) {												// the condition for landing on a platform is this:							// there is a collision with the child element AND							// the playerMC is not jumping up (as the player can jump through platforms when on the way up) AND							// and the player can't be off the top of the screen. If they are, we don't want them to land							// on unseen platforms above the top of the stage.														// oh, and also it would also be kind of cool if the player isn't dead either...								playerMC.y = child.y - playerMC.height + 5.45 + platformContainerOffsetOnYAxis;								// the playerMC's y position is now the y position of the child								// minus the height of the character								// plus the value 5.45 (which allows for the hairy feet)								// plus the screen offset which comes from 								if(child.platformType == "moveSideways")								{									// if the player is on a moving sideways platform, let's give									// the player a ride									var movingDirection:String;									switch(child.movingDirection)									{										case "right":											playerMC.x = playerMC.x + 2;										break;										case "left":											playerMC.x = playerMC.x - 2;										break;									}								}								//trace(playerMC.y);								//trace(child.y);																//trace("playerMC.jumpState = " + playerMC.jumpState); 																																playerMC.stopJumping();	// stop jumping																//trace(lastHitPlatformReference);																if(child.specialsMC != null)	// if there is a special inside this platform								{									if(child.specialsMC.collisionTest())	//check if the player is touching it									{										trace("collided with special");										child.specialsMC.performSpecialFunctionOn(playerMC); // perform that special's special function										springSound.play();	// play the sound									}									else if (child != lastHitPlatformReference)	// else we must just have hit the platform									{										trace("Hit a platform");										jumpingSound.play();	// jumping									}								}								else if(child.enemyMC != null)	// 								{									if(child.enemyMC.collisionTest())									{										trace("collided with enemy");										playerDeathSequence();	// oh noes. Player died by touching an enemy									}									else if (child != lastHitPlatformReference)									{										trace("Hit a platform");										jumpingSound.play();									}								}								else if (child != lastHitPlatformReference) // put in place so that the jumping sound doesn't play every single frame the player is touching a platform								{									trace("Hit a platform");									jumpingSound.play();								}																lastHitPlatformReference = child; // set the reference to the last platform						}				}			}					}						public function movePlatformContainer():void {						if (playerMC.jumpState == "going up")			{				// if going up, and above half of the stage, move the platformContainer higher 				if (playerMC.y < (GameVars.singletonInstance.stageHeight / 2)) 				{										rateOfMovement = 1 + playerMC.yVelocity; // move the platform container as fast as the player is jumping (also moves player down)				}								if (playerMC.y > (GameVars.singletonInstance.stageHeight / 2))  // else, if under half the stage				{					rateOfMovement = 1;	// reset movement to just one pixel per frame									}											// if above the top of the stage, drop the player down again				if (playerMC.y < 0) 				{					playerMC.y += 10;					platformContainerMC.y += playerMC.yVelocity;					platformContainerOffsetOnYAxis += playerMC.yVelocity;					playerMC.yVelocity = 0;					//trace(platformContainerOffsetOnYAxis);				}						}						if ((platformContainerOffsetOnYAxis / 1000) > level)	// each xml file has 1000 pixels worth of gamespace			{				// for the purposes of this a 'level' is 1000 pixels worth of gamespace between XML files				//trace("Platform container offset: " + (platformContainerOffsetOnYAxis / 1000));				level++;	// increase level				nextLevel = true;	// set the next level boolean to load more platforms				trace("Next level");			}						if (nextLevel == true) {				platformContainerMC.addPlatforms(platformContainerOffsetOnYAxis); // if next level, load more platforms				nextLevel = false;			}						platformContainerMC.removeOffScreenPlatforms(platformContainerOffsetOnYAxis);					}									public function manageGameBoundaries():void {						// check if the player is over the right hand edge game boundary			if (playerMC.x > GameVars.singletonInstance.stageWidth) {	// stageWidth is a singletonInstance variable				trace(playerMC.x + "is greater than GameVars.singletonInstance.stageWidth");				playerMC.x -= GameVars.singletonInstance.stageWidth;			}						// check if the player is over the left hand edge game boundary			if (playerMC.x < 0) {				trace(playerMC.x + "is less than 0");				playerMC.x += GameVars.singletonInstance.stageWidth;			}						// if player is under the bottom of the game boundary, PLAYER IS DEAD			if (playerMC.y > GameVars.singletonInstance.stageHeight) {												playerDeathSequence();								//this.parent.resetGame(); // reset game now handled otherwise			}						// OffScreen variable  			if (playerMC.y < -40) {				playerMC.isOffScreen = true;							}			if (playerMC.y > -40) {				playerMC.isOffScreen = false;			}					}				public function pauseGame(event:MouseEvent) {			if (GameVars.singletonInstance.isPaused) {		// if already paused				pauseAndPlayButtonMC.gotoAndStop("Pause");		// change pause button to 'pause' symbol				GameVars.singletonInstance.isPaused = false;	// unpause the isPaused variable				addChild(playerMC);								// put the player back on the stage				removeChild(pausedBackgroundMC);				// remove the background				trace("Play");			}			else {											// if not already paused				removeChild(pauseAndPlayButtonMC);			// remove the button from the underlying layer				GameVars.singletonInstance.isPaused = true;	// pause				removeChild(playerMC);						// remove the playerMC				addChild(pausedBackgroundMC);				// add the background				addChild(pauseAndPlayButtonMC);				// add the buttons on top of the new layer				pauseAndPlayButtonMC.gotoAndStop("Play");	// go to the 'play' symbol				trace("Pause");			}		}						public function playerDeathSequence():void {		// oh noes. Player died.			if(!playerMC.isDead)							// if not already dead, kill player			{					// remove the loop				channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);				// play game over sound				gameOverSound.play();								platformContainerMC._PlatformContainerMC();			// call the 'destructor'																	// Destructors wouldn't normally																	// require calling in other languages.																	// Not an official destructor																	// and official destructors would have ~																	// not _ as a prefix.																	// Actionscript disallows																	// it, and doesn't use destructors																					highScoreTXT.defaultTextFormat = gameDefaultFormat; // format high score text field				highScoreTXT.x = 211;				highScoreTXT.y = 1477;				highScoreTXT.width = 154;				addChild(highScoreTXT);								// add to stage				lastGameScoreTXT.defaultTextFormat = gameDefaultFormat;	//format lastGameScore textfield				lastGameScoreTXT.x = 211;				lastGameScoreTXT.y = 1517;				lastGameScoreTXT.width = 154;				addChild(lastGameScoreTXT);							// add to stage								// populate the textfields with score values				highScoreTXT.text = GameVars.singletonInstance.highScore.toString();				trace("Highscore: " + GameVars.singletonInstance.highScore.toString());				lastGameScoreTXT.text = GameVars.singletonInstance.score.toString();								// woosh us away to the bottom of the screen				TweenLite.to(this, 1, {x:0, y:-1200});				trace("Player Dead");				playerMC.isDead = true;			// Here the player dies. 												// So long, player - think not of what might have been...												// You will not grow old, as those who are left grow old.												// Your time has come, and you fought valiantly to the end.												// Alas, it was not meant to be.								playAgainMC.x = 211;			// position playAgain button				playAgainMC.y = 1617;								addChild(playAgainMC);			// add playAgain button to the stay.								playAgainMC.addEventListener(MouseEvent.MOUSE_UP,newGame);		// add eventlistener for playAgain button								playerMC.gotoAndPlay("DeathSequence");	// play the DeathSequence														// this involves going to And Playing 														// the Death Stars.														// Death Stars.								trace("on death: " + GameVars.singletonInstance.highScore);				var soundFadeInterval = null;			// set up a null variable for the soundFadeInterval																		// this was much larger, then I discovered the setInterval function								soundFadeInterval = setInterval( function(channelReference) 	// channel is mapped to																				// channelReference in this																				// anonymous function				{					var vol = channelReference.soundTransform.volume;			// vol is a reference					vol -= 0.025;												// decrement the vol variable					if(vol <= 0) {												// keep above 0. What would a negative volume sound like?						if(soundFadeInterval != null) 							// if not null...						{							clearInterval(soundFadeInterval);					// clearInterval						}						soundFadeInterval = null;								// it should now be null						channelReference.stop();								// stop that channel playing						trace("SoundChannel stopped");					} 					else 														// if we are not yet silent already					{						soundTransformObject.volume = vol;						// apply the decrement to the																				// soundTransformObject						channelReference.soundTransform = soundTransformObject;	// apply the sound transformation																				// to the channel by setting the																				// sound transform object to the																				// soundTransform property.																				// Anyone else think this is far																				// too many objects for a simple																				// operation?						trace("Volume: " + channelReference.soundTransform.volume);	// let's trace this just in case					}				}, 50, channel); 	// the setInterval function take the arguments of actual intervals and the 									// argument for that nice neat anonymous function I slipped in there.															}						if(playerMC.y > 1800)				// oh, if you are dead AND that far down the stage			{				gameOver = true;				// the game is so far over you couldn't believe				GameVars.singletonInstance.score = Math.round(platformContainerOffsetOnYAxis / 10 );	// the score is final.				//removeChild(playerMC);							}						//trace("after death: " + GameVars.singletonInstance.highScore); // removed because ghost scoring is no longer an issue. I aint afraid of no ghost.					}			}	}