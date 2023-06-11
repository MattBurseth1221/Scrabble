import java.util.*;
import de.bezier.data.sql.*;
import java.net.URLConnection;
import java.net.URL;

//*****GAMESTATE DICT*****
//0 -> Get numPlayers from input
//1 -> Initialize players
//1.5 -> Initialize tiles, pick tile to determine 1st player
//2 -> Re-initialize tiles, shuffle tiles, each player selects their rack
//2.5 -> Can also print player racks and remaining tiles
//3 -> Players take turns placing tiles and confirming moves
//10 -> Main menu?

SQLite db;
PImage photo;

final int SEARCH_IMAGE_DIM = 50;

int gameState = 0;
final float rectRatio = 1.14;
final int dimensions = 15;
int extraWidth = 150;
int extraHeight = 100;
boolean checkDict = true;

int squareWidth = 35;
int squareHeight = (int)(rectRatio * squareWidth);

private int id = 0;
int numPlayers;
int player;
PFont font;
int fontSize = (squareWidth + squareHeight) / 4;

ArrayList<Tile> tiles = new ArrayList<>(100);
ArrayList<Tile> swappedTiles = new ArrayList<>();
ArrayList<Player> players;
ArrayList<String> checkWords;
HashMap<int[], Boolean> map;
Scanner input = new Scanner(System.in);
Random r = new Random();
String[] specials = new String[dimensions * dimensions];
Space[][] spaces = new Space[dimensions][dimensions];
ArrayList<Space> playedSpaces = new ArrayList<>();

String errorCode = "";
boolean passed = false;
boolean tileSelected = false;
boolean validPlay = true;
boolean swapping = false;
boolean firstTurn = true;
int selectedTileId = -10;
int blankTileId = -1;

void settings() {
  size(dimensions * squareWidth + extraWidth, dimensions * squareHeight + extraHeight);
}

void setup() {
  photo = loadImage("magnifyingglass.jpg");
  photo.resize(SEARCH_IMAGE_DIM, SEARCH_IMAGE_DIM);
  photo.loadPixels();
  
  for (int i = 0; i < photo.pixels.length; i++) {
    if (photo.pixels[i] < -18000000) {
      photo.pixels[i] = color(205); 
    }
  }
  
  photo.updatePixels();
  
  db = new SQLite(this, "NWL2020.db");
  db.setDebug(false);

  initSpaces();
  font = createFont("Interstate Bold.otf", fontSize);
  System.out.println("How many players? (2-4)");
}

void draw() {
  background(205);
  drawGrid();
  drawSpaces();

  image(photo, width - (extraWidth / 2) - (SEARCH_IMAGE_DIM / 2), 100);

  if (gameState == 1) {
    initGame();
  }

  if (gameState == 2) {
    initPlayerTiles();
    player = 0;
  }

  if (gameState == 3) {
    playerTurn();
    showPlayerScore();
  }

  if (gameState == 4) {
    promptLetter();
  }
  
  if (gameState == 5) {
    playerTurn();
    printSwapText();
  }
  
  if (gameState == 6) {
     
  }
}



void printSwapText() {
  textSize(20);
  text("Select tiles to swap", width - 60, height - 20);
}

void showPlayerScore() {
  for (int i = 0; i < players.size(); i++) {
    fill(#000000);
    textSize(16);
    text("Player " + (i + 1) + ": " + players.get(i).getScore(), width - 40, 30 + (20 * i));
  }
}

void promptLetter() {
  textSize(40);
  fill(0);
  text("Enter a letter: ", 300, height - 30);
}

void drawSpaces() {
  for (int i = 0; i < dimensions; i++) {
    for (int j = 0; j < dimensions; j++) {
      spaces[i][j].show();
    }
  }
}

//Draws lines of grid
void drawGrid() {
  stroke(120);

  for (int i = 0; i <= dimensions; i++) {
    line(0, i * squareHeight, (dimensions * squareWidth), i * squareHeight);
    line(i * squareWidth, 0, i * squareWidth, (dimensions * squareHeight));
  }
}

//Initialize special space array with String identifier
//Afterwards, initialize 2D spaces array checking for multiplier from specials
void initSpaces() {
  specials[16] = "dw";
  specials[28] = "dw";
  specials[32] = "dw";
  specials[42] = "dw";
  specials[48] = "dw";
  specials[56] = "dw";
  specials[64] = "dw";
  specials[70] = "dw";
  specials[112] = "dw";
  specials[154] = "dw";
  specials[160] = "dw";
  specials[168] = "dw";
  specials[176] = "dw";
  specials[182] = "dw";
  specials[192] = "dw";
  specials[196] = "dw";
  specials[208] = "dw";
  specials[0] = "tw";
  specials[7] = "tw";
  specials[14] = "tw";
  specials[105] = "tw";
  specials[119] = "tw";
  specials[210] = "tw";
  specials[217] = "tw";
  specials[224] = "tw";
  specials[3] = "dl";
  specials[11] = "dl";
  specials[36] = "dl";
  specials[38] = "dl";
  specials[45] = "dl";
  specials[52] = "dl";
  specials[59] = "dl";
  specials[92] = "dl";
  specials[96] = "dl";
  specials[98] = "dl";
  specials[102] = "dl";
  specials[108] = "dl";
  specials[116] = "dl";
  specials[122] = "dl";
  specials[126] = "dl";
  specials[128] = "dl";
  specials[132] = "dl";
  specials[165] = "dl";
  specials[172] = "dl";
  specials[179] = "dl";
  specials[186] = "dl";
  specials[188] = "dl";
  specials[213] = "dl";
  specials[221] = "dl";
  specials[20] = "tl";
  specials[24] = "tl";
  specials[76] = "tl";
  specials[80] = "tl";
  specials[84] = "tl";
  specials[88] = "tl";
  specials[136] = "tl";
  specials[140] = "tl";
  specials[144] = "tl";
  specials[148] = "tl";
  specials[200] = "tl";
  specials[204] = "tl";

  for (int i = 0; i < dimensions; i++) {
    for (int j = 0; j < dimensions; j++) {
      spaces[i][j] = new Space(specials[(dimensions * i) + j], squareWidth * j, squareHeight * i);
    }
  }
}

void initGame() {
  startPlayers();
}

void printRacks() {
  for (int i = 0; i < players.size(); i++) {
    ArrayList<Tile> tempList = players.get(i).getLetterSet();
    System.out.print("Player " + (i + 1) + " has: ");
    tempList.forEach((n) -> System.out.print(n.getLetter() + " "));
    System.out.println("");
  }
}

void playerTurn() {
  printPlayerRack();
}

void printPlayerRack() {
  int rackTileWidth = squareWidth + 10;
  int spaceBetweenTiles = 10;

  ArrayList<Tile> tempRack = players.get(player).getLetterSet();

  for (int i = 0; i < tempRack.size(); i++) {
    tempRack.get(i).drawTile(50 + (i * (rackTileWidth + spaceBetweenTiles)), height - 75, rackTileWidth, (int)(rackTileWidth * rectRatio));
  }
}

void startPlayers() {
  if (gameState == 1) {
    players = new ArrayList<>(numPlayers);
    gameState = 2;

    drawInitTiles();
  }
}

int getTileIndexById(int id) {
  for (int i = 0; i < players.get(player).getLetterSet().size(); i++) {
    if (players.get(player).getLetterSet().get(i).getId() == id) {
      return i;
    }
  }

  return -1;
}

void mousePressed() {
  if (gameState == 3) {
    ArrayList<Tile> tempRack = players.get(player).getLetterSet();

    for (int i = 0; i < tempRack.size(); i++) {
      tempRack.get(i).wasClicked(mouseX, mouseY);
    }

    for (int i = 0; i < spaces.length; i++) {
      for (int j = 0; j < spaces[i].length; j++) {
        if (spaces[i][j].wasClicked(mouseX, mouseY)) {
          if (tileSelected) {
            if (!spaces[i][j].hasTile()) {
              int replace = getTileIndexById(selectedTileId);

              if (players.get(player).getLetterSet().get(replace).getLetter() == '_') {
                blankTileId = players.get(player).getLetterSet().get(replace).getId();
                gameState = 4;
              }

              if (replace != -1) {
                Tile transferTile = players.get(player).getLetterSet().get(replace);
                spaces[i][j].setTile(transferTile);
                playedSpaces.add(spaces[i][j]);
                players.get(player).removeLetterAtIndex(replace);
                tileSelected = false;
              }
            }
          } else {
            if (spaces[i][j].hasTile()) {
              if (spaces[i][j].getTile().myTile(player)) {
                if (spaces[i][j].getTile().getId() >= 98) {
                  spaces[i][j].getTile().setGhostLetter('!');
                }
                //chasnge here
                players.get(player).getLetterSet().add(spaces[i][j].getTile());
                spaces[i][j].removeTile();
                playedSpaces.remove(spaces[i][j]);
              }
            }
          }
        }
      }
    }
  }
  
  if (gameState == 5) {
    ArrayList<Tile> tempRack = players.get(player).getLetterSet();
    
    for (int i = 0; i < tempRack.size(); i++) {
      tempRack.get(i).wasClicked(mouseX, mouseY); 
    }
  }
}

void keyPressed() {
  //System.out.println(key);

  if (gameState == 0) {
    if (key == '2' || key == '3' || key == '4') {
      numPlayers = Character.getNumericValue(key);
      gameState = 1;
    } else {
      System.out.println("Bad input: " + key);
    }
  }

  if (gameState == 3) {
    if (key == 'p') {
      validPlay = checkValid();

      if (validPlay) {
        players.get(player).updateTotalRack();
        selectTiles();
        
        if (!passed) {
          players.get(player).addScore(calculateScore());
          firstTurn = false;
        }  
        changePlayer();
        //validPlay = true;
        playedSpaces = new ArrayList<>();
      } else {
        System.out.println(errorCode);
      }
    } else if (key == 's') {
      players.get(player).shuffle();
    } else if (key == 'r') {
      printRemainingTiles();
    } else if (key == 'w' && playedSpaces.size() == 0) {
      swapping = true;
      gameState = 5;
    }
  }
  if (gameState == 5) {
    if (key == 'p') {
      updateSwappedTiles();
      
      if (swappedTiles.size() != 0) {
        selectTiles();
        addSwappedTiles();
        gameState = 3;
        changePlayer();
        swapping = false;
      } else {
        System.out.println("No tiles swapped!");
        gameState = 3;
        swapping = false;
      }
    }
  }

  if (gameState == 4) {
    if (Character.isLetter(key)) {
      players.get(player).getTotalRack().get(getTileIndexByIdFromTotalRack(blankTileId)).setGhostLetter(Character.toUpperCase(key));
      gameState = 3;
    } else {
      System.out.println("Not a letter!");
    }
  }
}

void updateSwappedTiles() {
  swappedTiles = new ArrayList<>();
  ArrayList<Tile> tempRack = players.get(player).getLetterSet();
  
  for (int i = 0; i < tempRack.size(); i++) {
    if (tempRack.get(i).isSelected()) {
      tempRack.get(i).setSelected(false);
      swappedTiles.add(tempRack.get(i)); 
      
      tempRack.remove(i);
      i--;
    }
  }
}

boolean calculatePlayedWords() {
  ArrayList<Space> visited = new ArrayList<>();
  checkWords = new ArrayList<>();
  //boolean is true if horizontal, false if vertical
  map = new HashMap<>();
  int x = -1;
  int y = -1;
  String addWord;
  int storeX = -1;
  int storeY = -1;

  while (visited.size() != playedSpaces.size()) {
  outer:
    for (int i = 0; i < spaces.length; i++) {
      for (int j = 0; j < spaces[i].length; j++) {
        if (playedSpaces.contains(spaces[i][j]) && !visited.contains(spaces[i][j])) {
          //System.out.println("found!" + i + " " + j + " " + spaces[i][j].getTile().getLetter());
          y = i;
          x = j;
          break outer;
        }
      }
    }

    if (x == -1 || y == -1) {
      System.out.println("wtf happened here?");
    }
    //System.out.println("x: " + x + " y: " + y);


    //check left
    addWord = "";
    int index = x;

    while ((index - 1) >= 0 && spaces[y][index - 1].hasTile()) {
      index--;
    }

    storeX = y;
    storeY = index;

    //System.out.println("i: " + index);
    while (index < dimensions && spaces[y][index].hasTile()) {
      //System.out.println("adding letter");
      addWord += spaces[y][index].getTile().getLetter();
      index++;
    }

    if (addWord.length() > 1 && !checkWords.contains(addWord)) {
      map.put(new int[]{storeX, storeY}, true);
      checkWords.add(addWord);
      System.out.println("Horizontal word played: " + addWord);
    }

    //check down
    addWord = "";
    index = y;

    while ((index - 1) >= 0 && spaces[index - 1][x].hasTile()) {
      index--;
    }

    storeX = index;
    storeY = x;

    //System.out.println("i: " + index);
    while (index < dimensions && spaces[index][x].hasTile()) {
      //System.out.println("adding letter");
      addWord += spaces[index][x].getTile().getLetter();
      index++;
    }

    if (addWord.length() > 1 && !checkWords.contains(addWord)) {
      map.put(new int[]{storeX, storeY}, false);
      checkWords.add(addWord);
      System.out.println("Vertical word played: " + addWord);
    }

    visited.add(spaces[y][x]);
  }

  if (checkDict) {
    for (String word : checkWords) {
      String query = "SELECT COUNT(*) as \"count\" FROM words WHERE word LIKE ";
      query += "\"" + word + "\"";

      if (db.connect()) {
        db.query(query);

        if (db.next()) {
          if (db.getInt("count") == 0) {
            errorCode = "Word not found: " + word + "!";
            return false;
          }
        }
      }
    }
  }

  return true;
}


void addSwappedTiles() {
  for (int i = 0; i < swappedTiles.size(); i++) {
    tiles.add(swappedTiles.get(i));
  }
}

boolean checkTouching() {
  for (int i = 0; i < spaces.length; i++) {
    for (int j = 0; j < spaces[i].length; j++) {
      if (firstTurn && spaces[7][7].hasTile()) {
        return true;
      }

      if (playedSpaces.contains(spaces[i][j])) {
        //up
        if (i - 1 >= 0 && spaces[i - 1][j].hasTile() && !playedSpaces.contains(spaces[i - 1][j])) {
          return true;
        }
        //down
        if (i + 1 < dimensions && spaces[i + 1][j].hasTile() && !playedSpaces.contains(spaces[i + 1][j])) {
          return true;
        }
        //left
        if (j - 1 >= 0 && spaces[i][j - 1].hasTile() && !playedSpaces.contains(spaces[i][j - 1])) {
          return true;
        }
        //right
        if (j + 1 < dimensions && spaces[i][j + 1].hasTile() && !playedSpaces.contains(spaces[i][j + 1])) {
          return true;
        }
      }
    }
  }

  errorCode = "Floating tiles!";
  return false;
}

boolean checkValid() {
  validPlay = true;
  boolean vert = true, hori = true;
  int newTileCount = 0;
  boolean touchingLand = checkTouching();
  passed = false;
  
  if (playedSpaces.size() == 0) {
    System.out.println("Player " + (player + 1) + " passes...");
    passed = true;
    return true; 
  }

  if (firstTurn && playedSpaces.size() == 1) {
    errorCode = "Words must be more than one letter!";
    return false;
  } else if (firstTurn && !playedSpaces.contains(spaces[7][7])) {
    errorCode = "Use center space on first turn!";
    return false;
  }

  for (int i = 0; i < playedSpaces.size() - 1; i++) {
    if (playedSpaces.get(i).getXPos() != playedSpaces.get(i + 1).getXPos()) {
      //System.out.println("vert made false");
      vert = false;
    }
  }

  for (int i = 0; i < playedSpaces.size() - 1; i++) {
    if (playedSpaces.get(i).getYPos() != playedSpaces.get(i + 1).getYPos()) {
      //System.out.println("hori made false");
      hori = false;
    }
  }

  if (hori == false && vert == false) {
    errorCode = "Separated tiles!";
    return false;
  }

  if (vert) {
    for (int j = 0; j < spaces[0].length; j++) {
      for (int i = 0; i < spaces.length; i++) {
        if (playedSpaces.contains(spaces[i][j])) {
          while (i < dimensions && newTileCount < playedSpaces.size()) {
            if (!spaces[i][j].hasTile()) {
              //System.out.println("vert problem");
              return false;
            }

            newTileCount++;
            i++;
          }
        }
      }
    }
  } else if (hori) {
    for (int i = 0; i < spaces.length; i++) {
      for (int j = 0; j < spaces[0].length; j++) {
        if (playedSpaces.contains(spaces[i][j])) {
          while (j < dimensions && newTileCount < playedSpaces.size()) {
            if (!spaces[i][j].hasTile()) {
              //System.out.println("hori problem");
              return false;
            }

            newTileCount++;
            j++;
          }
        }
      }
    }
  }

  if (!calculatePlayedWords()) {
    return false;
  }

  return touchingLand && ((hori && vert) || hori ^ vert);
}

int calculateScore() {
  int wordMult = 1;
  int score = 0;
  int letterMult = 1;

  for (Map.Entry<int[], Boolean> entry : map.entrySet()) {
    int tempScore = 0;
    wordMult = 1;
    letterMult = 1;

    if (entry.getValue()) {
      //horizontal word

      int xIndex = entry.getKey()[0];
      int yIndex = entry.getKey()[1];

      while (yIndex < dimensions && spaces[xIndex][yIndex].hasTile()) {
        letterMult = 1;

        if (playedSpaces.contains(spaces[xIndex][yIndex])) {
          letterMult *= spaces[xIndex][yIndex].getScoreMult();

          if (spaces[xIndex][yIndex].getMultiplier() == "dw") {
            wordMult *= 2;
          } else if (spaces[xIndex][yIndex].getMultiplier() == "tw") {
            wordMult *= 3;
          }
        }

        tempScore += letterMult * spaces[xIndex][yIndex].getTile().getScore();
        yIndex++;
      }

      tempScore *= wordMult;
      System.out.println("word at " + xIndex + " " + yIndex + " has score of " + tempScore);
    } else {
      //vertical word

      int xIndex = entry.getKey()[0];
      int yIndex = entry.getKey()[1];

      while (xIndex < dimensions && spaces[xIndex][yIndex].hasTile()) {
        letterMult = 1;

        if (playedSpaces.contains(spaces[xIndex][yIndex])) {
          letterMult *= spaces[xIndex][yIndex].getScoreMult();

          if (spaces[xIndex][yIndex].getMultiplier() == "dw") {
            wordMult *= 2;
          } else if (spaces[xIndex][yIndex].getMultiplier() == "tw") {
            wordMult *= 3;
          }
        }

        tempScore += letterMult * spaces[xIndex][yIndex].getTile().getScore();
        xIndex++;
      }

      tempScore *= wordMult;
      System.out.println("word at " + xIndex + " " + yIndex + " has score of " + tempScore);
    }

    score += tempScore;
  }

  return playedSpaces.size() == 7 ? score + 50 : score;
}

int getTileIndexByIdFromTotalRack(int targetId) {
  for (int i = 0; i < players.get(player).getTotalRack().size(); i++) {
    if (players.get(player).getTotalRack().get(i).getId() == targetId) {
      return i;
    }
  }

  return -1;
}

void changePlayer() {
  player = (player + 1) % numPlayers;
  System.out.println("Player " + (player + 1) + "\'s turn!");
}

void initPlayerTiles() {
  initTiles();
  shuffleTiles();
  selectTiles();
  printRacks();
  //printRemainingTiles();

  gameState = 3;
}

void selectTiles() {

  for (int i = 0; i < players.size(); i++) {
    int random;
    int tempSize = 7 - (players.get(i).getLetterSet().size());
    ArrayList<Tile> tempList = new ArrayList<>(tempSize);
    int j = 0;
    //System.out.println("Player " + (i + 1) + " has size " + (tempSize));

    if (tempSize != 0) {
      while (j < tempSize && tiles.size() > 0) {
        random = r.nextInt(tiles.size());
        tempList.add(tiles.get(random));
        tiles.remove(random);
        j++;
      }

      players.get(i).addToLetterSet(tempList);
    }
  }
}

void initTiles() {
  id = 0;

  tiles = new ArrayList<Tile>(100);
  addTile('A', 1, 9);
  addTile('B', 3, 2);
  addTile('C', 3, 2);
  addTile('D', 2, 4);
  addTile('E', 1, 12);
  addTile('F', 4, 2);
  addTile('G', 2, 3);
  addTile('H', 4, 2);
  addTile('I', 1, 9);
  addTile('J', 8, 1);
  addTile('K', 5, 1);
  addTile('L', 1, 4);
  addTile('M', 3, 2);
  addTile('N', 1, 6);
  addTile('O', 1, 8);
  addTile('P', 3, 2);
  addTile('Q', 10, 1);
  addTile('R', 1, 6);
  addTile('S', 1, 4);
  addTile('T', 1, 6);
  addTile('U', 1, 4);
  addTile('V', 4, 2);
  addTile('W', 4, 2);
  addTile('X', 8, 1);
  addTile('Y', 4, 2);
  addTile('Z', 10, 1);
  addTile(' ', 0, 2);
}

void addTile(char letter, int score, int dist) {
  for (int i = 0; i < dist; i++) {
    tiles.add(new Tile(letter, score, id));
    id++;
  }
}

void shuffleTiles() {
  System.out.println("Shuffling tiles...");

  Collections.shuffle(tiles);
}

void printTiles() {
  tiles.forEach((n) -> System.out.print(n.getLetter() + " "));
}

void drawInitTiles() {
  initTiles();
  int[] starter = {-1, 1000};

  for (int i = 0; i < numPlayers; i++) {
    int random = r.nextInt(tiles.size());
    System.out.println("Player " + (i + 1) + " drew a " + tiles.get(random).getLetter());

    if (tiles.get(random).getLetter() < starter[1] && starter[1] != '_' || tiles.get(random).getLetter() == '_') {
      starter[0] = i;
      starter[1] = tiles.get(random).getLetter();
    }

    tiles.remove(random);
  }

  initPlayers(starter);
}

void initPlayers(int[] starter) {

  for (int i = 0; i < numPlayers; i++) {
    players.add(new Player(i + 1));
  }

  System.out.println("Drawer number " + (starter[0] + 1) + " that drew a " + char(starter[1]) + " will begin.");
}

void printRemainingTiles() {
  System.out.println("There are " + tiles.size() + " tiles left in the bag.");
}
