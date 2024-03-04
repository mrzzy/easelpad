/*
 * Easel
 * CAD Model
 */

include <mcad/units.scad>;

/* Draw the easel plate shape
 * size: 2D vector [x, y]
 * top_edge: length of the slanted edge on the hinge side.
 * bottom_edge: length of the slanted edge opposite the hinge side.
 */
module plate(size, top_edge, bottom_edge) {
  size_x = size[0];
  size_y = size[1];
  top_edge_len = sqrt((top_edge ^ 2) / 2);
  bottom_edge_len = sqrt((bottom_edge ^ 2) / 2);


  polygon(points = [
      // bottom left edge
      [0, bottom_edge_len],
      [bottom_edge_len, 0],

      // bottom right edge
      [size_x - bottom_edge_len, 0],
      [size_x, bottom_edge_len],

      // top right edge
      [size_x, size_y - top_edge_len],
      [size_x - top_edge_len, size_y],

      // top left edge
      [top_edge_len, size_y],
      [0, size_y - top_edge_len],
  ]);
}


module easel_bottom(size, hinge_size, hinge_offset, top_edge, bottom_edge) {
  size_x = size[0];
  size_y = size[1];
  hinge_x = hinge_size[0];
  hinge_y = hinge_size[1];

  difference() {
    plate(size = size, top_edge = top_edge, bottom_edge = bottom_edge);
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
  top_edge = 20 * mm;
  bottom_edge = 40 * mm;
  easel_bottom(size = size, hinge_size = hinge_size, hinge_offset = hinge_offset, top_edge = top_edge, bottom_edge = bottom_edge);
}

easel();
