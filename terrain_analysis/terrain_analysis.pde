MySurface ter;
Ray  ray = new Ray(new PVector(-13,13,15),new PVector(-2,0,-5)); //30,0,5 8
PVector centerPoint = new PVector();
PVector mousePoint = new PVector();

void setup() 
{ 
  size(900, 900, P3D); 
  strokeWeight(1); 
  colorMode(RGB, 1); 
  camera(0,0,2000,0,0,0,0,1,0); //2000
  ter = loadTer();
} 

void draw(){ 
  
  background(0.5);
  ter.draw();
  
  mousePoint = getMouseSurfIntersection(ter);

  fill(0);
  textSize(50);
  text("height: "+(mousePoint.z)+"m", -1090, -1090); 
  text("FPS: "+ frameRate, 900, -1090);
  
  fill(0.8,0.2,0.0);
  pushStyle();
      strokeWeight(20);
      point(centerPoint.x,centerPoint.y,centerPoint.z);
  popStyle();
  
 // ViewShade(); 
}

void keyPressed() {
  ViewShade();
//  angle();  
}

void mousePressed() {
  if (mouseButton == LEFT) {
    centerPoint = mousePoint;
    ray.setStart(centerPoint);
  } else if (mouseButton == RIGHT) {

  } else {

  }
}

void angle() {
  PVector zV = new PVector(0,0,1);
  for(int i = 0; i < ter.nfaces; i++) {
    float a = degrees(PVector.angleBetween(zV, ter.faces[i].n));
    
    ter.faces[i].f = color(map(a,0,90,0,1));
    
/*    
    if(a > 0 && a < 5)
      ter.faces[i].f = color(0.5);
    else if (a > 5 && a < 10)
      ter.faces[i].f = color(0.5);    
    else if (a > 5 && a < 10)      
    */
    //println(a);
  }
}

MySurface loadTer()
{
  MySurface terrain;
  
  String[] txtVtx = loadStrings("MeshVertex.txt");
  String[] txtNdx = loadStrings("MeshIndex.txt");
 // println(txtVtx.length);
 // println(txtNdx.length);

  
  terrain = new MySurface(txtVtx, txtNdx);
  return terrain;
}

void ViewShade() {
  for(int i = 0; i < ter.nfaces; i++ ){
    ray.setEnd(ter.faces[i].c);
    //println(ter.faces[i].c);
    float d = PVector.dist(ray.start, ray.end);
    //println(d);
    int r = 1000;

    if(d > r) { //RayCrossSurface(ray, ter)
      //println("unvisible");
      //line(ray.start.x,ray.start.y,ray.start.z,ray.end.x,ray.end.y,ray.end.z);
        ter.faces[i].f = color(0.8,0.2,0.0);
        ter.faces[i].isVisible = false;
        //ter.points[i].c = color(0.0);
    }
    else {
     // ter.faces[i].f = color(1);
      //println("visible");
      if(!RayCrossSurface(ray, ter)){
         //ter.faces[i].f = color(0);
        //!
//        ter.faces[i].f = color(0);
        //map(mouseX, 0, width, -30, 30)
        ter.faces[i].f = color(map(d,r,0,0.8,1),map(d,r,0,0.2,1),norm(d,r,0));
        ter.faces[i].isVisible = false;
//        ter.faces[i].f = color(0);
        //ter.points[i].c = color(norm(d,r,0));
        //ter.points[i].c = color(1.);
      }
     else {
       ter.faces[i].f = color(0.8,0.2,0.0);//0.8,0.2,0.0
       ter.faces[i].isVisible = false;
     }
    }
    
  }
}

//http://www.openprocessing.org/sketch/12681
boolean SameSide(PVector p1,PVector p2, PVector a, PVector b){
  PVector cp1, cp2;
  b = PVector.sub(b,a);
  p1 = PVector.sub(p1,a);
  p2 = PVector.sub(p2,a);
  
  cp1 = b.cross(p1);
  cp2 = b.cross(p2);
 
  if ((cp1.dot(cp2)) >= 0) {
    return true;
  }
  else
    return false;
}

boolean PointInTriangle(PVector p,PVector a,PVector b,PVector c) {
  if (SameSide(p,a, b,c) && SameSide(p,b, a,c) && SameSide(p,c, a,b)) {
    //fill(255,0,0);
    return true;
  }
  else
    //fill(255,255,255);
  return false;
}

boolean RayCrossSurface(Ray r, MySurface s) {
  //http://paulbourke.net/geometry/planeline/
  //line to plane intersection u = N dot ( P3 - P1 ) / N dot (P2 - P1), P = P1 + u (P2-P1), where P1,P2 are on the line and P3 is a point on the plane
 
  for(int i = 0; i < s.nfaces; i++ ){
   
    if(r.end == s.faces[i].c)
      continue;  
      
    if(PVector.dist(r.start, s.faces[i].c) > 1000)
      continue;
   
    PVector P2SubP1 = PVector.sub(r.end,r.start);
    PVector P3SubP1 = PVector.sub(s.faces[i].c,r.start); //s.faces[i].points[0].pv   
    float u = s.faces[i].n.dot(P3SubP1) / s.faces[i].n.dot(P2SubP1);
    PVector p = PVector.add(r.start,PVector.mult(P2SubP1,u));

    if (PointInTriangle(p, s.faces[i].points[0].pv, s.faces[i].points[1].pv, s.faces[i].points[2].pv)) {
      pushStyle();
      stroke(0,0,192);
      strokeWeight(0.5);
      line(ray.start.x,ray.start.y,ray.start.z,p.x,p.y,p.z);     
      strokeWeight(1);
      point(p.x,p.y,p.z);
      popStyle();     
      return true;
    }
  }
  
  return false;
}

PVector getMouseSurfIntersection(MySurface s) {
  PVector intr = getMouseGroundPlaneIntersection(0,0,2000,0,0,0,0,1,0);
  Ray r = new Ray(new PVector(intr.x,intr.y,500.),new PVector(intr.x,intr.y,-500.));
  
  for(int i = 0; i < s.nfaces; i++ ){
    PVector P2SubP1 = PVector.sub(r.end,r.start);
    PVector P3SubP1 = PVector.sub(s.faces[i].points[0].pv,r.start);
    float u = s.faces[i].n.dot(P3SubP1) / s.faces[i].n.dot(P2SubP1);
    PVector p = PVector.add(r.start,PVector.mult(P2SubP1,u));
   
    if (PointInTriangle(p, s.faces[i].points[0].pv, s.faces[i].points[1].pv, s.faces[i].points[2].pv)) {
      pushStyle();
      strokeWeight(20);
      p.z += 20; // 5 meters above surface
      point(p.x,p.y,p.z);
      popStyle();
      return p;
    }
  }
  return intr;  
}


PVector getMouseGroundPlaneIntersection(float eyeX, float eyeY, float eyeZ,
      float centerX, float centerY,
      float centerZ, float upX, float upY, float upZ) {
  //generate the required vectors
  PVector eye = new PVector(eyeX, eyeY, eyeZ);
  PVector center = new PVector(centerX, centerY, centerZ);
  PVector look = PVector.sub(center, eye); //
  look.normalize();
  PVector up = new PVector(upX, upY, upZ);
  up.normalize();
  PVector left = up.cross(look); ////.normalize()

  //calculate the distance between the mouseplane and the eye
  float distanceEyeMousePlane = (height / 2) / tan(PI / 6);

  //calculate the vector, that points from the eye
  //to the clicked point, the mouse is on
  PVector mousePoint = look.get();
  mousePoint.mult(distanceEyeMousePlane);
  left.mult((float)((mouseX-width/2)*-1));
  mousePoint.add(left); // = mousePoint
  up.mult((float)(mouseY-height/2));
  mousePoint.add(up);

  PVector intersection = new PVector();
  if (mousePoint.z != 0) { //avoid zero division
    //calculate the value, the vector that points to the mouse
    //must be multiplied with to reach the XY-plane
    float multiplier = -eye.z / mousePoint.z;
    //do not calculate intersections behind the camera
    if (multiplier > 0) { 
      //add the multiplied mouse point vector
      mousePoint.mult(multiplier);
      intersection = PVector.add(eye, mousePoint);  
    }
  }
  return intersection;
} 
