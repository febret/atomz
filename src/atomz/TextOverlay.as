package atomz 
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.text.*;
	
	/**********************************************************************************************
	 * @author Alessandro Febretti
	 */
	public class TextOverlay extends Sprite
	{
		/******************************************************************************************
		 * Constants.
		 */
		public static const STATE_ZOOM: String = "zoom";
		public static const STATE_FADE: String = "fade";
		 
		/******************************************************************************************
		 */
		public function TextOverlay(game: Game) 
		{
			myIsRemoved = false;
			myGame = game;
			myGame.addChild(this);
			addEventListener(Event.ENTER_FRAME, onFrame);
			
			myState = STATE_FADE;
			myTween = 0;
			alpha = 0;
			
			// Initialize debug text.
			var fmt:TextFormat = new TextFormat();
			fmt.font = "DefaultFont"
            fmt.size = 50;
			fmt.color = 0xffffff;
			
            myText = new TextField();
			myText.antiAliasType = AntiAliasType.ADVANCED;
			myText.defaultTextFormat = fmt;
			myText.autoSize = TextFieldAutoSize.CENTER;
			myText.selectable = false;
			myText.thickness = 100;
			myText.embedFonts = true;
			myText.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8, 2)];
			addChild(myText);
		}
		
		/******************************************************************************************
		 */
		public function remove(): void
		{
			// Avoid double removal.
			if (!myIsRemoved)
			{
				myIsRemoved = true;
				myGame.removeChild(this);
				removeEventListener(Event.ENTER_FRAME, onFrame);
			}
		}
		
		/******************************************************************************************
		 */
		public function set text(value: String): void
		{
			myText.text = value;
		}
		
		/******************************************************************************************
		 */
		public function get text(): String
		{
			return myText.text;
		}
		
		/**********************************************************************************************
		 */
		private function onFrame(e: Event): void 
		{
			var w: Number = 0;
			if (myState == STATE_FADE)
			{
				myTween++;
				w = myTween / Game.FPS * 2;
				alpha = w;
				myText.x = Math.pow(w, 0.8) * (380 - myText.width / 2);
				myText.y = 300 - myText.height / 2;
				if (w >= 1)
				{
					myTween = 0;
					myState = STATE_ZOOM;
				}
			}
			else if (myState == STATE_ZOOM)
			{
				myTween++;
				w = myTween / Game.FPS;
				alpha = 1 - w;
				myText.x = (380 - myText.width / 2) + Math.pow(w, 4) * 380;
				myText.y = 300 - myText.height / 2;
				if (w >= 1)
				{
					remove();
				}
			}
		}
		
		/******************************************************************************************
		 * Fields
		 */
		private var myGame: Game;
		private var myState: String;
		private var myTween: Number;
		private var myIsRemoved: Boolean;
        private var myText: TextField;
	}
	
}