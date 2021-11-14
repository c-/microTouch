part = "backer";	// [cover, slider, backer]

pcbt = 1.6;
t = 1.5;
backert = 3;
pind = 3;
magnetd = 3;
magneth = 3;
screwd = 2.8;	// set screw
br = 5.084;	// back corner radius
fr = 2.54;	// front corner radius

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
	slidelen = 14.5;
	
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

module backer() {
	difference() {
		hull() {
			translate([br-3.5,br,0]) cylinder(r=br,h=backert);
			translate([-3.5,15.4,0]) cube([14,1,backert]);
			translate([-3.5+14,0,0]) cube([0.1,1,backert]);
		}
		// mounting bolt
		translate([-3.5+5.5, (13+t*2)/2-0.4, -.1])
			cylinder(d=4, h=backert*2);
		
		// sensor pins
		translate([5.8,4.8,-.1]) cube([3,6,backert*2]);
	}
}

module cover() {
	difference() {
		hull() {
			translate([29+t,13.5+t*2-fr,-pcbt])
				cylinsphere(r=fr,h=10+t+pcbt);
			translate([29+t,fr,-pcbt]) cylinsphere(r=fr,h=10+t+pcbt);
			
			translate([br-3.5,13.5+t*2-br,0])
				cylinsphere(r=br,h=10+t);
			translate([br-3.5,br,0]) cylinsphere(r=br,h=10+t);
			
			translate([-3.5,fr,10+t-fr])
				rotate([0,90,0]) cylinder(r=fr,h=0.1);
			translate([-3.5,13.5+t*2-fr,10+t-fr])
				rotate([0,90,0]) cylinder(r=fr,h=0.1);
		}
		
		// main cutout - ideally a friction fit to servo pcb
		translate([-t,t+(13-10.25)/2,0]) cube([31,10.25,8]);
		
		// clearance for servo "legs" and fasteners
		translate([9.25,-10,-pcbt]) cube([4,35,pcbt*2.5]);
		translate([24.75,-10,-pcbt]) cube([4,35,pcbt*2.5]);
		
		// base clearance - slight friction fit would be good here
		translate([-3.5,-10,-pcbt]) cube([34.5,35,pcbt]);

		// gear clearance
		translate([27.5+2,t+4.5,0]) hull() {
			cylinder(d=4,h=8);
			translate([0,10-4,0]) cylinder(d=4,h=8);
		}
		
		// mounting bolt access hole
		translate([-3.5+5.5, (13+t*2)/2-0.4, -5])
			cylinder(d=3, h=20);
		
		// front hole
		translate([25,(13+t*2)/2,8]) rotate([0,90,0]) cylinder(d=pind+0.5,h=10);

		// set screw hole, should self-thread
		translate([20,25,3]) 
			rotate([90,0,0]) cylinder(d=screwd,h=30);
		
		// servo arm clearance and slider viewport
		translate([14,10,0]) hull() {
			cylinder(d=4,h=10+t);
			translate([11,0,0]) cylinder(d=4,h=10+t);
		}
		
		// track for slider. In an ideal world this would be entirely
		// contained, but odds are someone will need to get a file in
		// to smooth the track, and a back slot is by far the easiest.
		translate([-10,(13+t*2)/2,8]) rotate([0,90,0]) hull() {
			translate([0,-(12.5-4.5)/2,0]) cylinder(d=4.8,h=38);
			translate([0,(12.5-4.5)/2,0]) cylinder(d=4.8,h=38);
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
//	translate([34.8,27.5,pcbt]) servo();
	color("red") translate([-0.75, 15.75, 6+pcbt+2]) slider();
	color("gray")
		translate([10,15.75,pcbt+7.9]) rotate([0,90,0])
			cylinder(d=pind-1,h=25);
	%translate([0,7.7,pcbt]) cover();
	%translate([0,7.7,-backert]) backer();
}