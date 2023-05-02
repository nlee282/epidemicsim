int numDots = 200;
float radius = 4;
int spread = 6;
float spreadChance = 0.5;

Dot[] dots = new Dot[numDots];
int numHealthyDots = 0;
int numInfectedDots = 0;
int numRecoveredDots = 0;

void setup() {
  size(800, 800);
  for (int i = 0; i < numDots; i++) {
    dots[i] = new Dot(random(width), random(height), random(-2, 2), random(-2, 2));
  }

  int infectedIndex = int(random(numDots));
  dots[infectedIndex].setState(1); // Set the initial infected dot
}

void draw() {
  background(255, 255, 255);
  numHealthyDots = 0;
  numInfectedDots = 0;
  numRecoveredDots = 0;
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
    }
  }
  // Print the number of dots in each state
  text("Healthy dots: " + numHealthyDots, 10, 10);
  text("Infected dots: " + numInfectedDots, 10, 30);
  text("Recovered dots: " + numRecoveredDots, 10, 50);
}

class Dot {
  float x, y, vx, vy;
  color dotColor = color(71, 191, 255);
  long infectedTime;
  int state = 0; // 0 - healthy, 1 - infected, 2 - recovered

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
      dotColor = color(127, 127, 127);
    }
  }

  void update() {
    x += vx;
    y += vy;

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
        if (random(1) > spreadChance) {
          if (other.state == 1 && state == 0) {
            setState(1); // Set the dot as infected
          }
        }
      }
    }
  }

  void display() {
    if (state == 1 && millis() - infectedTime > 7000) {
      setState(2); // Set the dot as recovered (gray color)
    }
    fill(dotColor);
    ellipse(x, y, 2 * radius, 2 * radius);
  }
}
