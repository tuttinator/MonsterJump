package com.calebtutty
{
    public class GameVars
    {
		// convention used: underscore for private variables accessed through getters and setters
        private static var _singletonInstance:GameVars = new GameVars();
		public const stageWidth:int = 400;
		public const stageHeight:int = 600;
		
		private var _score:int = 0;
		private var _highScore:int = 0;
		private var _isPaused:Boolean = false;

        public function GameVars()
        {
            if (_singletonInstance != null)
            {
                throw new Error("Singleton class of GameVars can only be accessed through GameVars.instance");
            }
        }

        public static function get singletonInstance():GameVars
        {
            return _singletonInstance;
        }

		public function get score():int
		{
			return _score;
		}
		
		public function set score(value:int):void
		{
			_score = value;
			if(_score > _highScore)
			{
				highScore = _score;
			}
		}
		
		public function get highScore():int
		{
			return _highScore;
		}
		
		public function set highScore(value):void
		{
			_highScore = value;
		}
		
		public function get isPaused():Boolean
		{
			return _isPaused;
		}
		
		public function set isPaused(value:Boolean)
		{
			_isPaused = value;
		}
		

    }
}