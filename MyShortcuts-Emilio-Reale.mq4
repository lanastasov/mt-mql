#property copyright "Emilio Stefano Reale FxTrading"

#import "IdleLib.dll"
   int GetLastKeyWP();
   int GetLastMouseWP();
   int IdleLibInit();
   int IdleLibUnInit();
   string GetActiveWndName();
#import

#include <stdlib.mqh>

extern color      default_color           = Blue;
extern string     droppedLineName         = "LineDropped";
extern string     expansionLineName       = "_exp";
extern string     linePointsName          = "_lp";
extern bool       deleteLinePoints        = true;
extern bool       exitAfterLinePoints     = true;
extern string     exclusionPrefix         = "_";
extern bool       deleteExpansionLine     = true;
extern bool       exitAfterExpansion      = true;
extern bool       clearCommentsOnExit     = true;
extern color      expansionLevelColor     = Blue;
extern color      expansionColor          = Red;
extern int        expansionLevelStyle     = STYLE_DOT;
extern int        expansionLineWidth      = 2;
extern int        expansionLineStyle      = STYLE_SOLID;
extern color      expansionLineColor      = Red;

double expLevels[];
string expDescriptions[];
int objectTypes[];
string objectTypeDescriptions[];
int objectType = OBJ_TREND;

bool  keydown = false;
int   _lastkey = 0;
int current_color_index = 0;
int sleep = 100;
int colors[];
bool selected = false;
bool color_mode = false;
string s_color = "";
bool label_mode = false;
string s_label = "";

color getColor(int inc) {
   int s = ArraySize(colors) - 1;
   if (current_color_index + inc > s ) current_color_index = 0;
   else if (current_color_index + inc < 0) current_color_index = s;
   else current_color_index += inc;
   
   return (colors[current_color_index]);
}

int nextObjectType () {
   int size = ArraySize(objectTypes);
   
   for (int i = 0; i < size; i++) {
      if (objectTypes[i] == objectType) {
         if (i + 1 == size) { objectType = objectTypes[0]; break;} 
         else { objectType = objectTypes[i+1]; break; }
      }   
   }   
   return(objectType);
}

string objectTypeDescription() {
   int size = ArraySize(objectTypes);
   for (int i = 0; i < size; i++) {
      if (objectType == objectTypes[i]) return (objectTypeDescriptions[i]);
   }
   // errore non dovrebbe mai arrivare qui
   return ("--- undef ---");   
}

bool checkObjectType(int type) {
   return (type == objectType);
}

void SetSelected() {
   selected = !selected;  
   string s = "NON SELEZIONATO";
   if (selected) s = "SELEZIONATO";
   Comment("su oggetti: ", s);
}

void r() {
   WindowRedraw();
}   

bool isValidObjectName(string name) {
   bool r = true;
   if (StringFind(name, droppedLineName) != -1 || StringFind(name, exclusionPrefix) == 0 ) r = false;
   
   if (!selected) return(r); 
   return (!r);
}

int init() {
   Comment("Shortcut key Trapping");

   ArrayResize(colors,26);
   colors[0] = Black;
   colors[1] = DarkGreen;
   colors[2] = DarkSlateGray;
   colors[3] = Olive;
   colors[4] = Teal;
   colors[5] = Navy;
   colors[6] = Purple;
   colors[7] = Maroon;
   colors[8] = Indigo;
   colors[9] = MidnightBlue;
   colors[10] = DarkBlue;
   colors[11] = DarkOliveGreen;
   colors[12] = SaddleBrown;
   colors[13] = ForestGreen;
   colors[14] = OliveDrab;
   colors[15] = SeaGreen;
   colors[16] = DarkGoldenrod;
   colors[17] = DarkSlateBlue;
   colors[18] = Sienna;
   colors[19] = MediumBlue;
   colors[20] = Brown;
   colors[21] = DarkTurquoise;
   colors[22] = DimGray;
   colors[23] = LightSeaGreen;
   colors[24] = DarkViolet;
   colors[25] = FireBrick;

   // livelli dell'espansione da creare
   int lev = 9;  // num livelli
   ArrayResize(expLevels, lev); ArrayResize(expDescriptions, lev);

   expLevels[0] = -0.618;  expDescriptions[0] = "SL -61.8 @%$";
   expLevels[1] = 0;       expDescriptions[1] = "FE 0     @%$";
   expLevels[2] = 0.5;     expDescriptions[2] = "FE 50  @%$";
   expLevels[3] = 1.0;     expDescriptions[3] = "FE 100   @%$";
   expLevels[4] = 1.618;   expDescriptions[4] = "FE 161.8 @%$";
   expLevels[5] = 2.618;   expDescriptions[5] = "FE 261.8 @%$";
   expLevels[6] = 3.618;   expDescriptions[6] = "FE 361.8 @%$";
   expLevels[7] = 4.618;   expDescriptions[7] = "FE 461.8 @%$";
   expLevels[8] = 5.618;   expDescriptions[8] = "FE 561.8 @%$";

   // ----------- fine

   ArrayResize(objectTypes, 3); ArrayResize(objectTypeDescriptions, 3);
   objectTypes[0] = OBJ_TREND;
   objectTypes[1] = OBJ_HLINE; 
   objectTypes[2] = OBJ_VLINE;
   objectTypeDescriptions[0] = "OBJ_TREND";
   objectTypeDescriptions[1] = "OBJ_HLINE";
   objectTypeDescriptions[2] = "OBJ_VLINE";
   
   IdleLibInit();
   return(0);
}

void TrendLineWidth(int w) {
   Comment("SIZING TRENDLINES width: ", w);

   for(int k=ObjectsTotal()-1; k>=0; k--)  {
      string name = ObjectName(k);
      if (checkObjectType(ObjectType(name))) {
         if (isValidObjectName(name))  ObjectSet(name, OBJPROP_WIDTH, w);
      }                  
  }
  r();
}

void TrendLineColor(color clr) {
   Comment("COLORIZING TRENDLINES: ");
   int c = ArraySize(colors);

   for(int k=ObjectsTotal()-1; k>=0; k--)  {
      string name = ObjectName(k);
      if (checkObjectType(ObjectType(name))) {
         if (isValidObjectName(name)) ObjectSet(name, OBJPROP_COLOR, clr);
      }                  
  }
  r();
}


void TrendLineColorRot() {
   Comment("COLORIZING TRENDLINES: ");
   int c = ArraySize(colors);

   int n = 0;
   for(int k=ObjectsTotal()-1; k>=0; k--)  {
      string name = ObjectName(k);
      if (checkObjectType(ObjectType(name))) {
         if (n == c) n = 0;
         if (isValidObjectName(name)) ObjectSet(name, OBJPROP_COLOR, colors[n]);
         n++;
      }                  
  }
  r();
}

void LineDroppedStyle(int style) {
   Comment("CAMBIAMENTO STILE A LINE DROPPED: ");
   int c = ArraySize(colors);

   int n = 0;
   for(int k=ObjectsTotal()-1; k>=0; k--)  {
      string name = ObjectName(k);
      if (checkObjectType(ObjectType(name))) {
         if (n == c) n = 0;
         if (StringFind(name, droppedLineName) == 0) {
            LineStyle(name, style);
         }
         
         n++;
      }                  
  }
  r();
}

void LineStyle(string name, int style) {
   if (checkObjectType(ObjectType(name))) {
      ObjectSet(name, OBJPROP_STYLE, style);
   }
}


void TrendLineColorDefault() {
   Comment("COLORIZING TRENDLINES WITH DEFAULT: ");

   for(int k=ObjectsTotal()-1; k>=0; k--)  {
      string name = ObjectName(k);
      if (checkObjectType(ObjectType(name))) {
         if (isValidObjectName(name))  ObjectSet(name, OBJPROP_COLOR, default_color);
      }                  
  }
  r();
}

void LinesBlack() {
   Comment("COLORIZING TRENDLINES WITH BLACK: ");

   for(int k=ObjectsTotal()-1; k>=0; k--)  {
      string name = ObjectName(k);
      if (checkObjectType(ObjectType(name))) {
         if (isValidObjectName(name))  ObjectSet(name, OBJPROP_COLOR, Black);
      }                  
  }
  r();
}


void RotateText() {
   int lastObj = ObjectsTotal();
   string name = ObjectName(lastObj);
   Comment("TEXT ROTATATION OBJ: ", name);
   double ang = ObjectGet(name, OBJPROP_ANGLE);
   if (isValidObjectName(name)) ObjectSet(name, OBJPROP_ANGLE, ang+ 10);
   r();
}

void DeleteTrendLines() {
   Comment("DELETE ALL TRENDLINE");
   for(int k=ObjectsTotal()-1; k>=0; k--)  {
      string Obj_Name = ObjectName(k);
      if (checkObjectType(ObjectType(Obj_Name))) {
        if (isValidObjectName(Obj_Name)) ObjectDelete(Obj_Name);
      }                  
  }
  r();
  return(0);
}

void Ss() {
   Comment("Screenshot");
   ScreenShot("screenshot.gif",1024,1078,1,1,1);
   // bool WindowScreenShot( string filename, int size_x, int size_y, int start_bar=-1, int chart_scale=-1, int chart_mode=-1) 
}

string s (double v) {
   return (DoubleToStr(v, Digits));
}

void LinePoints() {
   string line = linePointsName;
   int l = ObjectFind(line);
   if (l > -1 && ObjectType(line) == OBJ_TREND) {
      double p1 = ObjectGet(line, OBJPROP_PRICE1);
      double p2 = ObjectGet(line, OBJPROP_PRICE2);
      Comment("start: ", s(p1), " end: ", s(p2), " - points of line: ", s(MathAbs(p1-p2)));
      if (deleteLinePoints) Exec(ObjectDelete(line));
   }
   else 
      Comment ("Line with name : \"", line, "\" not found.");
}

void help() {
   Comment("ELENCO TASTI\n====================\n\n",
      "0       : colora trendlines con colore di default\n",
      "1-5     : dimensione linea\n",
      "d       : cancella trendlines\n",
      "s       : seleziona / deseleziona _\n",
      "b       : tutte le linee di colore nero\n",
      "c       : colora trendlines\n",
      "e       : espansione su linea\n",
      "h       : salva screenshot\n",
      "j       : line dropped con stile a puntini\n",
      "o       : cancella tutti gli oggetti\n", 
      "p       : numeri linea (start, end, points)\n",
      "t       : cambia tipo di oggetto\n",
      "k       : line dropped con stile solido\n",
      "а       : trendline con colore (-)\n",
      "щ       : trendline con colore (+)\n",
      "u       : inverte coordinate linea di espansione\n",
      "w       : coverte expansion in linea\n",
      "e       : disegna expansion \n",
      "x       : uscita\n\n",
      "note:\n", 
      "quando una line inizia per _ viene ignorata negli stili altrettanto la line che inizia con LineDropped\n", 
      "la linea di espansione si chiama: [", expansionLineName, "]"
   );
}

void DeleteAllObjects() {
   ObjectsDeleteAll(0);
}

string d(double v) {
   return (DoubleToStr(v, Digits));
}

string key_to_char(int key) {
   string char = "";
   switch (key) {
      case 20: char =  " "; break;
      case 48: char =  "0"; break;
      case 49: char =  "1"; break;
      case 50: char =  "2"; break;
      case 51: char =  "3"; break;
      case 52: char =  "4"; break;
      case 53: char =  "5"; break;
      case 54: char =  "6"; break;
      case 55: char =  "7"; break;
      case 56: char =  "8"; break;
      case 57: char =  "9"; break;
      case 65: char =  "A"; break;
      case 66: char =  "B"; break;
      case 67: char =  "C"; break;
      case 68: char =  "D"; break;
      case 69: char =  "E"; break;
      case 70: char =  "F"; break;
      case 71: char =  "G"; break;
      case 72: char =  "H"; break;
      case 73: char =  "I"; break;
      case 74: char =  "J"; break;
      case 75: char =  "K"; break;
      case 76: char =  "L"; break;
      case 77: char =  "M"; break;
      case 78: char =  "N"; break;
      case 79: char =  "O"; break;
      case 80: char =  "P"; break;
      case 81: char =  "Q"; break;
      case 81: char =  "R"; break;
      case 81: char =  "S"; break;
      case 81: char =  "T"; break;
      case 81: char =  "U"; break;
      case 81: char =  "V"; break;
      case 81: char =  "W"; break;
      case 81: char =  "X"; break;
      case 81: char =  "Y"; break;
      case 81: char =  "Z"; break;

      default: break;
   }
   return (char);
}

int info() {
   double t = MarketInfo(Symbol(), MODE_TICKVALUE);
   double p = Point;
   double spread = MarketInfo(Symbol(), MODE_SPREAD) * p;
   string s = StringConcatenate("MERCATO: ", Symbol(), "\n----------------------\n", 
      "MODE_DIGITS: ", Digits,
      "\nMODE_SPREAD: ", d(spread),
      // "\nSPREAD VALUE x LOT: ", spreadMul(spread),
      "\nMODE_POINT: ", d(MarketInfo(Symbol(), MODE_POINT)),
      "\nMODE_LOTSIZE: ", MarketInfo(Symbol(), MODE_LOTSIZE),
      "\nMODE_TICKVALUE: ", d(t),
      "\nMODE_TICKSIZE: ", d(MarketInfo(Symbol(), MODE_TICKSIZE)),
      "\nMODE_SWAPLONG: ", MarketInfo(Symbol(), MODE_SWAPLONG),
      "\nMODE_SWAPSHORT: ", MarketInfo(Symbol(), MODE_SWAPSHORT),
      "\nMODE_TRADEALLOWED: ", MarketInfo(Symbol(), MODE_TRADEALLOWED),
      "\nMODE_MINLOT: ", MarketInfo(Symbol(), MODE_MINLOT),
      "\nMODE_LOTSTEP: ", MarketInfo(Symbol(), MODE_LOTSTEP),
      "\nMODE_MAXLOT: ", MarketInfo(Symbol(), MODE_MAXLOT),
      "\nMODE_PROFITCALCMODE: ", MarketInfo(Symbol(), MODE_PROFITCALCMODE),
      "\nMODE_MARGINCALCMODE: ", MarketInfo(Symbol(), MODE_MARGINCALCMODE),
      "\nMODE_MARGININIT: ", MarketInfo(Symbol(), MODE_MARGININIT)
   );
   Comment(s);
}

void outErr(string msg, bool detailed = false) {
   if (detailed) Comment(msg, " [ ", ErrorDescription(GetLastError()), " ]");
   else Comment (msg);
}


void Exec(bool exec) 
{
   if (!exec) Comment(ErrorDescription(GetLastError()));
}

void expansion() {
   string err = StringConcatenate("Line with name : \"", expansionLineName, "\" not found.");
   if (ObjectFind(expansionLineName) == 0) {
      if (ObjectType(expansionLineName) == OBJ_TREND) {  
         outErr("creating expansion");
         double p1 = ObjectGet(expansionLineName, OBJPROP_PRICE1);
         double p2 = ObjectGet(expansionLineName, OBJPROP_PRICE2);
         datetime t1 = ObjectGet(expansionLineName, OBJPROP_TIME1);
         datetime t2 = ObjectGet(expansionLineName, OBJPROP_TIME2);
         if (ObjectFind("expansion") > -1) ObjectDelete("expansion");
         
         Exec(ObjectCreate("expansion", OBJ_EXPANSION, 0, t1, p1, t2, p2, t2, p2));
         Exec(ObjectSet("expansion", OBJPROP_COLOR, expansionColor));
         Exec(ObjectSet("expansion", OBJPROP_LEVELCOLOR, expansionLevelColor));
         Exec(ObjectSet("expansion", OBJPROP_LEVELSTYLE, expansionLevelStyle));
         
         int j = ArraySize(expLevels);
         Exec(ObjectSet("expansion", OBJPROP_FIBOLEVELS, j));
         for (int i = 0; i < j; i++) {
            Exec(ObjectSet("expansion", OBJPROP_FIRSTLEVEL + i, expLevels[i]));
            Exec(ObjectSetFiboDescription("expansion",i, expDescriptions[i]));
            string msg = "target 100% = " + DoubleToStr(MathAbs(p1-p2), Digits);
            outErr(msg);
         }
         if (deleteExpansionLine ) Exec(ObjectDelete(expansionLineName));
      }
      else outErr("line is not a trendline");
   }
   else outErr (err);
}


void InvertCExp() {
   string err = StringConcatenate("Line with name : \"", expansionLineName, "\" not found.");
   if (ObjectFind(expansionLineName) == 0) {
      if (ObjectType(expansionLineName) == OBJ_TREND) {  
         double p1 = ObjectGet(expansionLineName, OBJPROP_PRICE1);
         double p2 = ObjectGet(expansionLineName, OBJPROP_PRICE2);
         datetime t1 = ObjectGet(expansionLineName, OBJPROP_TIME1);
         datetime t2 = ObjectGet(expansionLineName, OBJPROP_TIME2);
         Exec(ObjectMove(expansionLineName, 0, t2, p2));
         Exec(ObjectMove(expansionLineName, 1, t1, p1));
      }
      else outErr("line is not a trendline");
   }
   else outErr (err);
   outErr ("coordinate changed correctly");
}

void Expansion2Line() {
   string err = ("Expansion with name : expansion not found.");
   string exp = "expansion";
   if (ObjectFind(exp) == 0) {
      if (ObjectType(exp) == OBJ_EXPANSION) {  
         double p1 = ObjectGet(exp, OBJPROP_PRICE1);
         double p2 = ObjectGet(exp, OBJPROP_PRICE2);
         datetime t1 = ObjectGet(exp, OBJPROP_TIME1);
         datetime t2 = ObjectGet(exp, OBJPROP_TIME2);
         if (ObjectFind(expansionLineName) > -1) Exec(ObjectDelete(expansionLineName));
         Exec(ObjectCreate(expansionLineName, OBJ_TREND, 0, t1, p1, t2, p2));
         Exec(ObjectSet(expansionLineName, OBJPROP_COLOR, expansionLineColor));
         Exec(ObjectSet(expansionLineName, OBJPROP_RAY, False));
         Exec(ObjectSet(expansionLineName, OBJPROP_WIDTH, expansionLineWidth));
         Exec(ObjectSet(expansionLineName, OBJPROP_STYLE, expansionLineStyle));
         
         Exec(ObjectDelete(exp));
         
      }
      else outErr("line is not an expansion");
   }
   else outErr (err);
   outErr ("expansion converted.");   
}

void label_mode_on() {
   label_mode = true;   
   s_label = "";
   outErr("Label mode activated.");
}

void label_mode_off() {
   if (label_mode) color_mode = false;
   outErr("Label mode deactivated.");
}

void color_mode_on() {
   color_mode = true;   
   s_color = "";
   outErr("Color mode activated.");
}

void color_mode_off() {
   if (color_mode) color_mode = false;
   outErr("color mode deactivated.");
}

void applylabel(int key )
{
   s_label = StringConcatenate(s_label, key_to_char(key));
   string msg = StringConcatenate("label: { " , s_label, " }");
   outErr(msg);
}

void changeObjectType() {
   nextObjectType();
   outErr(StringConcatenate("Object type active: ", objectTypeDescription()));
}

int start() {
   bool NeedLoop=true;  
   bool NeedComments = false;
   
   while(NeedLoop) {           
     bool keyup = false;

     int lastkey=GetLastKeyWP();
     int lastmouse=GetLastMouseWP();
     string lastwnd=GetActiveWndName();
   
     RefreshRates();
          
     if (lastkey == 0)  {keydown = false; keyup = false; _lastkey = 0; }

     if (_lastkey == lastkey && keydown) { keyup = true; _lastkey = 0; }
     else { keyup = false; keydown = true;_lastkey = lastkey; }
     
     if (keyup) {
      if ((lastkey!=0) && (lastwnd!=""))  Print("LastKey=",lastkey," LastWindow=",lastwnd);
      if ((lastmouse!=0) && (lastwnd!="") && (lastmouse!=512)) Print("LastMouse=",lastmouse," LastMouseWindow= ",lastwnd);
      /*if (label_mode) {
         if (lastkey == 190) label_mode_off();  // .  
         else if (lastkey == 27)  { // ESC 
            s_label = "";            
         }
         else applylabel(lastkey);
      }*/
      if (color_mode) {
         if (lastkey > 47 && lastkey < 58) s_color = "";
         if (lastkey == 190) color_mode_off();  // .
      }
      else {
         if (lastkey == 48) TrendLineColorDefault(); // tasto 0      
         if (lastkey == 49) TrendLineWidth(1); // tasto 1
         if (lastkey == 50) TrendLineWidth(2); // tasto 2
         if (lastkey == 51) TrendLineWidth(3); // tasto 3
         if (lastkey == 52) TrendLineWidth(4); // tasto 4
         if (lastkey == 53) TrendLineWidth(5); // tasto 5

         if (lastkey == 68) DeleteTrendLines();                // tasto d
         if (lastkey == 66) LinesBlack();                      // tasto d
         if (lastkey == 67) TrendLineColorRot();               // tasto c
         if (lastkey == 69) {
            expansion(); // tasto e
            NeedComments = true;
            if (exitAfterExpansion) break;
         }   
         if (lastkey == 72) Ss();                             // tasto h
         if (lastkey == 73) info();                           // tasto h
         if (lastkey == 74) LineDroppedStyle(STYLE_DOT); // tasto j
         if (lastkey == 75) LineDroppedStyle(STYLE_SOLID); // tasto k
         if (lastkey == 77) { label_mode_on(); } // tasto o
         if (lastkey == 79) { DeleteAllObjects(); break; } // tasto o
         if (lastkey == 80) 
         {
            LinePoints(); // tasto p
            if (exitAfterLinePoints) {
               NeedComments = true;
               break;
            }
         }
         if (lastkey == 84) changeObjectType(); // tasto t
         if (lastkey == 85) InvertCExp(); // tasto u
         if (lastkey == 82) RotateText(); // tasto r
         if (lastkey == 83) SetSelected(); // tasto s
         if (lastkey == 86) color_mode_on(); // tasto v
         if (lastkey == 87) Expansion2Line(); // tasto w
         if (lastkey == 88) break; // tasto x // esce dallo script
         if (lastkey == 219) help();   // tasto ?
         if (lastkey == 192) TrendLineColor(getColor(1));   // tasto а
         if (lastkey == 222) TrendLineColor(getColor(-1));   // tasto т
        }
      }  
      Sleep(sleep);
   }//while
   if (clearCommentsOnExit && !NeedComments) Comment("");
   deinit();
   return(0);
  }

void deinit() {
   
   IdleLibUnInit();
}
