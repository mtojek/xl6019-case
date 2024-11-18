$fn = 100;

// Debug
caseEnabled = true;
lidEnabled = true;

wallsEnabled = true;
floorEnabled = true;
pcbEnabled = false;

// Parameters
caseWidth = 80;
caseDepth = 36;
caseHeight = 22;

wallWidth = 2;

portWidth = 3.5;
portHeight = 10;
portWallWidth = 3;

legWidth = 6;
legHeight = 6;
legBlockerWidth = 6;
legBlockerHeight = 9.5;
legBlockerClipHeight = 3;

screwMountWidth = 11;
screwMountHeight = 20;
screwHoleDiameter = 3.5;

lidClearance = 0.2;

ventHoleWidth = 2;
ventHoleMargin = 5;
ventHoleDistance = 4;
ventHolesOffset = 10;
ventHolesCount = 6;

// Const
caseMinkowski = wallWidth;

floorWidth = caseWidth - 2*wallWidth;
floorDepth = caseDepth - 2*wallWidth;

pcbWidth = 50;
pcbDepth = 28;

pcbHolesWidth = 39.8 + 3;
pcbHolesDepth = 17.8 + 3;

pcbHoleDiameter = 2.8;
pcbMountHeight = 4;

nutBase = 3.1;
nutWidth = 6.5;
nutHeight = 3;

ventHoleDepth = caseDepth - 2 * ventHoleMargin;

// Case
if (caseEnabled) {
    difference() {
        union() {
            // Walls
            if (wallsEnabled) {
                difference() {
                    minkowski() {
                        cube([caseWidth, caseDepth, caseHeight - wallWidth], center = true);
                        sphere(2);
                    }
                    cube([caseWidth - 2*wallWidth, caseDepth - 2*wallWidth, caseHeight+2*wallWidth], center = true);
                }
            }

            // Floor
            if (floorEnabled) {
                color("blue")
                translate([0, 0, -caseHeight/2]) {
                    cube([floorWidth, floorDepth, wallWidth], center = true);
                }
            }

            color("orange") {
                // Left port
                translate([caseWidth/2 + wallWidth + portHeight/2, 0, 0])
                cablePort();

                // Right port
                translate([-(caseWidth/2 + wallWidth + portHeight/2), 0, 0])
                cablePort();
            }
        }
        // Cable port holes
        rotate([0, 90, 0])
        cylinder(caseWidth + 2*caseMinkowski + 2*portHeight + 2, d = portWidth, center = true);
    }

    // Legs
    pcbLeg();

    mirror([1, 0, 0])
    pcbLeg();

    mirror([0, 1, 0])
    pcbLeg();

    mirror([0, 1, 0])
    pcbLeg();

    mirror([1, 0, 0])
    mirror([0, 1, 0])
    pcbLeg();

    // Screw mounts
    screwMount();

    mirror([1, 0, 0])
    screwMount();

    mirror([0, 1, 0])
    screwMount();

    mirror([0, 1, 0])
    screwMount();

    mirror([1, 0, 0])
    mirror([0, 1, 0])
    screwMount();

}

// Lid
if (lidEnabled) {
    difference() {
        color("orange")
        translate([0, 0, caseHeight/2])
        cube([floorWidth - 2*lidClearance, floorDepth - 2*lidClearance, wallWidth], center = true);
        
        union() {
            // Screw holes
            lidScrewHole();
            
            mirror([1, 0, 0])
            lidScrewHole();
            
            mirror([0, 1, 0])
            lidScrewHole();

            mirror([1, 0, 0])
            mirror([0, 1, 0])
            lidScrewHole();
            
            // Vent holes
            translate([-pcbWidth/2 + ventHolesOffset, 0, 0])
            for (i = [0 : 1 : ventHolesCount - 1]){
                translate([i * (ventHoleDistance + ventHoleWidth), 0, caseHeight/2])
                cube([ventHoleWidth, ventHoleDepth, wallWidth+1], center = true);
            }
        }
    }

    // Lid pcb leg blockers
    pcbLegBlocker();

    mirror([1, 0, 0])
    pcbLegBlocker();
            
    mirror([0, 1, 0])
    pcbLegBlocker();

    mirror([1, 0, 0])
    mirror([0, 1, 0])
    pcbLegBlocker();
}

// XL6019 model
if (pcbEnabled) {
    pcb();
}

// Part modules
module cablePort() {
    rotate([0, 90, 0])
    cylinder(portHeight, d = portWidth + 2 * portWallWidth, center = true);
}

module pcbLeg() {
translate([pcbHolesWidth/2, pcbHolesDepth/2, -caseHeight/2 + legHeight/2 + wallWidth/2]) {
        cube([legWidth, legWidth, legHeight], center = true);

        color("green")
        translate([0, 0, legHeight/2])
        cylinder(h = pcbMountHeight, d = pcbHoleDiameter, center = true); // FIXME: should stic to the yellow leg
    }
}

module screwMount() {
    translate([floorWidth/2 - screwMountWidth/2, floorDepth/2 - screwMountWidth/2, 0]) {
        color("green")
        
        difference() {
            translate([0, 0, screwMountHeight/2 - caseHeight/2 + wallWidth/2])
            cube([screwMountWidth, screwMountWidth, screwMountHeight], center = true);

            translate([-screwMountWidth/4 + nutBase/2 - 0.5, 0, screwMountHeight/4])
            cube([screwMountWidth/2 + nutBase + 1, nutWidth, nutHeight], center = true);
            
            translate([0, 0, screwMountHeight/2 - caseHeight/2 + wallWidth/2])
            cylinder(h = screwMountHeight + 2, d = screwHoleDiameter, center = true);
        }
        
        translate([0, 0, screwMountHeight/4 + nutHeight/2 + 0.1])
        cylinder(h = 0.2, d = screwHoleDiameter+1, center = true); // FIXME: sacrificial layer
    }
}

module lidScrewHole() {
    translate([floorWidth/2 - screwMountWidth/2, floorDepth/2 - screwMountWidth/2, caseHeight/2]) {
        cylinder(h = wallWidth + 1, d = screwHoleDiameter, center = true);
        
    }
}

module pcbLegBlocker() {
    translate([pcbHolesWidth/2, pcbHolesDepth/2, caseHeight/2 - wallWidth/2 - legBlockerHeight/2]) {
        cylinder(h = legBlockerHeight, d = legBlockerWidth, center = true);
        
        color("orange")
        translate([0, 0, -legBlockerHeight/2 - legBlockerClipHeight/2])
        difference() {
            cylinder(h = legBlockerClipHeight, d = legBlockerWidth, center = true);
            
            cylinder(h = legBlockerClipHeight + 1, d = pcbHoleDiameter + 0.2, center = true);
        }
        
    }
}

module pcb() {
    /*color("red")
    translate([0, 0, -3.9])
    import("xl6019-centered.stl", convexity=3);*/
}

