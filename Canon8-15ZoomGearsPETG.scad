
$fn=82*4;       // Smooth cylinders

ActualRadius      = 84.34 / 2; // Make corrections here to achieve correct OuterRadius of gear teeth.
ActualInnerRadius = 73.30 / 2; // Make corrections here to achieve correct InnerRadius of grasping cylinder.

OuterRadius       = 83.90 / 2; // These are the desired dimensions and may need to be measured and adjusted as above      
InnerRadius       = 71.71 / 2; // These are the desired dimensions and may need to be measured and adjusted as above      

Height            = 6.0;       // The height of the housings gearing.
NumberOfTeeth     = 82;        // Copied from a purchased Canon 17-40mm ring gear.
ToothBevelWidth   = 1.0;       // Make gear engagement easier.
GearWallThickness = 1.15;      // The measured usable wall space at the ring gear.

LensClearRadius   = 76.16 / 2;  // Clearance for the lens body autofocus and limit switches. 

// Make correction due to systematic printing errors
OuterCorrection          = OuterRadius / ActualRadius;

union()
{
  // Upper Grasp Ring
  difference()
  {  
    translate([0,0,3*Height]) graspRing();
    // Top Grasp Ring Bevel
    rotate_extrude(angle=360,convexity=10)
      polygon(points = [
        [LensClearRadius+1.5*GearWallThickness,4*Height-GearWallThickness],
        [LensClearRadius+0.5*GearWallThickness,4*Height],
        [LensClearRadius+1.5*GearWallThickness,4*Height]]
      );
  }    
  // Lower Grasp Ring  
  union()
  { 
    // Grasp Ring Positioning  
    translate([0,0,2*Height]) graspRing();
    // Grasp Ring Inner to Gear Ring Inner Bevel  
    rotate_extrude(angle=360,convexity=10)
      polygon(points = [
        [LensClearRadius,2*Height-(LensClearRadius-InnerRadius)],
        [InnerRadius,2*Height],
        [LensClearRadius,2*Height]]
      );
    rotate_extrude(angle=360,convexity=10)
      polygon(points = [
        [LensClearRadius+GearWallThickness,2*Height+(LensClearRadius-InnerRadius)],
        [OuterRadius-ToothBevelWidth,2*Height],
        [LensClearRadius+GearWallThickness,2*Height]]
      );
  }
  // Gear Ring
  difference()
  {
    //Gear Ring Positioning  
    translate([0,0,Height])
    {
      gear(m = OuterCorrection, z = NumberOfTeeth, x = 0, h = 2*Height, w = 20, clearance = 0.1, center = true);
    }
    // Gear Ring Lens Clearance     
    cylinder(r = LensClearRadius, h = 2*Height);
    // Bottom Gear Teeth Bevel
    rotate_extrude(angle=360,convexity=10)
      polygon(points = [
        [OuterRadius-ToothBevelWidth,0],
        [OuterRadius,0],
        [OuterRadius,ToothBevelWidth]]
      );
    // Top Gear Teeth Bevel
    rotate_extrude(angle=360,convexity=10)
      polygon(points = [
        [OuterRadius,2*Height-ToothBevelWidth],
        [OuterRadius-ToothBevelWidth,2*Height],
        [OuterRadius,2*Height]]
      );
  }
}
module graspRing()
difference()
{
  difference()
  {
    cylinder(r = LensClearRadius+GearWallThickness,h = Height);
    cylinder(r = InnerRadius, h = Height);
  }
}  

module gear(m = 1, z = 10, x = 0, h = 4, w = 20, clearance = 0.1, center = true)
{
	linear_extrude(height = h, center = center, convexity = z)
    gear2D(m, z, x, w, clearance); 
}


//==============================================================
// 2D Gear Stuff
// Courtesy of Rudolf Huttary (Parkinbot)
// https://www.thingiverse.com/thing:636119
//==============================================================

iterations = 150; // increase for enhanced resolution beware: large numbers will take lots of time!

// default values
z = 10; // teeth - beware: large numbers may take lots of time!
m = 1;  // modulus
x = 0;  // profile shift
h = 6;  // face_width	respectively axial height
w = 20; // profile angle
clearance = 0.1; // assymmetry of tool to clear tooth head and foot. For internal splines use -.1

module gear2D(m = 1, z = 10, x = 0, w = 20, clearance = 0.1)
{
  	r_wk = m*z/2 + x; 
    U = m*z*PI; 
   	dy = m;  
  	r_fkc = r_wk + dy *(1-clearance/2);  
  s = 360/iterations; 
  difference()
  {
    circle(r_fkc, $fn=300);  // workpiece
    for(i=[0:s:360])
      rotate([0, 0, -i])
      translate([-i/360*U, 0, 0])
      Rack(m, z, x, w, clearance);  // Tool
  }
}

module Rack(m = 1, z = 10, x = 0, w = 20, clearance = 0)
  {
    p = m*PI; 
    dy = 2*m;  
    dx = dy * tan(w);  
    ddx = dx/2 * clearance/2; 
    ddy = dy/2 * clearance/2; 
    r_wk = m*z/2 + x; 
    y0 = r_wk+dy; 
    y1 = r_wk+dy/2-ddy; 
    y2 = r_wk+dy/2 - ddy; 
    y3 = r_wk-dy/2 - ddy; 
    x0 = p/4-dx/2 + ddx; 
    x1 = p/4+dx/2 + ddx; 
    x2 = 3*p/4-dx/2 - ddx; 
    x3 = 3*p/4+dx/2 - ddx; 
    polygon(points = tooth(z));
    
    function tooth(z = 10) = concat([[-p, y0],[-p, y1]],  
		[for(i=[-1:z], j=[0:3]) to(i*p)[j]], [[(z+1)*p, y1], [(z+1)*p, y0]]); 
      
    function to(dx) = [[dx+x0, y2], [dx+x1, y3], [dx+x2, y3], [dx+x3, y2]]; 
}
