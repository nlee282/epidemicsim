int numDots = 100; // number of dots
int radius = 4; // radius of a dot
int spread = 12; // radius for an infected dot to infect
float spreadChance = 0.7; // percentage that a dot in an infected dots spread radius will get infected
float mortalityRate = 0.011; // chance of death for infected
int recoveryTime = 7000; // time before recovered (MILLISECONDS; 1 second = 1000 milliseconds)
int originallyInfected = 4; // amount of dots to be infected when sim starts
int quarintineTime = 3000;
int quarintineRecovery = 5000;
int timebeforecontagious = 2000;
// >>> TWEAK VARIABLES ABOVE <<< //


int rectX = 100;
int rectY = 150;
int rectWidth = 600;
int rectHeight = 600;

int quarintinerectX = 350;
int quarintinerectY = 40;
int quarintinerectWidth = 100;
int quarintinerectHeight = 100;

Dot[] dots = new Dot[numDots];
int numHealthyDots = 0;
int numInfectedDots = 0;
int numRecoveredDots = 0;
int deadDots = 0;
int quarintinedDots = 0;

float pauseDelay = 0;

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
  int totalContacts = 0;
  background(0, 0, 0);
  stroke(1);
  noFill();
  stroke(255, 255, 255);
  rect(100, 150, 600, 600);
  rect(350, 40, 100, 100);
  
  numHealthyDots = 0;
  numInfectedDots = 0;
  numRecoveredDots = 0;
  deadDots = 0;
  quarintinedDots = 0;
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
    } else if (d.state == 3) {
      deadDots++;
      
    } else if (d.state == 4) {
      quarintinedDots++;
    }
    if (d.state == 1) {
        totalContacts += d.contacts;
    }
 
    
  }
  // Print the number of dots in each state
  fill(255, 255, 255);
  text("Healthy dots: " + numHealthyDots, 10, 10);
  text("Infected dots: " + numInfectedDots, 10, 30);
  text("Recovered dots: " + numRecoveredDots, 10, 50);
  text("Dead: " + deadDots, 10, 70);
  float averageContacts = numInfectedDots > 0 ? (float) totalContacts / numInfectedDots : 0;
  fill(255, 255, 255);
  //text("Average Contacts Per Dot: " + averageContacts, 10, 90);
  text("Quarintined: " + quarintinedDots, 10, 90);
  text("r0: " + averageContacts*(recoveryTime/1000), 10, 110);
  //text("Spread percent: "  + spreadChance, 120, 10);
  //text("Death percent: "  + mortalityRate, 120, 30);
  //text("Recovery time: "  + recoveryTime, 120, 50);
}

boolean paused = false;


public void keyPressed() {

  if ( key == 'p' ) {

    paused = !paused;

    if (paused) {
      noLoop();
      pauseDelay = millis();
    } else {
      loop();
      pauseDelay = millis() - pauseDelay;
    }
  }
}

class Dot {
  float x, y, vx, vy;
  color dotColor = color(71, 209, 255);
  long infectedTime;
  int state = 0; // 0 - healthy, 1 - infected, 2 - recovered, 3 - dead or quarintined
  int contacts = 0;
  boolean alreadyQuarintined;
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
    } else if (state == 4) {
      x = 360;
      y = 70;
    }
  }

  void update() {
    if (state != 4) {
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
    } else if (state == 4) {
        x += vx;
        y += vy;
        if (x < quarintinerectX || x > quarintinerectX + quarintinerectWidth) {
          vx *= -1;
        } 
        // Bounce off top/bottom walls
        if (y < quarintinerectY || y > quarintinerectY + quarintinerectHeight) {
          vy *= -1;
        } 
        
        if (x < radius || x > width - radius) {
          vx *= -1;
        }
        if (y < radius || y > height - radius) {
          vy *= -1; 
        }
    }
  }

  void checkCollision(Dot[] others) {
    for (Dot other : others) {
      if (other != this && dist(x, y, other.x, other.y) < 2 * spread) {
        if (random(1) < spreadChance && millis() - pauseDelay - other.infectedTime>timebeforecontagious) {
          if (other.state == 1 && state == 0) {
            setState(1); // Set the dot as infected
            other.contacts++; // Increment the number of contacts for the infected dot
           }
         }
       }
     }
   }

  void display() {
    if (state == 1 && millis() - pauseDelay - infectedTime > quarintineTime && alreadyQuarintined != true) {
      setState(4);
    }
    if (state == 1 && millis() - pauseDelay - infectedTime > recoveryTime) {
      if (random(1) > mortalityRate) {
        setState(2); // Set the dot as recovered (gray color)
      } else {
        setState(3);
      }
    }
    if (state == 4 && millis() - pauseDelay - infectedTime > recoveryTime) {
      if (random(1) > mortalityRate) {
        dotColor = color(115, 115, 115);
      } else {
        dotColor = color(0, 0, 0);
        
      }
      
    }
    if (state == 4 && millis() - pauseDelay - infectedTime > quarintineRecovery+quarintineTime) {
      if (dotColor == color(115, 115, 115)) {
        setState(2);
        alreadyQuarintined = true;
      } else if (dotColor == color(255, 0, 0)) {
        setState(1);
        alreadyQuarintined = true;
      }
      x = 400;
      y = 400;
    }
    noStroke();
    fill(dotColor);
    ellipse(x, y, 2 * radius, 2 * radius);
  }
}
