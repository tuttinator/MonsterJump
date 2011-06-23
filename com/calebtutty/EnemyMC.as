package com.calebtutty {
	
	import flash.display.MovieClip;
	
	public class EnemyMC extends MovieClip
	{
		public var collisionArea:MovieClip;	//this is will hold a reference
											//to the playerMC
											//so we can test if there is a
											//collision
													
		
		public function EnemyMC(typeOfEnemy:int = 1)
		{
			switch (typeOfEnemy)		// creation dependent on the XML attribute "hasEnemy"
			{
				case 1:
					gotoAndStop("Enemy1");
				break;
				case 2:
					gotoAndStop("Enemy2");
				break;
				// extendable to more enemies in the future
			}
			
			trace("EnemyMC constructed");
		}
		
		public function collisionTest():Boolean {				// simple collision detection
			if (hitTestObject(collisionArea)) {
				return true;
			}
			else {
				return false;
			}
		}

		
	}
	
}