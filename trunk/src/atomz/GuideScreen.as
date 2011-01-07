package atomz 
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.net.URLRequest;
	
	/**********************************************************************************************
	 * @author Alessandro Febretti
	 */
	public class GuideScreen extends Sprite
	{
		/**********************************************************************************************
		 * Assets
		 */
        [Embed(source="../../assets/GuideScreen.png")]
        public static const bmpBackground: Class;
        [Embed(source="../../assets/GuideStartGameButton.png")]
        public static const bmpStartGameButton: Class;
		
		/******************************************************************************************
		 */
		public function GuideScreen(game: Game) 
		{
			myGame = game;
			myGame.addChild(this);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
			var background: Bitmap = new bmpBackground();
			background.x = 10;
			background.y = 10;
			addChild(background);
			
			myStartButton = new Sprite();
			myStartButton.addChild(new bmpStartGameButton());
			myStartButton.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8, 2)];
			myStartButton.addEventListener(MouseEvent.MOUSE_DOWN, onStartButtonClick);
			
			myStartButton.x = 760 - myStartButton.width;
			myStartButton.y = 600 - myStartButton.height;
			
			addChild(myStartButton);
			
		}
		
		/******************************************************************************************
		 */
		private function onFrame(e: Event): void 
		{
			myFrameCount++;
			myStartButton.alpha = Math.abs(Math.sin(myFrameCount / 25));
		}
		
		/******************************************************************************************
		 */
		private function onStartButtonClick(e: MouseEvent): void 
		{
			myGame.removeChild(this);
			
			myStartButton.removeEventListener(MouseEvent.MOUSE_DOWN, onStartButtonClick);
			removeEventListener(Event.ENTER_FRAME, onFrame);
			
			myGame.enterState(Game.STATE_GAME);
		}
		
		/******************************************************************************************
		 */
		private var myStartButton: Sprite;
		private var myGame: Game;
		private var myFrameCount: int;
	}
}