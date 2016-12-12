import processing.video.*;
import deadpixel.keystone.*;    //see http://keystonep5.sourceforge.net/reference/index.html
import java.io.FilenameFilter;
import java.util.concurrent.TimeUnit;
//set up keystone surfaces
Keystone ks;
CornerPinSurface surfaceL;
CornerPinSurface surfaceR;

Movie m;           //video
PImage cropped;    //image for cropping video
int h=720;   int w=1080;    
//int h=1920;   int w=1080*2;    //output dimensions - across two projectors in portrait orientation
int mh = 720; int mw = 1280;   //video dimensions

int cropX = 320; 
int cropY = 80;
int cropW = 600; 
int cropH = 720-150; 
int splitPoint = cropW / 2;

boolean moviePaused = false; boolean movieMuted = false;
boolean showText = true; String fileName = "no file";
String videoDir = "c:/temp";
boolean adjustCropXY = true;
CornerPinSurface activeSurface; 
int activeCorner;
float moveAmount =10;   //how much to move calibration points by each time

  int fileIndex = 0;
  File dir ;
  File[] files ;
void setup() { 
  size(w, h, P3D);    //1080 x 1920
  
  println(cropH);
  println(cropW);
  
  ks = new Keystone(this);
  surfaceL = ks.createCornerPinSurface(w / 2, h, 20);  
  surfaceR = ks.createCornerPinSurface(w /2, h, 20);
  surfaceR.moveTo(w/2,0);
  activeSurface = surfaceL;
  activeCorner = activeSurface.TL;
  
  dir = new File(videoDir);
  files = dir.listFiles(new FilenameFilter() {
    public boolean accept(File dir, String name) {
        return name.toLowerCase().endsWith(".mp4");
    }
  });
  background(0);
  if(files.length <0){
     text("No videos found",20,20); 
  } else {
    loadVideo(files[fileIndex]);
    cropped = m.get(cropX, cropY, cropW, cropH );   //populate cropped so the first cycle of draw doesn't crash
  }   
}


JSONObject json = new JSONObject();

void loadVideo(File f){
    try {m.stop();} catch (Exception e){}
    m = null;
    m = new Movie(this,f.toString());
    // these don't work
    //mh = m.height;
    //mw = m.width;
    m.loop();
}

void draw() { 
  background(0);
  surfaceL.render(cropped,0,0,splitPoint,cropH); 
 surfaceR.render(cropped,splitPoint,0,cropW-splitPoint,cropH);
 if (showText){
   fill(255,60,60);
   textSize(h / 18);
   
   fileName = files[fileIndex].getName().replaceAll("_"," ").replaceAll("\\.MP4$","");  //.replace("\\.MP4","")
   //int index = fullPath.lastIndexOf(fileName);
   
   long t = (long)(m.time() *1000);
   String time = String.format("%dm%ds", 
      TimeUnit.MILLISECONDS.toMinutes(t),
      TimeUnit.MILLISECONDS.toSeconds(t) - 
      TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(t))
    );
   
   text(fileName + "\n" + time, w /6, h/5); 
 }
  //image(cropped, 0, 0,w,h); 
} 

void movieEvent(Movie m) { 
  m.read(); 
  cropped = m.get(cropX, cropY, cropW, cropH );
} 


void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

   case 'l':
    // loads the saved layout
   if( ks.isCalibrating()){
     ks.load();
     try{
     json = loadJSONObject("data.json");
     splitPoint = json.getInt("splitPoint");
     cropH = json.getInt("cropH");
     cropW = json.getInt("cropW");
     cropX = json.getInt("cropX");
     cropY = json.getInt("cropY");
     println("loaded additional settings");
     } catch (Exception e){}
     
   }
    break;

  case 's':
    // saves the layout
    if(ks.isCalibrating()){
      ks.save();
      json.setInt("splitPoint", splitPoint);
      json.setInt("cropX", cropX);
      json.setInt("cropY", cropY);
      json.setInt("cropH", cropH);
      json.setInt("cropW", cropW);
      saveJSONObject(json,"data.json");
      println("Saved additional settings");
    }
    break;
    
  case 'r':
  m.jump(0);
  break;
  // skip forwards and back
  case 'f':
  println(m.time()+moveAmount);
    println(m.duration());
  m.jump((m.time()+moveAmount < m.duration()) ? m.time()+moveAmount : m.duration());
  if ( moviePaused ){m.loop();movieEvent(m);m.pause();}
  break;
  case 'b':
  
  m.jump(m.time()-moveAmount > 0 ? m.time()-moveAmount : 0);
  if ( moviePaused ){m.loop();movieEvent(m);m.pause();}
  break;
  case 'F':
  m.jump(m.time()+moveAmount*6 < m.duration() ? m.time()+moveAmount*6 : m.duration());
  if ( moviePaused ){m.loop();movieEvent(m);m.pause();}
  break;
  case 'B':
  m.jump(m.time()-moveAmount*6 > 0 ? m.time()-moveAmount*6 : 0);
  if ( moviePaused ){m.loop();movieEvent(m);m.pause();}
  break;  
  
  case ' ':
  if ( moviePaused ){m.loop();} else {m.pause();}
  moviePaused = !moviePaused;
  break;

   case 'q':
  m.speed(2.0);
  break;
   case 'n':
  case 'a':
  m.speed(1.0);
  break;
  case 'z':
  m.speed(0.5);
  break;
  
  //cycle videos
  case '[':
    fileIndex--;
    if (fileIndex < 0){fileIndex = files.length -1;}
    loadVideo(files[fileIndex]);
    break;  
  case ']':
    fileIndex++;
    if (fileIndex >= files.length){fileIndex = 0;}
    loadVideo(files[fileIndex]);
     break;
  
  case 't':
    showText = !showText;
    break;
     
  case '/':    activeSurface = surfaceL; break;  
  case '*':    activeSurface = surfaceR; break;  
  case '#' : adjustCropXY = !adjustCropXY; break;
  case '-':   
    moveAmount = 1; 
    break;  
  case '+':
    moveAmount = 10; 
    break; 
  case 'm':
    m.volume(movieMuted ? 1: 0);
    movieMuted = ! movieMuted;
    break;
  case '1':    activeCorner = CornerPinSurface.BL; break;
  case '3':    activeCorner = CornerPinSurface.BR; break;
  case '7':    activeCorner = CornerPinSurface.TL; break;
  case '9':    activeCorner = CornerPinSurface.TR; break;

  //allow the split point to be moved
  case ',':    if (ks.isCalibrating()){ splitPoint = splitPoint +(int)moveAmount ; if (splitPoint <0){splitPoint = 0;}   }break;
  case '.':    if (ks.isCalibrating()){ splitPoint = splitPoint -(int)moveAmount ; if (splitPoint > cropW){splitPoint = cropW;}   }break;
  
  case '2':    if (ks.isCalibrating()){ moveCorner(activeSurface,activeCorner,0,moveAmount);   }break;
  case '4':    if (ks.isCalibrating()){ moveCorner(activeSurface,activeCorner,-moveAmount,0);   }break;
  case '6':    if (ks.isCalibrating()){ moveCorner(activeSurface,activeCorner,moveAmount,0);   }break;
  case '8':    if (ks.isCalibrating()){ moveCorner(activeSurface,activeCorner,0,-moveAmount);  }break;
  
  // stuff for adjusting movie cropping
  case CODED: 
    if (ks.isCalibrating()){
      if (adjustCropXY){
        if (keyCode == DOWN) {
          cropY -= moveAmount;
          if (cropY < 0){cropY = 0;}
        } else if (keyCode == UP) {        
          cropY += moveAmount;
          if (cropY > mh - cropH){cropY = mh - cropH;}
        } else if (keyCode == RIGHT) {
          cropX -= moveAmount;
          if (cropX < 0 ){cropX = 0;}
        } else if (keyCode == LEFT) {
          cropX += moveAmount;
          if (cropX > mw - cropW ){cropX = mw - cropW;}
        }
      } else {
        if (keyCode == DOWN) {
          cropH -= moveAmount;
          if (cropH < 1){cropH = 1;}      
        } else if (keyCode == UP) {
          cropH += moveAmount;
          if (cropH > mh -cropY){cropH = mh -cropY;}
        } else if (keyCode == RIGHT) {
          cropW -= moveAmount;
          if (cropW < 1){cropW = 1;}
        } else if (keyCode == LEFT) {
          cropW += moveAmount;
          if (cropW > mw -cropX){cropW = mw -cropX;}
        }       
        
      }
    }
    break;
  

  } 
}

 void moveCorner(CornerPinSurface surface, int activeCorner, float x, float y){
    // for some reason the movemeshpointby method thinks the surface shoudl be at zero, zero
    // - so add the surface.x and surface.y to cancel out
    surface.moveMeshPointBy(activeCorner, x+surface.x, y+surface.y);
  }
