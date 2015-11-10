import processing.serial.*;
import java.util.ArrayDeque;
double PIXEL_PER_MM = 1;
int offset_x = 200;
int offset_y = 0;
double BOUNDARY_SIZE_SCALE = 2*PIXEL_PER_MM;
Serial myPort;        // The serial port

ArrayDeque<int[]> targets = new ArrayDeque<int[]>();

int x = 0;
int y = 0;

int target_x = 0;
int target_y = 0;

boolean target_set = false;

void setup () {
  noSmooth();
  // List all the available serial ports
  println(Serial.list());
  // Check the listed serial ports in your machine
  // and use the correct index number in Serial.list()[].

  myPort = new Serial(this, Serial.list()[0], 9600);  //

  // set the window size:
  size(2000, 1600);     
  
  draw_grid();
  stroke(60);
  strokeWeight(10);
  
  noFill();
  rect(600, 600, 1200, 600);
  // A serialEvent() is generated when a newline character is received :
  myPort.bufferUntil('\n');


  //  background(0);      // set inital background: 
  // target line
}
void draw () {
  // everything happens in the serialEvent() except actually drawing; stupid Processing
  int[] aaa;
  while ((aaa = drawQueue.poll()) != null) {
    point(aaa[0], aaa[1]);
  }
}

// save image upon key press of s
void keyPressed() {
  if (key == 's') {
    String savename = new String();
    savename += target_x;
    savename += '_';
    savename += target_y;
    saveFrame(savename);
  }
  else if (key == '0') {
    while (!targets.isEmpty()) {
      int[] whatever = targets.pop();
      myPort.write(Integer.toString(whatever[0]) + "\n");
      myPort.write(Integer.toString(whatever[1]) + "\n");
    }
    myPort.write("0\n0\n");
  }
  // adding in the hoppers
  else if (key == '1') {
    myPort.write("3\n");
    myPort.write("5\n");
    myPort.write("11\n");
    myPort.write("7\n");
  }
  else if (key == '2') {
    myPort.write("10\n");
    myPort.write("12\n");
    myPort.write("18\n");
    myPort.write("7\n");
  }
  else if (key == '3') {
    myPort.write("0\n");
    while (!targets.isEmpty()) {
      int[] whatever = targets.pop();
      myPort.write(Integer.toString(whatever[0]) + "\n");
      myPort.write(Integer.toString(whatever[1]) + "\n");
    }
    myPort.write("0\n0\n");
  }
  // load hopper waypoints
  else if (key == '4') {
    myPort.write("1\n");
    while (!targets.isEmpty()) {
      int[] whatever = targets.pop();
      myPort.write(Integer.toString(whatever[0]) + "\n");
      myPort.write(Integer.toString(whatever[1]) + "\n");
    }
    myPort.write("0\n0\n");
  }
  // set rendezvous x and y
  else if (key == '5') {
    myPort.write("1350\n");
    myPort.write("800\n");
  }
  // set coordinates by clicking
  else if (key == '6') {
    int[] whatever = targets.pop();
    myPort.write(Integer.toString(whatever[0]) + "\n");
    myPort.write(Integer.toString(whatever[1]) + "\n");
  }
}

void mouseReleased() {
  stroke(255);
  strokeWeight(10);
  int tx = (int)((height - (mouseY-offset_x))/PIXEL_PER_MM);
  int ty = (int)((mouseX-offset_y)/PIXEL_PER_MM);
  point(mouseX, mouseY);

  targets.push(new int[]{tx, ty});
  print(tx,ty);
  println("(",mouseX, mouseY,")");
}

boolean isnum(char c) {
  switch (c) {
  case '0': 
  case '1': 
  case '2': 
  case '3': 
  case '4': 
  case '5': 
  case '6': 
  case '7': 
  case '8': 
  case '9': 
    return true;
  default: 
    return false;
  }
}

void draw_grid() {
  stroke(150);
  for (int grid_x = 0; grid_x < height; grid_x += 200*PIXEL_PER_MM)
    line(0,grid_x, width,grid_x);
    
  for (int grid_y = 0; grid_y < width; grid_y += 200*PIXEL_PER_MM)
    line(grid_y, 0, grid_y, height);
}

void plot_target(String target) {
  strokeWeight(10);
  String[] target_pair = splitTokens(target);
  if (target_pair.length < 2) return;
  String string_x = target_pair[0];
  for (int i = 0; i < string_x.length (); ++i)
    if (isnum(string_x.charAt(i))) {
      if (i == 0) target_x = int(string_x);
      else target_x = int(string_x.substring(i-1));
      i = string_x.length();
    }

  target_y = int(target_pair[1].substring(0, target_pair[1].length()));

  print("target x:");
  print(target_x);
  print(" target y:");
  println(target_y);

  strokeWeight(7);
  stroke(127, 55, 127);
  point((int)(PIXEL_PER_MM*(target_y-offset_y)), (int)(height - PIXEL_PER_MM*(target_x-offset_x)));
  stroke(0);
  strokeWeight(5);
}

void plot_boundary(String boundary) {
  String[] boundary_pair = splitTokens(boundary);
  String string_x = boundary_pair[0];
  if (boundary_pair.length < 2) return;
  int boundary_x = 0;
  int boundary_y = 0;
  int boundary_r = 0;
  for (int i = 0; i < string_x.length (); ++i)
    if (isnum(string_x.charAt(i))) {
      if (i == 0) boundary_x = int(string_x);
      else boundary_x = int(string_x.substring(i-1));
      break;
    }
  if (boundary_pair.length == 2)
    boundary_y = int(boundary_pair[1].substring(0, boundary_pair[1].length()-1));
  else {
    boundary_y = int(boundary_pair[1]);
    boundary_r = int(boundary_pair[2].substring(0, boundary_pair[2].length()-1));
  }


  boundary_r *= BOUNDARY_SIZE_SCALE;
  if (boundary_r != 0) strokeWeight(boundary_r);
  else strokeWeight(15);
  stroke(200, 0, 20, 125);
  point((int)(PIXEL_PER_MM*(boundary_y-offset_y)), (int)(height - PIXEL_PER_MM*(boundary_x-offset_x)));
  stroke(0);
  strokeWeight(5);
}
ArrayDeque<int[]> drawQueue = new ArrayDeque<int[]>();

void serialEvent (Serial myPort) {
 
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');

  if (inString != null) {
    print(inString);
    if (inString.charAt(inString.length()-3) == 'E') {
      plot_target(inString);
      target_set = true;
      return;
    } else if (inString.charAt(inString.length()-3) == 'B') {
      plot_boundary(inString);
      return;
    }
    String[] params = splitTokens(inString);
    // not properly formatted
    if (params.length < 3) {
      print("bad format\n");
      return;
    }
    x = int(params[1]);
    y = int(params[2]);
    switch (inString.charAt(0)) {
      case '9':  stroke(255,105,180); strokeWeight(15); break;
      case '4':  stroke(0,0,250); break;
      case '3':  stroke(0,250,0); break;
      case '2':  stroke(0); break;
      case '1':  stroke(250,250,0); break;
      case '0':  stroke(250); break;
      default: break;
    }

    print("point (" + x + "," + y + ")(" + (int)(PIXEL_PER_MM*(y-offset_y)) + "," + (int)(height - PIXEL_PER_MM*(x-offset_x)) + ")\n");
    //point((int)(PIXEL_PER_MM*(y-offset_y)), (int)(height - PIXEL_PER_MM*(x-offset_x)));
    drawQueue.push(new int[] {(int)(PIXEL_PER_MM*(y-offset_y)), (int)(height - PIXEL_PER_MM*(x-offset_x))});
    strokeWeight(5);
  }
}