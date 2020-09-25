
PImage flag;
PImage bomb;
PImage boom;
PImage cell;
PImage hiddenCell;
PImage[] numbers;
PFont f;

final int CELL_SIZE = 30;
final int NB_ROW = 20;
final int NB_COL = 20;
int nbBombs = 20;
int bombsRemaining = nbBombs;
char[][] grid;
boolean[][] revealed;
boolean[][] flagged;
boolean over = false;
String message = "lost";

void setup() {
  size(600,635); //x y
  revealed = new boolean[NB_ROW][NB_COL];
  flagged  = new boolean[NB_ROW][NB_COL];
  grid = new char[NB_ROW][NB_COL];
  
  numbers = new PImage[8];
  for(int i = 0; i < numbers.length; i++)
    numbers[i] = loadImage((i+1)+".png");
    
   f = createFont("Noto Sans Condensed Bold",32,true);
  
  hiddenCell = loadImage("hiddenCell.png");
  cell = loadImage("cell.png");
  bomb = loadImage("bomb.png");
  boom = loadImage("boom.png");
  flag = loadImage("flag.png");
  
  fillGrid();
  noLoop();
}

void fillGrid() {
  ArrayList<Integer> nums = new ArrayList<Integer>();
  int rand = 0;
  for(int i = 0; i < NB_ROW*NB_COL; i++) {
    nums.add(i);
  }
  
  for(int i = 0; i < NB_ROW; i++) {
    for(int j = 0; j < NB_COL; j++) {
      revealed[i][j] = false;
      flagged[i][j] = false;
      grid[i][j] = ' ';
    }
  }
  
  for(int i = 0; i < nbBombs; i++) {
    rand = (int)random(nums.size());
    Integer pos = nums.get(rand);
    nums.remove(rand);
    int x = pos%NB_COL;
    int y = pos/NB_COL;
    grid[x][y] = 'B';
   // revealed[x][y] = true;
  }
  
  for(int i = 0; i < NB_ROW; i++) 
    for(int j = 0; j < NB_COL; j++) 
      if(grid[i][j] != 'B') {
        int around = bombsAround(i,j);
        if(around>0) {
          grid[i][j] = (around+" ").charAt(0);
          // revealed[i][j] = true;
        }
        
      }
}

void mouseClicked() {
  int row = (mouseX)/CELL_SIZE;
  int col = (mouseY-30)/CELL_SIZE;
  if(mouseButton == LEFT) {
    if(!over && !flagged[row][col]) {
      if(grid[row][col] == ' ') fill(row,col);
      else if(grid[row][col] == 'B') {
        over = true;
        grid[row][col] = 'b';
      }
      else revealed[row][col] = true;
    }
      
  } else if (mouseButton == RIGHT) {
    flagged[row][col] = !flagged[row][col];
    bombsRemaining--;
  }
  
  
  if(hasWon()) {
    message = "won";
    over = true;
  }
  redraw();
}

void draw() {
  background(0xc0c0c0);
  for(int i = 0; i < NB_ROW; i ++) {
    for(int j = 0; j < NB_COL; j++) {
      if(over || revealed[i][j])
        image(correspondingImage(grid[i][j]), i*CELL_SIZE, j*CELL_SIZE+30);
      else
        if(flagged[i][j]) image(correspondingImage('F'), i*CELL_SIZE, j*CELL_SIZE+30);
        else image(hiddenCell, i*CELL_SIZE, j*CELL_SIZE+30);
    }
  }
  fill(0); 
  textAlign(CENTER);
  textFont(f,18);
  text("bombs remaining : " + String.format("%2d", bombsRemaining), 635/2, 22);
  if(over) {
    stroke(#808080);
    strokeWeight(5);
    fill(#c0c0c0);
    textFont(f,48);
    rect(210 , 270, 180, 55, 7);
    fill(0);
    text("You " + message, 600/2,635/2);
  }
}

boolean hasWon() {
  int n = 0;
  for(int i = 0; i < NB_ROW; i++) 
    for(int j = 0; j < NB_COL; j++) {
      if(revealed[i][j]) n++;
    }
  return n == NB_COL*NB_ROW-nbBombs;
}

PImage correspondingImage(char c) {
  switch(c) {
    case 'B' : return bomb;
    case 'b' : return boom;
    case 'F' : return flag;
    case '1' : return numbers[0];
    case '2' : return numbers[1];
    case '3' : return numbers[2];
    case '4' : return numbers[3];
    case '5' : return numbers[4];
    case '6' : return numbers[5];
    case '7' : return numbers[6];
    case '8' : return numbers[7];
    default  : return cell;
  }
}



int bombsAround(int i, int j) {
  int n = 0; 
    if(i>0 && grid[i-1][j] == 'B') n++;
    if(i<NB_COL-1 && grid[i+1][j] == 'B') n++;
    if(j > 0 && grid[i][j-1] == 'B') n++;
    if(j < NB_ROW-1 && grid[i][j+1] == 'B') n++;
    if(i>0 && j > 0 && grid[i-1][j-1] == 'B') n++;
    if(i<NB_COL-1 && j < NB_ROW-1 && grid[i+1][j+1] == 'B') n++;
    if(i>0 && j < NB_ROW-1 && grid[i-1][j+1] == 'B') n++;
    if(i<NB_COL-1 && j > 0 && grid[i+1][j-1] == 'B') n++;
 
  return n;
}

void fill(int y, int x) {
 if(y >= 0 && y < NB_ROW && x >= 0 && x < NB_COL && fillable(grid[y][x])&&!revealed[y][x]) {
    revealed[y][x] = true;
    if(grid[y][x] == ' ') {
      if(flagged[y][x]) grid[y][x] = ' ';
      if(y>0)fill(y-1,x); //N
      if(y>0&&x>0)fill(y-1,x-1); //NE
      if(y<NB_ROW-1)fill(y+1,x); //S
      if(y<NB_ROW-1&&x<NB_COL-1)fill(y+1,x+1); //SE
      if(x<NB_COL-1)fill(y,x+1); //E
      if(x>0)fill(y,x-1); //O
      if(x>0&&y>0)fill(y-1,x-1); //NO
      if(x>0&&y<NB_ROW-1)fill(y+1,x-1); //SO
    }    
 }
}

boolean fillable(char c) {
  return c == ' ' || c == '1' ||  c == '2' ||  c == '3' ||  c == '4' ||  c == '5' ||  c == '6' ||  c == '7' ||  c == '8'; 
}
