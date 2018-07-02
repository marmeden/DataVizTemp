//created by yasai

PShape baseMap;
Table data;
Table nums;
PVector[] points;
PVector[] equidistantPoints;

float t = 0.0;
float tStep = 0.001;
int rows, rows_;
PFont fontBold, fontReg;

final int POINT_COUNT = 100;
BezierCurve curve;
int offset = 100;
int nationCount = 1;
float ptoLong = 0.0;
float pfromLong = 0.0;
float distance;
int offsetW = 10;
int offsetH = 100;
int offsetZ = 60;    
float zoomX = 0;
float zoomY = 0;
int timer;
int year = 1975;
int frames = 10;
int margin = 500;

void setup() {
  size(1800, 900, P3D);
  baseMap = loadShape("WorldMap-05.svg");
  data = loadTable("nanming.csv", "header");
  rows = data.getRowCount();
  nums = loadTable("numbers.csv", "header");
  rows_ = nums.getRowCount();
  smooth(15);
  fontBold = createFont("Lato-Bold.ttf", 48); 
  fontReg = createFont("Lato-Regular.ttf", 48);
}

void draw() {
  background(22, 22, 22);
  shape(baseMap, offset*2, offset, width - offset*4, height - offset*2);


  for (int i = 0; i < rows_; i++) { 
    if (frameCount/frames >= i & frameCount/frames <i+1) {
      drawRoutes(1975+i);
    } else if (frameCount/frames > 41) { 
      drawRoutes(2016);
    }
  }

  pushMatrix();
  translate(margin+100, 50);
  drawBar();
  drawLine(); 
  drawInfo();
  popMatrix();
  //saveFrame("map-######.png");
}

void drawBar() {
  int barW = (width-margin*2)/rows_;
  for (int i =0; i<rows_; i++) {
    float barH = map(nums.getInt(i, 1), 0, 18000000, 20, 80);  
    stroke(255, 220);
    strokeWeight(10);
    strokeCap(SQUARE);
    if (frameCount/frames > i ) {
      line(i*barW, 750, i*barW, 750-barH);
    }
  }
}

void drawLine() {  
  int lineW = (width-margin*2)/rows_; 
  float lineH;
  beginShape();
  noFill();   
  strokeWeight(5);
  stroke(#FF536D);
  strokeCap(ROUND);
  float fist = map(nums.getInt(0, 2), 0, 5500, 0, 80);
  vertex(0, 750-fist);  
  for (int i = 0; i< rows_; i++) {      
    lineH = map(nums.getInt(i, 2), 0, 5500, 0, 80);  
    if (frameCount/frames > i ) {    
      vertex(i*lineW, 750-lineH);
    }
  }   
  endShape();
}

void drawInfo() {  
  textAlign(RIGHT); 

  fill(255); 
  textFont(fontReg); 
  textSize(15);
  text("Outflow of refugees", -15, 606);  
  text("Inflow of refugees", -15, 630);

  for (int j =0; j<rows_; j++) {
    int year = int(nums.getFloat(j, 0));  

    if (j<rows_/2) { 
      float percent1 = norm(j, 0, rows_/2);
      color between1 = lerpColor(#FF536D, #FFFFFF, percent1);
      stroke(between1, 180);
      strokeWeight(1);
      line(j-170, 595, j-170, 610);
    } else { 
      float percent2 = norm(j, rows_/2, rows_);
      color between2 = lerpColor(#FFFFFF, #21D8A8, percent2);         
      stroke(between2, 180); 
      line(j-rows_/2-170, 615, j-rows_/2-170, 630);
    }      

    if (frameCount/frames >= j & frameCount/frames <j+1) {  
      //年份
      textFont(fontBold);        
      textSize(30);  
      fill(255); 
      text(year, -15, 670);  

      //难民数量
      textFont(fontReg);      
      fill(255); 
      textSize(15); 
      text("Number of refugees", -15, 690);   
      textSize(18);
      text(nfc(nums.getInt(j, 1)), -15, 710);  

      //逃亡路径
      fill(#FF536D);       
      textSize(15);    
      text("Number of escape routes", -15, 730);
      textSize(18);
      text(nfc(nums.getInt(j, 2)), -15, 750);
    }
  }
}

void drawRoutes(int tempYear) {
  for (int j= 0; j < rows; j++) {
    float fromLat = map(data.getFloat(j, 2), 90, -90, offset, height - offset );    
    float fromLong = map(data.getFloat(j, 3), -180, 180, offset*2, width - offset*2 );

    float toLat = map(data.getFloat(j, 5), 90, -90, offset, height - offset);
    float toLong = map(data.getFloat(j, 6), -180, 180, offset*2, width - offset*2);
    int awardYear = int(data.getFloat(j, 0));

    if (awardYear == tempYear) {
      distance = dist(toLong, toLat, fromLong, fromLat);
      if (distance < 80) {
        offsetW = 5;
        offsetH = 30;
        offsetZ = 10;
      } else if (distance > 80 && distance < 200) {
        offsetW = 0;
        offsetH = 60;
        offsetZ = 0;
      } else if (distance > 200 && distance <600) {
        offsetW = -50;
        offsetH = 110;
        offsetZ = 40;
      } else if (distance > 600) {
        offsetW = 30;
        offsetH = 200;
        offsetZ = 0;
      }

      if (fromLong > toLong) {
        offsetW = offsetW * -1;
      }

      noFill();
      if (toLong == ptoLong && fromLong == pfromLong) { 
        nationCount++;
      } else { 
        nationCount = 1;
      }

      PVector a = new PVector(fromLong, fromLat);
      PVector b = new PVector(fromLong - offsetW, fromLat - offsetH + nationCount * 2, offsetZ);
      PVector c = new PVector(toLong + offsetW, toLat - offsetH + nationCount * 2, offsetZ);
      PVector d = new PVector(toLong, toLat);

      curve = new BezierCurve(a, b, c, d);

      points = curve.points(POINT_COUNT);
      equidistantPoints = curve.equidistantPoints(POINT_COUNT/10 );
      if (toLong != fromLong) {
        float linew = map(data.getFloat(j, 7), 0, 3300000, 2, 50);
        strokeWeight(linew);
        beginShape(LINES);
        strokeCap(ROUND);
        for (int i = 0; i < points.length -1; i +=1) {
          if (i<points.length/2) { 
            float percent1 = norm(i, 0, points.length/2);
            color between1 = lerpColor(#FF536D, #FFFFFF, percent1);
            stroke(between1, 100);
          } else { 
            float percent2 = norm(i, points.length/2, points.length);
            color between2 = lerpColor(#FFFFFF, #21D8A8, percent2);         
            stroke(between2, 100);
          }
          vertex(points[i].x, points[i].y);
          vertex(points[i+1].x, points[i+1].y);
        }
        endShape();

        // draw moving circles 
        circleStyle();
        float t1 = t;
        if (t > 1 ) {
          t1 = t -1;
        }
        t++;
        PVector pos1 = curve.pointAtParameter(t1);
        pushMatrix();
        translate(pos1.x, pos1.y, pos1.z);
        ellipse(0, 0, 5, 5) ;
        popMatrix();

        //previous a, d;
        ptoLong = toLong;
        pfromLong = fromLong;

        fill(255);
      } // close if
    }// close year if
  }//close for
}

void curveStyle() {
  stroke(255, 241, 0, 60);
  noFill();
}

void circleStyle() {
  noStroke();
  fill(255, 255, 250, 80);
}
