part = "all";	// [cover, slider, backer]

pcbt = 1.6;
t = 1.5;
backert = 3;
pind = 3;
magnetd = 3.5;
magneth = 3;
br = 5.084;	// back corner radius
fr = 2.54;	// front corner radius
tabw = 7;	// bolt tab/spacer width
slidelen = 14.5;

// M3 heat set insert for mounting screw, or just M3
// diameter if you want to try threading it directly
insertd = 3;
insertl = 4;

$fn = 72;

module servo() {
	color("teal") import("micro linear servo.stl");
}

module pcb() {
	color("green") translate([-8.254,-20.254,pcbt/2]) import("microTouch.stl");
}

module slider() {
	w = 2;
	h = 4;
	
	rotate([0,90,0]) difference() {
		union() {
			translate([0.1,0,0]) hull() {
				translate([0,-(12-h)/2,0]) cylinder(d=h,h=slidelen);
				translate([0,(12-h)/2,0]) cylinder(d=h,h=slidelen);
			}
		}
		
		// pin
		translate([0,0,slidelen-6]) cylinder(d=pind,h=slidelen);
		
		// magnet
		translate([(h/2-magneth)+0.1,0,magnetd])
			rotate([0,90,0]) cylinder(d=magnetd,h=magneth);
	}
}

module cylinsphere(r,h) {
	hull() {
		cylinder(r=r,h=0.1);
		translate([0,0,h-r]) sphere(r=r);
	}
}

module rcube(v,cornerr=3,center=false) {
   cr = max(0.1,min(v[0]/2,v[1]/2,cornerr));
	cx = center ? -v[0]/2 : 0;
	cy = center ? -v[1]/2 : 0;
   translate([cr+cx,cr+cy,0]) hull() {
      translate([0,0,0]) cylinder(r=cr,h=v[2]);
      translate([0,v[1]-cr*2,0]) cylinder(r=cr,h=v[2]);
      translate([v[0]-cr*2,0,0]) cylinder(r=cr,h=v[2]);
      translate([v[0]-cr*2,v[1]-cr*2,0])
			cylinder(r=cr,h=v[2]);
   }
}

module backer() {
	difference() {
		hull() {
			translate([br-3.5,br,0]) cylinder(r=br,h=backert);
			translate([-3.5,15.4,0]) cube([14,1,backert]);
			translate([-3.5+14,0,0]) cube([0.1,1,backert]);
		}
		// mounting bolt
		translate([-3.5+5.5, (13+t*2)/2-0.4, -.1])
			cylinder(d=insertd, h=backert*2);
		
		// sensor pins
		translate([5.8,4.8,-.1]) cube([3,6,backert*2]);
	}
}

module cover() {
	bwid = 13.5;
	difference() {
		hull() {
			translate([30+t,bwid+t*2-fr,-pcbt])
				cylinsphere(r=fr,h=10+t+pcbt);
			translate([30+t,fr,-pcbt]) cylinsphere(r=fr,h=10+t+pcbt);
			
			translate([br-3.5,bwid+t*2-br,0])
				cylinsphere(r=br,h=10+t);
			translate([br-3.5,br,0]) cylinsphere(r=br,h=10+t);
			
			translate([-3.5,fr,10+t-fr])
				rotate([0,90,0]) cylinder(r=fr,h=0.1);
			translate([-3.5,bwid+t*2-fr,10+t-fr])
				rotate([0,90,0]) cylinder(r=fr,h=0.1);
		}
		
		// main cutout
		difference() {
			union() {
//				// This needs to go just far enough back to
				// clear the hall sensor
				hull() {
					translate([-t+29,t+(bwid-12)/2,0]) rcube([3,12,8],cornerr=3);
					translate([t+9.5,t+bwid/2,0]) cylinder(d=12,h=8);
				}

				// clearance for the passives around the
				// mounting hole
				difference() {
					hull() {
						translate([-t+14,t+(bwid-12)/2,0]) cube([11,12,2.4]);
						translate([t+2-br/2,t-1-br/2+bwid/2,0]) cylinder(d=br,h=2.4);
						translate([t+2-br/2,t+1+br/2+bwid/2,0]) cylinder(d=br,h=2.4);
					}
					
					// want the mounting hole supported flush to the board
					hull() {
						translate([-t, (13+t*2)/2-0.2, -.1])
							cylinder(d=6, h=backert*2);
						translate([2, (13+t*2)/2-0.2, -.1])
							cylinder(d=6, h=backert*2);
					}
				}
			}
		}
		
		// clearance for servo "legs" and fasteners
		hull() {
			translate([9,-10,-pcbt]) cube([20,35,pcbt*2.5]);
			translate([9-2.5,-10,-pcbt]) cube([22.5,35,pcbt]);
		}
		
		// base clearance - slight friction fit would be good here
		translate([-3.5,-10,-pcbt]) cube([32,35,pcbt]);
		
		// this cutout follows the contour of the PCB and helps prevent it
		// from rotating around the mounting bolt
		translate([32-3.25,0,-pcbt])
		hull() {
			translate([0,fr,0]) cylinder(r=fr+.25,h=pcbt);
			translate([0,bwid+t*2-fr,0]) cylinder(r=fr+.25,h=pcbt);
		}

		// extra gear clearance
		translate([28.5+1.5,t+4.5,0]) hull() {
			translate([0,-2,10]) mirror([0,0,1]) cylinsphere(h=9,r=2.5);
			translate([0,10-3,10]) mirror([0,0,1]) cylinsphere(h=9, r=2.5);
		}
		
		// hole for mounting from the back. This shouldn't go all the way
		// through, since it's nicer to print a bridge
		translate([2, (bwid+t*2)/2-0.4, 0])
			cylinder(d=insertd, h=pcbt+insertl-1);
		
		// front hole
		translate([25,(bwid+t*2)/2,8]) rotate([0,90,0])
			cylinder(d=pind+0.5,h=10);

		// servo arm clearance and slider viewport
		translate([14,10.25,0]) hull() {
			cylinder(d=4,h=10+t);
			translate([11,0,0]) cylinder(d=4,h=10+t);
		}
		
		// give the connector just a hair of play
		translate([-t-1,16,0]) rcube([14.5,5,15],cornerr=1);
		
		// track for slider. Aside from where the slider is inserted,
		// it's useful for smoothing things with a file.
		translate([-10,(bwid+t*2)/2,7.5]) rotate([0,90,0]) hull() {
			translate([0,-(12.5-4.5)/2,0]) cylinder(d=5.2,h=38);
			translate([0,(12.5-4.5)/2,0]) cylinder(d=5.2,h=38);
		}
	}
}

if( part == "slider" ) {
	slider();
} else if( part == "cover" ) {
	cover();
} else if( part == "backer" ) {
	backer();
} else {
	pcb();
   translate([34.8,27.5,pcbt]) servo();
	color("red") translate([-0.75, 15.75, 6+pcbt+2]) slider();
	color("gray")
		translate([10,15.75,pcbt+7.9]) rotate([0,90,0])
			cylinder(d=pind-1,h=25);
	%translate([0,7.7,pcbt]) cover();
	%translate([0,7.7,-backert]) backer();
}