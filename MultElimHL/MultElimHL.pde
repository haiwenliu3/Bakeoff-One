import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;
import java.util.HashMap;

//when in doubt, consult the Processsing reference: https://processing.org/reference/

int margin = 200; //set the margin around the squares
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 40; // padding between buttons and also their width/height
ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
int trialNum = 0; //the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks
Robot robot; //initalized in setup 

boolean hit = false;

int numRepeats = 2; //sets the number of times each button repeats in the test

HashMap<Integer,Integer> buttonsHit = new HashMap();

HashMap<Integer, Integer> butt = new HashMap(0, 1);


void setup()
{
  size(700, 700); // set the size of the window
  //noCursor(); //hides the system cursor if you want
  noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
  //rectMode(CENTER); //enabling will break the scaffold code, but you might find it easier to work with centered rects

  try {
    robot = new Robot(); //create a "Java Robot" class that can move the system cursor
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }

  //===DON'T MODIFY MY RANDOM ORDERING CODE==
  for (int i = 0; i < 16; i++) //generate list of targets and randomize the order
      // number of buttons in 4x4 grid
    for (int k = 0; k < numRepeats; k++)
      // number of times each button repeats
      trials.add(i);

  Collections.shuffle(trials); // randomize the order of the buttons
  System.out.println("trial order: " + trials);
  
  frame.setLocation(0,0); // put window in top left corner of screen (doesn't always work)
  
  for (int i = 0; i < 16; i++)
    buttonsHit.put(i, 0);
}


void draw()
{
  background(0); //set background to black

  if (trialNum >= trials.size()) //check to see if test is over
  {
    float timeTaken = (finishTime-startTime) / 1000f;
    float penalty = constrain(((95f-((float)hits*100f/(float)(hits+misses)))*.2f),0,100);
    fill(255); //set fill color to white
    //write to screen (not console)
    text("Finished!", width / 2, height / 2); 
    text("Hits: " + hits, width / 2, height / 2 + 20);
    text("Misses: " + misses, width / 2, height / 2 + 40);
    text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, height / 2 + 60);
    text("Total time taken: " + timeTaken + " sec", width / 2, height / 2 + 80);
    text("Average time for each button: " + nf((timeTaken)/(float)(hits+misses),0,3) + " sec", width / 2, height / 2 + 100);
    text("Average time for each button + penalty: " + nf(((timeTaken)/(float)(hits+misses) + penalty),0,3) + " sec", width / 2, height / 2 + 140);
    return; //return, nothing else to do now test is over
  }

  fill(255); //set fill color to white
  text((trialNum + 1) + " of " + trials.size(), 40, 20); //display what trial the user is on

  for (int i = 0; i < 16; i++)// for all button
    drawButton(i); //draw button

  fill(255, 0, 0, 200); // set fill color to translucent red
  ellipse(mouseX, mouseY, 20, 20); //draw user cursor as a circle with a diameter of 20
  
  Rectangle bounds = getButtonLocation(trials.get(trialNum));
  
  stroke(255);  //draw a line from cursor to target
  line(mouseX, mouseY, bounds.x + (bounds.width/2), bounds.y+(bounds.height/2));
}

void mousePressed() // test to see if hit was in target!
{  
  
  /*
  Rectangle bounds1 = getButtonLocation(1);
  Rectangle bounds2 = getButtonLocation(2);
  
  int dist = bounds2.x - bounds1.x;
  
  System.out.println("mouse location");
  System.out.println(mouseX);
  System.out.println(mouseY);
  
  System.out.println("distance calc");
  System.out.println(bounds2.x);
  System.out.println(bounds1.x);
  
  System.out.println(dist);
  */
  
  if (trialNum >= trials.size()) //if task is over, just return
    return;

  if (trialNum == 0) //check if first click, if so, start timer
    startTime = millis();

  if (trialNum == trials.size() - 1) //check if final click
  {
    finishTime = millis();
    //write to terminal some output. Useful for debugging too.
    println("we're done!");
  }

  Rectangle bounds = getButtonLocation(trials.get(trialNum));
  
  /**
   * counts as within bounds if nearest the correct button
   * padding is 50 between buttons, so halfway between is 50/2 = 25
  **/
  int xLowerLimit = bounds.x - 25;
  int xUpperLimit = bounds.x + bounds.width + 25;
  
  int yLowerLimit = bounds.y - 25;
  int yUpperLimit = bounds.y + bounds.height + 25;

 //check to see if mouse cursor is inside button 
  if ((mouseX >= xLowerLimit && mouseX <= xUpperLimit) && (mouseY >= yLowerLimit && mouseY <= yUpperLimit)) // test to see if hit was within bounds
  {
    System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
    hits++;
    hit = true;
    buttonsHit.put(trials.get(trialNum), buttonsHit.get(trials.get(trialNum)) + 1);
    trialNum++; //Increment trial number
  } 
  else
  {
    //System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
    //misses++;
    hit = false;
  }


  //in this example code, we move the mouse back to the middle
  //robot.mouseMove(width/2, (height)/2); //on click, move cursor to roughly center of window!
}  

//probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
   int x = (i % 4) * (padding + buttonSize) + margin;
   int y = (i / 4) * (padding + buttonSize) + margin;
   return new Rectangle(x, y, buttonSize, buttonSize);
}

//you can edit this method to change how buttons appear
void drawButton(int i)
{
  Rectangle bounds = getButtonLocation(i);

  if (trials.get(trialNum) == i) // see if current button is the target
    fill(255,105,180); // if so, fill hotpink
    
  else if (trialNum != trials.size() - 1 && trials.get(trialNum+1) == i)
    fill(50,50,50); //fill next button dark grey
    
  else if (buttonsHit.get(i) == numRepeats)
    fill(208, 240, 192);
    
  else
    fill(200); // if not, fill gray

  rect(bounds.x, bounds.y, bounds.width, bounds.height); //draw button
}

void mouseMoved()
{
   //can do stuff everytime the mouse is moved (i.e., not clicked)
   //https://processing.org/reference/mouseMoved_.html
}

void mouseDragged()
{
  //can do stuff everytime the mouse is dragged
  //https://processing.org/reference/mouseDragged_.html
}

void keyPressed() 
{
  //can use the keyboard if you wish
  //https://processing.org/reference/keyTyped_.html
  //https://processing.org/reference/keyCode.html
}
