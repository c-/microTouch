part = "cover";	// [cover, slider, backer]

pcbt = 1.6;
bextra = 0; // pcbt;
t = 1.5;
backert = 3;
pind = 3;
magnetd = 3.5;
magneth = 3;
br = 5.084;	// back corner radius
fr = 2.54;	// front corner radius
tabw = 7;	// bolt tab/spacer width
magnetoffset = 15;
slidelen = magnetoffset + magnetd/2 + 1;
slidew = 12;

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


module cylinsphere(r,d,h) {
	r = r ? r : d/2;
	hull() {
		cylinder(r=r,h=0.1);
		translate([0,0,h-r]) sphere(r=r);
	}
}

module slider() {
	w = 2;
	h = 4;
	
	rotate([0,90,0]) difference() {
		union() {
			translate([0.1,0,0]) hull() {
				// taper the body to help prevent binding
				translate([0,-(slidew-h)/2,slidelen*.66])
					cylinsphere(d=h,h=slidelen/3);
				translate([0,(slidew-h)/2,slidelen*.66])
					cylinsphere(d=h,h=slidelen/3);
				translate([0,-(slidew-2-h)/2,0]) cylinsphere(d=h,h=slidelen);
				translate([0,(slidew-2-h)/2,0]) cylinsphere(d=h,h=slidelen);
			}
		}
		
		// pin
		translate([0,0,slidelen/2]) cylinder(d=pind,h=slidelen);
		
		// magnet. making it a through hole means someone can
		// flip it if they screw up polarity
		translate([-h,0,slidelen-magnetoffset])
			rotate([0,90,0]) cylinder(d=magnetd,h=h*2);
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
			h = 11;
			
			translate([30,bwid+t*2-fr,-pcbt-bextra])
				cylinsphere(r=fr+t,h=h+t+pcbt+bextra);
			translate([30,fr,-pcbt-bextra])
				cylinsphere(r=fr+t,h=h+t+pcbt+bextra);
			
			translate([br-3.5-t,bwid+t*3-br,-pcbt-bextra])
				cylinsphere(r=br,h=h+t+pcbt+bextra);
			translate([br-3.5,br,-pcbt-bextra])
				cylinsphere(r=br+t,h=h+t+pcbt+bextra);
			
			translate([-3.5-t,fr,h-fr])
				rotate([0,90,0]) cylinder(r=fr+t,h=0.1);
			translate([-3.5-t,bwid+t*2-fr,h-fr])
				rotate([0,90,0]) cylinder(r=fr+t,h=0.1);
		}
		
		// main cutout
		difference() {
			union() {
//				// This needs to go just far enough back to
				// clear the hall sensor
				hull() {
					translate([-t+29,t+(bwid-12)/2,0]) rcube([3,12,0.1],cornerr=3);
					translate([-t+29,t+(bwid-12)/2+1,8]) rcube([3,10,.1],cornerr=3);
					translate([t+9.5,t+bwid/2,0]) cylinder(d1=12,d2=10,h=8);
				}

				// clearance for the passives around the
				// mounting hole
				difference() {
					hull() {
						translate([-t+14,t+(bwid-12)/2,0]) cube([11,12,2.3]);
						translate([t+2-br/2,t-1-br/2+bwid/2,0]) cylinder(d=br,h=2.3);
						translate([t+2-br/2,t+1+br/2+bwid/2,0]) cylinder(d=br,h=2.3);
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
		translate([0,-0.5,-pcbt-0.1]) hull() {
			translate([9,0,0]) cube([20,17.1,pcbt*2.5]);
			translate([9-2.5,0,0]) cube([22.5,17.1,pcbt]);
		}
		
		// this cutout follows the contour of the PCB. Doesn't need to be
		// perfect, just cutting out a pocket.
		// (FIXME: should just load the PCB as a DXF or something)
		translate([0,0,-pcbt*3+0.1])
		difference() {
			e = 0.5;
			hull() {
				translate([32-3,fr,0]) cylinder(r=fr+e,h=pcbt*3);
				translate([32-3,bwid+t*2-fr,0]) cylinder(r=fr+e,h=pcbt*3);
				translate([br-3.5,bwid+t*2-br+6.4,0])
					cylinder(r=br+e,h=pcbt*3);
				translate([br-3.5+8.4,bwid+t*2-br+6.4,0])
					cylinder(r=br+e,h=pcbt*3);
				translate([br-3.5,br-0.25,0]) cylinder(r=br+e,h=pcbt*3);
			}
			hull() {
				translate([br-3.5+15,bwid+t*2-br+6.5,0])
					cylinder(r=2-e,h=pcbt*3);
				translate([br-3.5+32,bwid+t*2-br+7,0])
					cylinder(r=2,h=pcbt*3);
				translate([br-3.5+15,bwid+t*2-br+12,0])
					cylinder(r=2,h=pcbt*3);
			}
		}

		// extra gear clearance
		translate([28.5+1.5,t+4.5,-pcbt-0.1]) hull() {
			translate([0,-2,10]) mirror([0,0,1]) cylinder(h=10,r=2.5);
			translate([0,10-3,10]) mirror([0,0,1]) cylinder(h=10, r=2.5);
		}
		
		// hole for mounting from the back. This shouldn't go all the way
		// through, since it's nicer to print a bridge
		translate([2, (bwid+t*2)/2-0.4, 0])
			cylinder(d=insertd, h=pcbt+insertl-1);
		
		// front hole
		translate([25,(bwid+t*2)/2,8.5]) rotate([0,90,0])
			cylinder(d=pind+0.5,h=10);

		// servo arm clearance and slider viewport
		translate([14,10.25,0]) hull() {
			cylinder(d=4,h=12+t);
			translate([11,0,0]) cylinder(d=4,h=12+t);
		}
		
		// give the connector just a hair of play
		translate([-t-1,16,0]) rcube([14.5,5,15],cornerr=1);
		
		// track for slider. Aside from where the slider is inserted,
		// it's useful for smoothing things with a file.
		translate([-10,(bwid+t*2)/2,7.75]) rotate([0,90,0]) hull() {
			translate([0,-(12-4.5)/2,0]) cylinder(d=5.5,h=38);
			translate([0,(12-4.5)/2,0]) cylinder(d=5.5,h=38);
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