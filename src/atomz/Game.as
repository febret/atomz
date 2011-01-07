package atomz
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.text.*;
	import flash.net.*;
	import flash.media.*;
	import mx.controls.Button;
	import mx.core.*;
	import mochi.as3.*;

	/**********************************************************************************************
	 * @author Alessandro Febretti
	 */
	public dynamic class Game extends UIComponent
	{
		/******************************************************************************************
		 * Mochi Ads stuff.
		 */
		public var _mochiads_game_id:String = "1deff831fdf18efc";
		
		/******************************************************************************************
		 * Game states
		 */
		public static const FPS: int = 25;
		public static const STATE_MAIN_SCREEN: String = "main";
		public static const STATE_GUIDE: String  = "guide";
		public static const STATE_GAME: String  = "game";
		public static const STATE_GAME_OVER: String  = "gameOver";
		 
		/******************************************************************************************
		 * Game constants
		 */
		public static const LINK_DISTANCE: Number = 120;
		public static const FORCE_DISTANCE: Number = 100;
		public static const GOAL_HEIGHT: Number = 30;
		public static const ATOM_SIZE: Number = 64;

		/******************************************************************************************
		 * Other constants
		 */
		public static const UPDATE_SCORE_URL: String = "http://pan/db/update_score.php";
		public static const GET_SCORE_URL: String = "http://pan/db/get_score.php";
		 
		/******************************************************************************************
		 * Sounds
		 */
        [Embed(source="../../assets/LinkOk.mp3")]
        public static const sndLinkOk: Class;
        [Embed(source="../../assets/Start.mp3")]
        public static const sndStart: Class;
        [Embed(source="../../assets/Error.mp3")]
        public static const sndError: Class;
        [Embed(source="../../assets/GameOver.mp3")]
        public static const sndGameOver: Class;
		
		/******************************************************************************************
		 */
		static public function formatPoints(pts: String): String 
		{
			var result: String = "";
			for (var i: int = pts.length - 1; i >= 0; i--)
			{
				if ((pts.length - i) % 3 == 1 && (pts.length - i) != 1)
				{
					result = "," + result;
				}
				result = pts.charAt(i) + result;
			}
			return result;
		}
		
		/******************************************************************************************
		 */
		public function Game() 
		{
			// Initialize debug text.
			var fmt:TextFormat = new TextFormat();
			fmt.font = "DefaultFont";
            fmt.size = 24;
			fmt.color = 0xffffff;
			
			myBackground = new Shape();
			myBackground.graphics.beginFill(0x333333);
			myBackground.graphics.drawRoundRect(0, 0, 760, 600, 16, 16);
			myBackground.graphics.endFill();
			addChildAt(myBackground, 0);
			
            myPointsText = new TextField();
			myPointsText.defaultTextFormat = fmt;
			myPointsText.selectable = false;
			myPointsText.width = 500;
			myPointsText.x = 100;
			myPointsText.embedFonts = true;
			myPointsText.antiAliasType = AntiAliasType.ADVANCED;
			myPointsText.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8, 2)];
			addChild(myPointsText);
			
            myLifeText = new TextField();
			myLifeText.defaultTextFormat = fmt;
			myLifeText.selectable = false;
			myLifeText.width = 500;
			myLifeText.x = 500;
			myLifeText.embedFonts = true;
			myLifeText.antiAliasType = AntiAliasType.ADVANCED;
			myLifeText.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8, 2)];
			addChild(myLifeText);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		/******************************************************************************************
		 */
		public function init(): void 
		{
			MochiServices.connect("1deff831fdf18efc", this);
			enterState(Game.STATE_MAIN_SCREEN);
		}

		/******************************************************************************************
		 * Manager the main state machine transitions.
		 */
		public function enterState(state: String): void 
		{
			trace("Entering state " + state);
			if (state == STATE_MAIN_SCREEN)
			{
				var mainScreen: MainScreen = new MainScreen(this);
				myState = STATE_MAIN_SCREEN;
			}
			else if (state == STATE_GUIDE)
			{
				var guideScreen: GuideScreen = new GuideScreen(this);
				myState = STATE_GUIDE;
			}
			else if (state == STATE_GAME_OVER)
			{
				myPointsText.visible = false;
				myLifeText.visible = false;
				// Remove old atoms and links.
				var childrenTBRemoved: Array = new Array();
				for (var i: int = 0; i < numChildren; i++)
				{
					var child: DisplayObject = getChildAt(i);
					if (child is Link || child is Atom)
					{
						childrenTBRemoved.push(child);
					}
				}
				for (var j: int = 0; j < childrenTBRemoved.length; j++)
				{
					removeChild(childrenTBRemoved[j]);
				}
				//myOverlay.remove();
				var gameOverScreen: GameOverScreen = new GameOverScreen(this);
				myState = STATE_GAME_OVER;
				
				var t: TextOverlay = new TextOverlay(this);
				t.text = "GAME OVER";
			}
			else if (state == STATE_GAME)
			{
				myPointsText.visible = true;
				myLifeText.visible = true;
				t = new TextOverlay(this);
				t.text = "READY?";
				// Set initial life level.
				myFrameCounter = 0;
				myLife = 100;
				myPoints = 0;
				// Speed of atoms (by frame)
				myAtomSpeed = 1;
				myAtomAddInterval = 50;
				
				myPreviewLink = new Link(this);
				//myOverlay = new GameOverlay(this);
				myAtoms = new Array();
				myLinks = new Array();
				updateGoal();
				updatePoints();
				
				myState = STATE_GAME;
			}
		}
		
		/******************************************************************************************
		 */
		public function print(msg: String): void 
		{
			myPointsText.text = msg;
		}
		
		/******************************************************************************************
		 */
		public function sendScoreUpdate(): void 
		{
			// Submit score to mochi leaderboard.
			var o:Object = { n: [9, 3, 6, 0, 2, 10, 2, 14, 0, 9, 8, 4, 8, 14, 7, 10], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
			var boardID:String = o.f(0,"");
			MochiScores.showLeaderboard( { boardID: boardID, score: myPoints, res: "740x600", hideDoneButton: true  } ); 
		}
		
		/******************************************************************************************
		 */
		public function handleAtomDragging(atom: Atom): void 
		{
			var minDist: Number = LINK_DISTANCE;
			myPreviewLink.clearLink();
			for (var i: int = 0; i < myAtoms.length; i++)
			{
				var target: Atom = myAtoms[i] as Atom;
				if (target != atom)
				{
					var dist: Number = atom.distanceTo(target) ;
					if (dist < minDist &&
						atom.canLinkTo(target))
					{
						minDist = dist;
						myPreviewLink.setLink(atom, target, Link.LINK_PREVIEW);
					}
				}
			}
		}
		
		/******************************************************************************************
		 */
		public function confirmLink(): void 
		{
			// If there is a valid link stored in the preview link object, confirm it.
			if (myPreviewLink.atom1 != null)
			{
				var a1: Atom = myPreviewLink.atom1;
				var a2: Atom = myPreviewLink.atom2;
				
				var link: Link = new Link(this);
				link.setLink(a1, a2, Link.LINK_FIXED);
				myLinks.push(link);
				if (a1.color == a2.color && !a2.colorLocked)
				{
					a1.shapeLocked = false;
					a1.colorLocked = true;
					a2.shapeLocked = false;
					a2.colorLocked = true;
				}
				else if (a1.shape == a2.shape)
				{
					a1.shapeLocked = true;
					a1.colorLocked = false;
					a2.shapeLocked = true;
					a2.colorLocked = false;
				}
				else
				{
					print("Trying to create a wrong link, shold never get here..");
				}
				
				var comboLevel: int = 0;
				for (var k: int = 0; k < myLinks.length; k++)
				{
					if (myLinks[k].atom1 ==  a1 || myLinks[k].atom2 == a2)
					{
						comboLevel++;
					}
				}
				var pts: int = 50 + 100 * comboLevel;
				myPoints += pts;
				updatePoints();
				new PointsEffect(this, link, pts, comboLevel);
				
				// Play link sound.
				var snd: Sound = new sndLinkOk();
				snd.play();
			}
			myPreviewLink.clearLink();
		}
		
		/******************************************************************************************
		 */
		public function get isGameOver(): Boolean
		{
			return myIsGameOver;
		}
		
		/******************************************************************************************
		 */
		private function createAtom(): void 
		{
			var color: String;
			var shape: String;
			switch(int(Math.random() * 4))
			{
			case 0:
				color = Atom.COLOR_BLUE;
				break;
			case 1:
				color = Atom.COLOR_RED;
				break;
			case 2:
				color = Atom.COLOR_GREEN;
				break;
			case 3:
				color = Atom.COLOR_YELLOW;
				break;
			}
			switch(int(Math.random() * 4))
			{
			case 0:
				shape = Atom.SHAPE_1;
				break;
			case 1:
				shape = Atom.SHAPE_2;
				break;
			case 2:
				shape = Atom.SHAPE_3;
				break;
			case 3:
				shape = Atom.SHAPE_4;
				break;
			}
			var atom: Atom = new Atom(this, color, shape);
			//atom.x = 700;
			atom.x = Math.random() * 700;
			atom.y = 520;
			myAtoms.push(atom);
		}
		
		/******************************************************************************************
		 */
		private function updateGoal(): void 
		{
			myLifeText.text = "Life: " + myLife + "%";
		}
		
		/******************************************************************************************
		 */
		private function updatePoints(): void 
		{
			myPointsText.htmlText = formatPoints(myPoints.toString());
		}
		
		/******************************************************************************************
		 */
		private function handleGoalHit(): void 
		{
			var atomsTbRemoved: Array = new Array();
			var linksTbRemoved: Array = new Array();
			var i: int;
			for (i = 0; i < myAtoms.length; i++)
			{
				var atom: Atom = myAtoms[i];
				if (!atom.isDragging && atom.y <= 0)
				{
					atom.remove();
					atomsTbRemoved.push(atom);
					// This atom hit the goal. See if it is linked
					var linked: Boolean = false;
					var j: int;
					for (j = 0; j < myLinks.length; j++)
					{
						var link: Link = myLinks[j];
						if (link.atom1 == atom || link.atom2 == atom)
						{
							// At least one link exists, this atom will count as points.
							linked = true;
							// if both link atoms have been removed, destroy the link.
							if (link.atom1.isRemoved && link.atom2.isRemoved)
							{
								linksTbRemoved.push(link);
							}
						}
					}
					if (!linked)
					{
						myLife -= 5;
						if (myLife <= 0)
						{
							var snd: Sound = new sndGameOver();
							snd.play();
							//myIsGameOver = true;
							enterState(STATE_GAME_OVER);
						}
						else
						{
							var snde: Sound = new sndError();
							snde.play();
							updateGoal();
						}
					}
				}
			}
			// Remove unused atoms
			for (i = 0; i < atomsTbRemoved.length; i++)
			{
				var aidx: int = myAtoms.indexOf(atomsTbRemoved[i]);
				myAtoms.splice(aidx, 1);
			}
			// Remove unused links
			for (i = 0; i < linksTbRemoved.length; i++)
			{
				var lidx: int = myLinks.indexOf(linksTbRemoved[i]);
				linksTbRemoved[i].remove();
				myLinks.splice(lidx, 1);
			}
		}
		
		/******************************************************************************************
		 */
		private function handleLinkPhysics(): void 
		{
			var i: int;
			for (i = 0; i < myLinks.length; i++)
			{
				var link: Link = myLinks[i];
				var l: Number = link.length;
				var vx: Number = link.dx / l;
				var vy: Number = link.dy / l;
				var w: Number = (l - FORCE_DISTANCE) / 20;
				link.atom1.setForce(- vx * w, - vy * w);
				link.atom2.setForce(vx * w, vy * w);
			}
		}
		
		/******************************************************************************************
		 */
		private function handleAtomCollisions(): void 
		{
			var i: int;
			for (i = 0; i < myAtoms.length; i++)
			{
				var atom1: Atom = myAtoms[i];
				var j: int;
				for (j = i + 1; j < myAtoms.length; j++)
				{
					var atom2: Atom = myAtoms[j];
					var dx: Number = atom1.x - atom2.x;
					var dy: Number = atom1.y - atom2.y;
					var d: Number = Math.sqrt(dx * dx + dy * dy);
					if (d < ATOM_SIZE)
					{
						var vx: Number = dx / d;
						var vy: Number = dy / d;
						var w: Number = (d - ATOM_SIZE);
						atom1.setForce(- vx * w, - vy * w);
						atom2.setForce(vx * w, vy * w);
					}
				}
			}
		}
		
		/******************************************************************************************
		 */
		private function onFrame(e: Event): void 
		{
			if (myState == STATE_GAME)
			{
				if (myDraggingAtom != null)
				{
					myDraggingAtom.x = mouseX - ATOM_SIZE / 2;
					myDraggingAtom.y = mouseY - ATOM_SIZE / 2;
				}
				myFrameCounter++;
				if (myFrameCounter == 25)
				{
					var snds: Sound = new sndStart();
					snds.play();
					var t: TextOverlay = new TextOverlay(this);
					t.text = "GO!!";
				}
				if (myFrameCounter % myAtomAddInterval == 0)
				{
					createAtom();
				}
				if (myFrameCounter % (25 * 5) == 0)
				{
					myAtomAddInterval--;
					
					var tmp: int = myAtomSpeed;
					myAtomSpeed = (50 - myAtomAddInterval) / 10 + 1;
					
					if (tmp != myAtomSpeed)
					{
						var snd: Sound = new sndStart();
						snd.play();
						t = new TextOverlay(this);
						t.text = "LEVEL " + myAtomSpeed;
					}
				}
				//Update atom and link positions
				var i: int;
				for (i = 0; i < myAtoms.length; i++)
				{
					var atom: Atom = myAtoms[i];
					if (!atom.isDragging)
					{
						atom.y -= myAtomSpeed;
					}
					if (atom.y < Game.ATOM_SIZE)
					{
						atom.alpha = atom.y / Game.ATOM_SIZE;
					}
				}
				for (i = 0; i < myLinks.length; i++)
				{
					var link: Link = myLinks[i];
					if (link.atom1.y < Game.ATOM_SIZE || link.atom2.y < Game.ATOM_SIZE)
					{
						link.alpha = (link.atom1.y + link.atom2.y)  / (Game.ATOM_SIZE * 2);
					}
				}
				handleGoalHit();
				handleLinkPhysics();
				handleAtomCollisions();
			}
			
			// Be sure that text is over everything else.
			addChild(myPointsText);
			addChild(myLifeText);
		}
		
		/**********************************************************************************************
		 */
		private function onMouseUp(e: MouseEvent): void 
		{
			try
			{
				if (myDraggingAtom != null)
				{
					myDraggingAtom.endDragging();
					myDraggingAtom = null;
					confirmLink();
				}
			}
			catch (e: Error)
			{
				print("ERROR");
			}
		}
		
		/**********************************************************************************************
		 */
		private function onMouseDown(e: MouseEvent): void 
		{
			if (myState == STATE_GAME)
			{
				for (var i: int = 0; i < myAtoms.length; i++)
				{
					var atom: Atom = myAtoms[i];
					if (Math.abs(atom.x - mouseX) < ATOM_SIZE && Math.abs(atom.y - mouseY) < ATOM_SIZE)
					{
						if (atom.y > Game.GOAL_HEIGHT && !atom.colorLocked && !atom.shapeLocked)
						{
							atom.beginDragging();
							myDraggingAtom = atom;
							return;
						}
					}
				}
			}
		}
		
		/**********************************************************************************************
		 */
		private function onMouseMove(e: MouseEvent): void 
		{
			if (myDraggingAtom != null)
			{
				myDraggingAtom.x = mouseX - ATOM_SIZE / 2;
				myDraggingAtom.y = mouseY - ATOM_SIZE / 2;
				handleAtomDragging(myDraggingAtom);
			}
		}
		
		/******************************************************************************************
		 * Fields
		 */
        private var myOverlay: GameOverlay;
        private var myPointsText: TextField;
        private var myLifeText: TextField;
		private var myPreviewLink: Link;
		private var myDraggingAtom: Atom;
		private var myAtoms: Array;
		private var myLinks: Array;
		private var myFrameCounter: int;
		private var myPoints: int;
		private var myLife: int;
		//private var myStreak: int;
		private var myIsGameOver: Boolean;
		private var myState: String;
		// Game difficulty parameters
		private var myAtomSpeed: int;
		private var myAtomAddInterval: int;
		private var myBackground: Shape;
	}
}