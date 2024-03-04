/*
 * Easel
 * CAD Model
 */

include <mcad/units.scad>;

// Tnut: M6 or M8
// Hinge Screws: M4

/* Draw the easel plate shape
 * size: 2D vector [x, y]
 * border_radius: Radius of rounded corners
 */
module plate(size, top_edge, bottom_edge, border_radius = 10 * mm) {
  size_x = size[0];
  size_y = size[1];


  difference() {

    // offset to round borders
    translate([border_radius, border_radius])
      offset(r=border_radius) 
      square([size_x - 2 * border_radius, size_y - 2* border_radius]);
    
    // cutout for divider storage
    divider_x = 80 * mm;
    divider_y = 10 * mm;
    translate([size_x / 2 - divider_x / 2 ,size_y - divider_y]) square(size = [divider_x, divider_y]);
  }
}

module easel_plate(size, hinge_size, hinge_offset, top_edge, bottom_edge) {
  size_x = size[0];
  size_y = size[1];
  hinge_x = hinge_size[0];
  hinge_y = hinge_size[1];

  difference() {
    plate(size = size);
    // top left hinge hole
    translate([hinge_offset, size_y - hinge_y])
      square(size = [hinge_x + 1 * mm, hinge_y + 1 * mm], center = false);
    // top right hinge hinge hole
    translate([size_x - hinge_offset - hinge_x, size_y - hinge_y]) 
      square(size = [hinge_x + 1 * mm, hinge_y + 1 * mm], center = false);
  }
}


module easel() {
  size = [ 280 * mm, 200 * mm ];
  hinge_size = [ 65 * mm, 20 * mm ];
  hinge_offset = 20 * mm;
  bottom_edge = 40 * mm;
  easel_plate(size = size, hinge_size = hinge_size, hinge_offset = hinge_offset);
}

easel();
