/*
 * Easel
 * CAD Model
 */

include <mcad/units.scad>;

/* Draw the easel plate shape
 * size: Dimensions of easel plate as 3D vector [x, y, z]
 * border_radius: Radius of rounded corners
 */
module plate(size, border_radius = 10 * mm) {
  size_x = size[0];
  size_y = size[1];
  size_z = size[2];

  linear_extrude(size_z)
    translate([0, 0, -size_z])
    difference() {
      // offset to round borders
      translate([border_radius, border_radius])
        offset(r=border_radius) 
        square([size_x - 2 * border_radius, size_y - 2* border_radius]);
      
      // cutout for divider storage
      divider_x = 80 * mm;
      divider_y = 10 * mm;
      translate([size_x / 2 - divider_x / 2 ,size_y - divider_y]) 
        square(size = [divider_x, divider_y + 1 * mm]);
    }
}

/* Draw a easel plate with hinge hole cutouts.
 * size: Dimensions of easel plate as 3D vector [x, y, z]
 * hinge_size: dimensions of the hinge.
 * hinge_offset: offset from the sides of the plate to position hinge holes.
*/
module easel_plate(size, hinge_size = [ 65 * mm, 20 * mm ], hinge_offset = 20 * mm) {
  size_x = size[0];
  size_y = size[1];
  size_z = size[2];
  hinge_x = hinge_size[0];
  hinge_y = hinge_size[1];

  difference() {
    plate(size = size);
    // top left hinge hole
    translate([hinge_offset, size_y - hinge_y, -0.5 * mm])
      cube(size = [hinge_x, hinge_y + 1 * mm, size_z + 1 * mm], center = false);
    // top right hinge hinge hole
    translate([size_x - hinge_offset - hinge_x, size_y - hinge_y, -0.5 * mm]) 
      cube(size = [hinge_x, hinge_y + 1 * mm, size_z + 1 * mm], center = false);
  }
}

/* Draw a grid of holes for seating circular magnets
 * size: Volume bounds as 3D vector [x, y, z] to draw magnet holes within.
 * rows: No. of rows in the grid of magnets.
 * cols: No. of columns in the grid of magnets.
 * diameter: diameter of each magnet hole.
*/
module magnet_holes(size, rows=4, cols = 3, diameter = 8 * mm) {
  size_x = size[0];
  size_y = size[1];
  size_z = size[2];
  
  // draw a grid of magnet holes
  gap_x = size_x / (rows - 1);
  gap_y = size_y / (cols - 1);
  for(x = [0:rows - 1]) {
    for(y =  [0:cols - 1]) {
      translate(v = [
          x * gap_x,
          y * gap_y,
          diameter / 2,
      ]) 
        cylinder(h = size_z, r = diameter / 2, center = true);
   }
  }
}

module easel_bottom(size, magnet_offset = [20 * mm, 20 * mm]) {
  size_x = size[0];
  size_y = size[1];
  size_z = size[2];
  magnet_offset_x = magnet_offset[0];
  magnet_offset_y = magnet_offset[1];


  difference() {
    easel_plate(size = size);
    translate([magnet_offset_x, magnet_offset_y, -(size_z / 2 - 1) * mm])
      magnet_holes(
        size = [
          size_x - 2 * magnet_offset_x, 
          size_y - magnet_offset_y - 50 * mm, 
          size_z + 1 * mm
        ],
        rows = 4,
        cols = 3,
        diameter = 8 * mm
      );
  }
}

module easel() {
  size = [ 280 * mm, 200 * mm, 5 * mm ];
  easel_bottom(size = size);
}

easel();
