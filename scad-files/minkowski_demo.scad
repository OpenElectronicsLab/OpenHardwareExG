// This demonstrates why we need to "translate" the origin of a rectangle
// before we apply a minkowski() transformation

// a rectangle with rounded corners of radius r
module rounded_rectangle(size = [1, 1], r = 0.1) {
    // move the origin, to compensate for shrinkage
    // comment out the translate to see the difference
    translate([r,r])

    minkowski() {
        square(size - 2*[r,r]);
        circle(r);
    }
}

$fn = 360;

rect= [3,5];

translate([3.1,0])
square(rect);

rounded_rectangle(rect, 1);
