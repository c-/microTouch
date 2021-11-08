part = "cover";	// [cover, flag]

pcbt = 1.6;
$fn = 72;

module servo() {
	color("blue") import("micro linear servo.stl");
}

module pcb() {
	color("green") translate([-8.254,-20.254,pcbt/2]) import("microTouch.stl");
}

module interrupter() {
	difference() {
		union() {
			cube([6,13,10]);
			translate([(6-2.54)/2,1.5,-pcbt*2]) cylinder(d=0.8,h=pcbt*2);
			translate([6-(6-2.54)/2,1.5,-pcbt*2]) cylinder(d=0.8,h=pcbt*2);
			translate([(6-2.54)/2,11.5,-pcbt*2]) cylinder(d=0.8,h=pcbt*2);
			translate([6-(6-2.54)/2,11.5,-pcbt*2]) cylinder(d=0.8,h=pcbt*2);
		}
		translate([-.1,4,2]) cube([7,5,10]);
		translate([2.6,0,4.1]) cube([0.8,0.8,6]);
		translate([2.6,13-0.8,4.1]) cube([0.8,0.8,6]);
		translate([2.75,3.5,2]) cube([0.5,0.5,4.8]);
		translate([2.75,13-4,2]) cube([0.5,0.5,4.8]);
	}
}

module flag() {
	w = 3;
	h = 4;
	
	rotate([0,90,0]) difference() {
		union() {
			hull() {
				translate([.1,0,1.5]) cylinder(d=w,h=3);
				translate([7.8-w,0,1.5]) cylinder(d=w,h=3);
			}
			
			// this is also an alignment pin for the plunger
			translate([-1.8,-w/2,-h]) cube([2,w,14]);
			
			translate([0.1,0,7.5]) hull() {
				translate([0,-(10-h)/2,0]) cylinder(d=h,h=7);
				translate([0,(10-h)/2,0]) cylinder(d=h,h=7);
			}
		}
		translate([0,0,9]) cylinder(d=2.5,h=20);
	}
}

module cover() {
	t = 1.5;
	difference() {
		hull() {
			cube([t,13+t*2,10+t]);
			translate([29+t,13+t*2-5/2,-pcbt]) cylinder(d=5,h=10+t+pcbt);
			translate([29+t,5/2,-pcbt]) cylinder(d=5,h=10+t+pcbt);
		}
		
		translate([0,t+(13-10.5)/2,0]) cube([31.5,10.5,10.5]);
		translate([6.5,-10,-pcbt]) cube([22,35,pcbt*3]);
		translate([27.25,t+2.5,0]) cube([4,10,10.5]);	// gear clearance
		
		translate([0,t,0]) difference() {
			cube([7,13,10.5]);
			translate([3.5,0,5]) cylinder(d=1,h=5.5,$fn=4);
			translate([3.5,13,5]) cylinder(d=1,h=5.5,$fn=4);
		}
		
		translate([30,7.75,8]) rotate([0,90,0]) cylinder(d=3.5,h=t*2);
		
		translate([14,10,0]) hull() {
			cylinder(d=4,h=10+t);
			translate([11,0,0]) cylinder(d=4,h=10+t);
		}
		
		translate([0,-10,-pcbt]) cube([31.25,35,pcbt]);
	}
}

if( part == "flag" ) {
	flag();
} else if( part == "cover" ) {
	cover();
} else {
	*pcb();
	translate([34.8,27.5,pcbt]) servo();
	translate([.65,9,pcbt]) color("darkgray") interrupter();
	translate([-0.75, 15.5, 6+pcbt+2]) flag();
	color("gray")
		translate([10,15.5,pcbt+7.9]) rotate([0,90,0]) cylinder(d=3,h=30);
	*%translate([0,7.7,pcbt]) cover();
}