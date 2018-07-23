Table data;
int rows, cols;

PFont fz;
PFont fe;

float posY[], posX[], targetX[], targetY[];
float[][] sort;
String item[];


int count = 1;
float maxNumber = 0;

//////////////////////////data////////////////////////////////////////
float easing = 0.1;
int timeitv = 100;
int margin = 50;
int barMaxW = 480;//barlength
int barH = 25;//barHeight
int minY = 100;//first bar position Y
int maxY = 500;//last bar positon Y
color newMovie = #3b91fe;
color other = #90caf8;
int yearA = 1997;
int yearZ = 2017;



void setup() {
  size(670, 650);
  fz =  createFont("方正兰亭细黑_GBK", 48); 
  fe =  createFont("Lato Regular", 48);

  data = loadTable("movie.csv","header");
  rows = data.getRowCount();
  cols = data.getColumnCount();

  posX = new float[rows];
  posY = new float[rows];
  targetX = new float[rows];
  targetY = new float[rows];
  sort = new float[rows][cols];
  item = new String[rows];

  for (int i = 0; i < rows; i++) {
    item[i] = data.getString(i, 0);
  }

  //find max
  for (int m = 0; m<cols; m++) {
    for (int n =0; n<rows; n++) {
      float value = data.getFloat(n, m);
      if (value > maxNumber) {
        maxNumber = value;
      }
    }
  }

  //rank every column
  for (int j = 0; j < cols; j++) {
    for (int k = 0; k < rows; k++) {
      sort[k][j] = data.getFloat(k, j);
    }
  }  
  selected(sort);
}

void draw() {
  background(255);    
  
  float time = frameCount-timeitv*count;
  if (time > 0) {
    count ++;
  }
  if ( frameCount > (count-1)*timeitv && frameCount < count*timeitv && count < cols-1 ) {
    int years = yearA+count-1;
    infor(years);
    drawBar(count);
  } else if ( frameCount > (cols-2)*timeitv) {
    infor(yearZ);
    drawBar(cols-1);
  }
}

void infor(int year) {
  stroke(250);
  strokeWeight(40); 
  for (int i = 0; i < 5; i++) {  
    float y = map(i, 0, 5, 182, 580);
    line( 20, y, width-20, y);
  }


  textFont(fe);
  fill(100);
  textSize(36);  
  textAlign(RIGHT);
  text(year, width-60, 515);
}

void drawBar(int year) {  
  strokeWeight(barH);
  strokeCap(SQUARE);
  for ( int i = 0; i < rows; i++ ) {
    
    if (year == 1) {
      posX[i] = map(data.getFloat(i, 1), 0, maxNumber, 0, barMaxW) + margin;   
      posY[i] = map(sort[i][1], 0, -10, minY, maxY);
    } else {
      targetX[i] = map(data.getFloat(i, year), 0, maxNumber, 0, barMaxW) + margin;
      targetY[i] = map(sort[i][year], 0, -10, minY, maxY);
      posX[i] += (targetX[i] - posX[i])*easing;
      posY[i] += (targetY[i] - posY[i])*easing;
    }

    if (data.getFloat(i, year)-data.getFloat(i, year-1)>0&year>1) {
      stroke(newMovie);
    } else {
      stroke(other);
    }
    line(margin, posY[i], posX[i], posY[i]);

    textAlign(RIGHT);
    textSize(20);
    if (sort[i][year]<-10) {
      fill(255) ;
    } else {
      fill(30);
    }
    textFont(fz);  
    textAlign(LEFT);
    textSize(20);  
    text(item[i], posX[i]+5, posY[i]+8);

    if (sort[i][year] < -10) {
      fill(255) ;
    } else {
      fill(255);
    }
    textFont(fe);
    textAlign(RIGHT);    
    textSize(16);  
    text(nfc(data.getFloat(i, year), 2), posX[i]-5, posY[i]+6);
  }
}

//排序列表
void selected( float arr[][]) {
  float rank = -1;
  for (int k = 0; k < cols; k++) {
    for (int i = 0; i < rows; i++) {
      float record = -1;
      int selecteditem = 0;  

      for (int j = selecteditem; j < rows; j++) {
        float b = arr[j][k];
        if (b > record) {
          selecteditem = j ;
          record = b;//select max
        }
      }
      arr[selecteditem][k] = rank;  
      rank--;
    }
    rank += rows;
  }
}
