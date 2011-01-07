package atomz 
{
	import flash.display.*;
	import flash.events.*;
	
	/**********************************************************************************************
	 * @author Alessandro Febretti
	 */
	public class Atom extends Sprite
	{
		/**********************************************************************************************
		 * Assets
		 */
        [Embed(source="../../assets/Base.png")]
        public static const bmpBase: Class;
		
        [Embed(source="../../assets/GrayGlow.png")]
        public static const bmpGrayGlow: Class;
        [Embed(source="../../assets/BlueGlow.png")]
        public static const bmpBlueGlow: Class;
        [Embed(source="../../assets/RedGlow.png")]
        public static const bmpRedGlow: Class;
        [Embed(source="../../assets/GreenGlow.png")]
        public static const bmpGreenGlow: Class;
        [Embed(source="../../assets/YellowGlow.png")]
        public static const bmpYellowGlow: Class;
		
        [Embed(source="../../assets/Blue.png")]
        public static const bmpBlue: Class;
        [Embed(source="../../assets/Red.png")]
        public static const bmpRed: Class;
        [Embed(source="../../assets/Green.png")]
        public static const bmpGreen: Class;
        [Embed(source="../../assets/Yellow.png")]
        public static const bmpYellow: Class;
		
        [Embed(source="../../assets/BlueS1.png")]
        public static const bmpBlueS1: Class;
        [Embed(source="../../assets/RedS1.png")]
        public static const bmpRedS1: Class;
        [Embed(source="../../assets/GreenS1.png")]
        public static const bmpGreenS1: Class;
        [Embed(source="../../assets/YellowS1.png")]
        public static const bmpYellowS1: Class;
		
        [Embed(source="../../assets/BlueS2.png")]
        public static const bmpBlueS2: Class;
        [Embed(source="../../assets/RedS2.png")]
        public static const bmpRedS2: Class;
        [Embed(source="../../assets/GreenS2.png")]
        public static const bmpGreenS2: Class;
        [Embed(source="../../assets/YellowS2.png")]
        public static const bmpYellowS2: Class;
		
		[Embed(source="../../assets/BlueS3.png")]
        public static const bmpBlueS3: Class;
        [Embed(source="../../assets/RedS3.png")]
        public static const bmpRedS3: Class;
        [Embed(source="../../assets/GreenS3.png")]
        public static const bmpGreenS3: Class;
        [Embed(source="../../assets/YellowS3.png")]
        public static const bmpYellowS3: Class;
		
        [Embed(source="../../assets/BlueS4.png")]
        public static const bmpBlueS4: Class;
        [Embed(source="../../assets/RedS4.png")]
        public static const bmpRedS4: Class;
        [Embed(source="../../assets/GreenS4.png")]
        public static const bmpGreenS4: Class;
        [Embed(source="../../assets/YellowS4.png")]
        public static const bmpYellowS4: Class;
		
        [Embed(source="../../assets/S1.png")]
        public static const bmpS1: Class;
        [Embed(source="../../assets/S2.png")]
        public static const bmpS2: Class;
        [Embed(source="../../assets/S3.png")]
        public static const bmpS3: Class;
        [Embed(source="../../assets/S4.png")]
        public static const bmpS4: Class;
		
		/**********************************************************************************************
		 * Color constants
		 */
		public static const COLOR_BLUE: String = "Blue";
		public static const COLOR_GREEN: String = "Green";
		public static const COLOR_RED: String = "Red";
		public static const COLOR_YELLOW: String = "Yellow";

		/**********************************************************************************************
		 * Shape constants
		 */
		public static const SHAPE_1: String = "S1";
		public static const SHAPE_2: String = "S2";
		public static const SHAPE_3: String = "S3";
		public static const SHAPE_4: String = "S4";
		
		/**********************************************************************************************
		 */
		public function Atom(game: Game, color: String, shape: String) 
		{
			myGame = game;
			myAtomBitmap = null;
			myColor = color;
			myShape = shape;
			myColorLocked = false;
			myShapeLocked = false;
			updateAppearance();
			
			myGame.addChild(this);
			
			alpha = 0;
			mySX = 0;
			mySY = 0;
			
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		/**********************************************************************************************
		 */
		public function remove(): void 
		{
			myIsRemoved = true;
			myGame.removeChild(this);
		}
		
		/**********************************************************************************************
		 */
		public function updateAppearance(): void 
		{
			var bmpName: String;
			var glowName: String = "";
			if (myColorLocked)
			{
				bmpName = "bmp" + myShape;
				glowName = "bmpGrayGlow";
			}
			else if(myShapeLocked)
			{
				bmpName = "bmpBase";
				glowName = "bmp" + myColor + "Glow";
			}
			else
			{
				//bmpName = "bmp" + myColor + myShape;
				bmpName = "bmp" + myShape;
				glowName = "bmp" + myColor + "Glow";
			}
			if (myAtomBitmap != null)
			{
				removeChild(myAtomBitmap);
			}
			if(myGlowBitmap != null)
			{
				removeChild(myGlowBitmap);
				myGlowBitmap = null;
			}
			myAtomBitmap = new Atom[bmpName]();
			addChild(myAtomBitmap);
			if (glowName != "")
			{
				myGlowBitmap = new Atom[glowName]();
				myGlowBitmap.blendMode = BlendMode.ADD;
				addChild(myGlowBitmap);
			}
		}
		
		/**********************************************************************************************
		 */
		public function canLinkTo(target: Atom): Boolean
		{
			if (target.colorLocked)
			{
				if (myShape == target.shape) return true;
			}
			else if (target.shapeLocked)
			{
				if (myColor == target.color) return true;
			}
			else 
			{
				if (myColor == target.color ||
					myShape == target.shape) return true;
			}
			return false;
		}
		
		/**********************************************************************************************
		 */
		public function distanceTo(target: Atom): Number
		{
			var dx: int = x - target.x;
			var dy: int = y - target.y;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		/**********************************************************************************************
		 */
		public function endDragging(): void 
		{
			//stopDrag();
			myIsDragging = false;
			mySX = 0;
			mySY = 0;
		}
		
		/**********************************************************************************************
		 */
		public function beginDragging(): void 
		{
			//startDrag();
			myIsDragging = true;
		}
		
		/**********************************************************************************************
		 */
		public function setForce(sx: Number, sy: Number): void 
		{
			mySX += sx;
			mySY += sy;
		}
		
		/**********************************************************************************************
		 */
		public function get isDragging(): Boolean
		{
			return myIsDragging;
		}
		
		/**********************************************************************************************
		 */
		public function get isRemoved(): Boolean
		{
			return myIsRemoved;
		}
		
		/**********************************************************************************************
		 */
		public function get shape(): String
		{
			return myShape;
		}
		
		/**********************************************************************************************
		 */
		public function get color(): String
		{
			return myColor;
		}
		
		/**********************************************************************************************
		 */
		public function get colorLocked(): Boolean 
		{
			return myColorLocked;
		}
		public function set colorLocked(value: Boolean): void
		{
			myColorLocked = value;
			myAppearanceSwitch = myFrameCount;
			myLastX = x;
		}
		 
		/**********************************************************************************************
		 */
		public function get shapeLocked(): Boolean 
		{
			return myShapeLocked;
		}
		public function set shapeLocked(value: Boolean): void
		{
			myShapeLocked = value;
			myAppearanceSwitch = myFrameCount;
			myLastX = x;
		}
		
		/**********************************************************************************************
		 */
		private function onFrame(e: Event): void 
		{
			myFrameCount++;
			if (myAppearanceSwitch != 0)
			{
				if (myAppearanceSwitch > 0)
				{
					var w: Number = Number((myFrameCount - myAppearanceSwitch) / 3);
					scaleX = 1 - w;
					x = myLastX + w * Game.ATOM_SIZE / 2;
					if (w >= 1)
					{
						updateAppearance();
						myAppearanceSwitch = -myFrameCount;
					}
				}
				else
				{
					w = Number((myFrameCount + myAppearanceSwitch) / 3);
					scaleX = w;
					x = myLastX - w * Game.ATOM_SIZE / 2 + Game.ATOM_SIZE / 2;
					if (w >= 1)
					{
						myAppearanceSwitch = 0;
						// Play the link effect.
						var linkFx: LinkEffect;
						linkFx = new LinkEffect(myGame, this);
					}
				}
			}
			if (alpha < 1)
			{
				alpha += 0.1;
			}
			if (!myIsDragging)
			{
				x += mySX;
				y += mySY;
				mySX = 0;
				mySY = 0;
			}
			
			// Update glow
			if (myGlowBitmap != null)
			{
				var scale: Number = 1.2 + (Math.random() * 0.1);
				myGlowBitmap.alpha = 0.6 + Math.random() * 0.4;
				myGlowBitmap.scaleX = scale;
				myGlowBitmap.scaleY = scale;
				var pos: int = - Game.ATOM_SIZE / 2 * scale + Game.ATOM_SIZE / 2;
				myGlowBitmap.x = pos;
				myGlowBitmap.y = pos;
			}
		}
		
		/**********************************************************************************************
		 * Fields
		 */
		private var myGame: Game;
		private var myFrameCount: int;
		private var myAtomBitmap: Bitmap;
		private var myGlowBitmap: Bitmap;
		private var myColor: String;
		private var myShape: String;
		private var myColorLocked: Boolean;
		private var myShapeLocked: Boolean;
		private var myIsDragging: Boolean;
		// true if the atom has been removed (even if it is still visible i.e. because its playing an 
		// end animation).
		private var myIsRemoved: Boolean; 
		// Appearance animation
		private var myAppearanceSwitch: int;
		private var myLastX: int;
		private var myLastY: int;
		// Physics
		private var mySX: Number;
		public var mySY: Number;
	}
	
}