/*
 * Easel
 * CAD Model
 */

include <mcad/units.scad>;
include <mcad/materials.scad>;

/* Draw the easel plate shape
 * size: Dimensions of easel plate as 3D vector [x, y, z]
 * border_radius: Radius of rounded corners
 */
module plate(size, border_radius = 8 * mm) {
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
      divider_y = 12 * mm;
      translate([size_x / 2 - divider_x / 2 ,size_y - divider_y]) 
        square(size = [divider_x, divider_y + 1 * mm]);
    }
}

/* Draw a easel plate with hinge hole cutouts.
 * size: Dimensions of easel plate as 3D vector [x, y, z]
 * hinge_size: dimensions of the hinge.
 * hinge_offset: offset from the sides of the plate to position hinge holes.
*/
module easel_plate(size,  hinge_size = [ 65 * mm, 20 * mm ], hinge_offset = 20 * mm) {
  size_x = size[0];
  size_y = size[1];
  size_z = size[2];
  hinge_x = hinge_size[0];
  hinge_y = hinge_size[1];

  difference() {
    plate(size = size);
    // top left hinge hole
    translate([hinge_offset, size_y - hinge_y, -0.5 * mm])
      cube(size = [hinge_x, hinge_y, size_z + 1 * mm], center = false);
    // top right hinge hole
    translate([size_x - hinge_offset - hinge_x, size_y - hinge_y, -0.5 * mm]) 
      cube(size = [hinge_x, hinge_y, size_z + 1 * mm], center = false);
  }
}

/* Draw a grid of holes for seating circular magnets
 * size: Volume bounds as 3D vector [x, y, z] to draw magnet holes within.
 * rows: No. of rows in the grid of magnets.
 * cols: No. of columns in the grid of magnets.
 * diameter: diameter of each magnet hole.
 * skip: 0-indexed indexes of the magnet holes to skip drawing.
*/
module magnet_holes(size, rows=4, cols = 3, diameter = 8 * mm, skip=[]) {
  size_x = size[0];
  size_y = size[1];
  size_z = size[2];
  
  // draw a grid of magnet holes
  gap_x = size_x / (cols - 1);
  gap_y = size_y / (rows - 1);
  for(x = [0:cols - 1]) {
    for(y =  [0:rows - 1]) {
      // skip drawing magnet holes if specified in skip vector
      if(len(search(x + y * cols, skip)) <= 0) {
        translate(v = [
            x * gap_x,
            y * gap_y,
            diameter / 2,
        ]) 
          cylinder(h = size_z, r = diameter / 2, center = true);
      }
   }
  }
}

/* Draw a hole for seating a T-nut for an easel plate of given size
 * size: Dimensions of easel plate as 3D vector [x, y, z]
 * diameter: Diameter of the T-nut hole.
 * offset_y: Offset from the top of the easel plate to place the hole.
*/
module tnut_hole(plate_size, diameter, offset_y) {
  size_x = plate_size[0];
  size_y = plate_size[1];
  size_z = plate_size[2];
  

  translate(v = [size_x / 2, size_y - offset_y, size_z / 2])
    cylinder(h = size_z + 1 * mm, r = diameter / 2, center = true);
}

/* Draw pilot holes for screw attaching a hinge of given size.
 * hinge_size: Dimensions of the hinge as a 3D vector.
 * screw_offset: x,y offset to place screw hole as a 2D vector.
 * diameter: Diameter of the screw pilot hole.
*/
module screw_hole(hinge_size, screw_offset, diameter) {
  hinge_x = hinge_size[0];
  hinge_y = hinge_size[1];

  hinge_z = hinge_size[2];

  screw_x = screw_offset[0];
  screw_y = screw_offset[1];
  screw_radius = diameter / 2;
 
  // left screw hole
  translate([screw_x, screw_y])
    cylinder(h = hinge_z + 1 * mm, r = screw_radius, center = true);
  // right screw hole
  translate([hinge_x - screw_x, screw_y])
    cylinder(h = hinge_z + 1 * mm, r = screw_radius, center = true);
}

/* Draw a easel hinge support plate of given size.
 * Includes pilot holes screws attaching hinges.
 * size: Dimensions of the hinge support plate
 * hinge_size: Dimensions of the hinge.
 * hinge_offset: Offset from the sides of the plate to position hinge.
 * screw_offset: Offset from the sides of the hinge to place screw hole.
 * screw_diameter: Diameter of screw hole
*/
module hinge_support(size, hinge_size, hinge_offset, screw_offset, screw_diameter) {
  size_x = size[0];
  size_y = size[1];
  size_z = size[2];

  hinge_x = hinge_size[0];
  hinge_y = hinge_size[1];

  difference() {
    plate(size = size);
    offset_z = size_z / 2;
    // top left hinge
    translate([hinge_offset, size_y - hinge_y, offset_z]) {
      screw_hole(hinge_size = [hinge_x, hinge_y, size_z], screw_offset = screw_offset, diameter = screw_diameter);
    }
    // top right hinge
    translate([size_x - hinge_offset - hinge_x, size_y - hinge_y, offset_z])  {
      screw_hole(hinge_size = [hinge_x, hinge_y, size_z], screw_offset = screw_offset, diameter = screw_diameter);
    }
  }
}


// Easel Top
module easel_top(size, magnet_offset, magnet_shape, label, label_gap, divider_offset_y = 12 * mm) {
  size_x = size[0];
  size_y = size[1];
  size_z = size[2];
  
  magnet_diameter = magnet_shape[0];
  magnet_z = magnet_shape[1];
  magnet_offset_x = magnet_offset[0];
  magnet_offset_y = magnet_offset[1];
  // gap between last magnet hole and end of easel plate
  magnet_gap_y = 20 * mm;

  difference() {
    easel_plate(size = size);
    // magnet holes
    // magnets for holding drawing board
    translate([magnet_offset_x, magnet_gap_y, 0])
      magnet_holes(
        size = [
          size_x - 2 * magnet_offset_x, 
          size_y - magnet_gap_y - magnet_offset_y,
          magnet_z,
        ],
        rows = 2,
        cols = 2,
        diameter = magnet_diameter
      );

    // magnet for attaching
    translate([magnet_offset_x, magnet_gap_y + divider_offset_y, 0])
      magnet_holes(
        size = [
          size_x - 2 * magnet_offset_x, 
          size_y - magnet_gap_y - magnet_offset_y,
          magnet_z,
        ],
        rows = 3,
        cols = 4,
        diameter = magnet_diameter,
        skip = [0, 1, 2, 3, 4, 5, 6, 7, 8, 11]
      );
  }

}

module hinge_support_top(size, hinge_size, hinge_offset, screw_offset, screw_diameter) {
  hinge_support(size = size, hinge_size = hinge_size, hinge_offset = hinge_offset,
    screw_offset = screw_offset, screw_diameter = screw_diameter);
}

// Easel Bottom
module easel_bottom(size, tnut_diameter, tnut_offset_y, magnet_offset, magnet_shape, label, label_gap) {
  size_x = size[0];
  size_y = size[1];
  size_z = size[2];

  magnet_diameter = magnet_shape[0];
  magnet_z = magnet_shape[1];
  magnet_offset_x = magnet_offset[0];
  magnet_offset_y = magnet_offset[1];
  // gap between last magnet hole and end of easel plate
  magnet_gap_y = 20 * mm;

  difference() {
    easel_plate(size = size);
    // magnet holes
    translate([magnet_offset_x, magnet_gap_y, 0])
      magnet_holes(
        size = [
          size_x - 2 * magnet_offset_x, 
          size_y - magnet_gap_y - magnet_offset_y,
          magnet_z,
        ],
        rows = 3,
        cols = 4,
        diameter = magnet_diameter
      );
    // tnut hole
    tnut_hole(plate_size = size, diameter = tnut_diameter, offset_y = tnut_offset_y);
    // decorative text label
    translate(v = [size_x - 40 * mm - label_gap, label_gap]) 
      linear_extrude(height = size_z)
      rotate(a = 45)
      #text(text = label, font = "Abril Fatface:style=Regular");
  }
}
  

module hinge_support_bottom(size, tnut_diameter, tnut_offset_y, hinge_size, hinge_offset, screw_offset, screw_diameter) {
  difference() {
    hinge_support(size = size, hinge_size = hinge_size, hinge_offset = hinge_offset, 
      screw_offset = screw_offset, screw_diameter = screw_diameter);
    // tnut hole
    tnut_hole(plate_size = size, diameter = tnut_diameter, offset_y = tnut_offset_y);
  }
}

module easel(magnet_z = 3 * mm) {
  // dimensions of the easel
  size_x = 280 * mm;
  size_y = 200 * mm;
  size_z = 5 * mm;
  size = [ size_x, size_y, size_z];

  // dimensions of the tnut hole
  tnut_diameter = 8 * mm;
  tnut_offset_y = 30 * mm;

  // dimensions of the magnet holes
  magnet_offset = [20 * mm, 40 * mm];
  magnet_diameter = 8 * mm;
  magnet_shape = [magnet_diameter, magnet_z];
  // length of the hinge support plate
  support_y = 0.4 * size_y;
  
  // dimension of the hinges
  hinge_size = [ 65 * mm, 20 * mm ]; 
  hinge_offset = 20 * mm;
  screw_offset = [8.5 * mm, 8 * mm ];
  // #8 screw: 1/8 inch pilot hole
  screw_diameter = 1/8 * inch;
  
  // decorative label
  label = "PleinPad";
  label_gap = 8 * mm;

  // top
  translate([size_x + 0.1 * mm, 0, 0]) 
    easel_top(size = size, magnet_offset = magnet_offset, magnet_shape = magnet_shape, 
    label = label, label_gap=label_gap);
  translate([size_x + 0.1 * mm, size_y + 0.1 * mm, 0]) 
    hinge_support_top(size = [size_x, support_y, size_z], 
    hinge_size = hinge_size, hinge_offset = hinge_offset, 
    screw_offset = screw_offset, screw_diameter = screw_diameter);
  
  // bottom
  easel_bottom(size = size, tnut_diameter = tnut_diameter, tnut_offset_y = tnut_offset_y,  
    magnet_offset = magnet_offset, magnet_shape = magnet_shape, label=label, label_gap=label_gap);
  translate([0, size_y + 0.1 * mm, 0]) 
    hinge_support_bottom(size = [size_x, support_y, size_z], 
    tnut_diameter = tnut_diameter, tnut_offset_y = tnut_offset_y, 
    hinge_size = hinge_size, hinge_offset = hinge_offset, 
    screw_offset = screw_offset, screw_diameter = screw_diameter);
}

projection() easel(magnet_z = 8 * mm);
