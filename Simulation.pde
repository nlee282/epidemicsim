int numDots = 100; // number of dots
float radius = 4; // radius of a dot
int spread = 12; // radius for an infected dot to infect
float spreadChance = 0.7; // percentage that a dot in an infected dots spread radius will get infected
float mortalityRate = 0.01; // chance of death for infected
int recoveryTime = 7000; // time before recovered (MILLISECONDS; 1 second = 1000 milliseconds)
int originallyInfected = 4; // amount of dots to be infected when sim starts
int timebeforecontagious = 2000;

// >>> TWEAK VARIABLES ABOVE <<< //


int rectX = 100;  // x position of the rectangle
int rectY = 150;  // y position of the rectangle
int rectWidth = 600; // width of the rectangle
float rectHeight = 600; // height of the rectangle

Dot[] dots = new Dot[numDots];
int numHealthyDots = 0;
int numInfectedDots = 0;
int numRecoveredDots = 0;
int deadDots = 0;

int totalContacts = 0;
float r = 0;
float peakR = 0;

void setup() {
  size(800, 800);
  
  
  for (int i = 0; i < numDots; i++) {
    float x = random(rectX, rectX + rectWidth);
    float y = random(rectY, rectY + rectHeight);
    dots[i] = new Dot(x, y, random(-1, 1), random(-1, 1));
  } 

  for (int i = 0; i<originallyInfected; i++) {
    dots[i].setState(1); // Set the initial infected dot
  }
}

void draw() {
  
  background(0, 0, 0);
  stroke(1);
  noFill();
  stroke(255, 255, 255);
  rect(100, 150, 600, 600);
  
  
  numHealthyDots = 0;
  numInfectedDots = 0;
  numRecoveredDots = 0;
  deadDots = 0;
  totalContacts = 0;
  for (Dot d : dots) {
    d.update();
    d.checkCollision(dots);
    d.display();
    if (d.state == 0) {
      numHealthyDots++;
    } else if (d.state == 1) {
      numInfectedDots++;
    } else if (d.state == 2) {
      numRecoveredDots++;
      totalContacts += d.contacts;
    } else if (d.state == 3) {
      deadDots++;
      totalContacts += d.contacts;
      
    }
    //totalContacts += d.contacts;
   
 
    
  }
  
  if (numRecoveredDots != 0) {
    r = float(totalContacts)/(numRecoveredDots+deadDots);
  }
  if (peakR < r) {
    peakR = r;
  }
  // Print the number of dots in each state
  fill(255, 255, 255);
  text("Healthy dots: " + numHealthyDots, 10, 10);
  text("Infected dots: " + numInfectedDots, 10, 30);
  text("Recovered dots: " + numRecoveredDots, 10, 50);
  text("Dead: " + deadDots, 10, 70);
  text("r0: " + r, 10, 90);
  text("Peak r0: " + peakR, 10, 110);
  fill(255, 255, 255);
  
  //text("Spread percent: "  + spreadChance, 120, 10);
  //text("Death percent: "  + mortalityRate, 120, 30);
  //text("Recovery time: "  + recoveryTime, 120, 50);
}

class Dot {
  float x, y, vx, vy;
  color dotColor = color(71, 209, 255);
  long infectedTime;
  int state = 0; // 0 - healthy, 1 - infected, 2 - recovered, 3 - dead or quarintined
  int contacts = 0;
  
  Dot(float x, float y, float vx, float vy) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
  }

  void setState(int newState) {
    state = newState;
    if (state == 1) {
      dotColor = color(255, 0, 0);
      infectedTime = millis();
    } else if (state == 2) {
      dotColor = color(115, 115, 115);
    } else if (state == 3) {
      dotColor = color(0, 0, 0);
    }
  }

  void update() {
    x += vx;
    y += vy;
    if (x < rectX || x > rectX + rectWidth) {
      vx *= -1;
    } 
    // Bounce off top/bottom walls
    if (y < rectY || y > rectY + rectHeight) {
      vy *= -1;
    } 
    
    if (x < radius || x > width - radius) {
      vx *= -1;
    }
    if (y < radius || y > height - radius) {
      vy *= -1; 
    }
  } 

  void checkCollision(Dot[] others) {
    for (Dot other : others) {
      if (other != this && dist(x, y, other.x, other.y) < 2 * spread) {
        if (random(1) < spreadChance && millis() - infectedTime > timebeforecontagious) {
          if (other.state == 1 && state == 0) {
            setState(1); // Set the dot as infected
            other.contacts++;
            
            
           }
         }
       }
     }
   }

  void display() {
    if (state == 1 && millis() - infectedTime > recoveryTime) {
      if (random(1) > mortalityRate) {
        setState(2); // Set the dot as recovered (gray color)
      } else {
        setState(3);
      }
    }
    noStroke();
    fill(dotColor);
    ellipse(x, y, 2 * radius, 2 * radius);
  }
}
