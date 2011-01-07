package atomz 
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.text.*;
	
	/**********************************************************************************************
	 * @author Alessandro Febretti
	 */
	public class PointsEffect extends Sprite
	{
		/**********************************************************************************************
		 */
		public function PointsEffect(game: Game, link: Link, pts: int, comboValue: int) 
		{
			myGame = game;
			myLink = link;
			myGame.addChild(this);
			addEventListener(Event.ENTER_FRAME, onFrame);
			
			
			filters = [new DropShadowFilter(0, 0, 0, 1, 16, 16)];
			
			// Setup text
            myText = new TextField();
			var fmt: TextFormat = new TextFormat();
			fmt.font = "DefaultFont";
            fmt.size = 20;
			fmt.color = 0xffffff;
			myText.defaultTextFormat = fmt;
			myText.selectable = false;
			myText.antiAliasType = AntiAliasType.ADVANCED;
			myText.thickness = 120;
			myText.embedFonts = true;
			myText.width = 500;
			
			myText.x = (link.atom1.x + link.atom2.x) / 2;
			myText.y = (link.atom1.y + link.atom2.y) / 2;
			addChild(myText);
			
			var text: String = "+" + pts;
			if (comboValue > 1)
			{
				text += " <font color=\"#FFFF55\">" + comboValue + "X Combo!</font>";
			}
			myText.htmlText = text;
			
			onFrame(null);
		}
		
		/**********************************************************************************************
		 */
		private function onFrame(e: Event): void 
		{
			myFrameCount++;
			var w: Number = Number(myFrameCount / 25);
			alpha = 1 - w;
			y = (y * 2 + 16) / 3;
			if (w >= 1)
			{
				removeEventListener(Event.ENTER_FRAME, onFrame);
				myGame.removeChild(this);
			}
		}
		
		/**********************************************************************************************
		 * Fields
		 */
        private var myText: TextField;
		private var myGame: Game;
		private var myLink: Link;
		private var myFrameCount: int;
	}
}