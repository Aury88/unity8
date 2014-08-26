/*
 * Copyright 2014 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtTest 1.0
import Unity.Test 0.1 as UT
import ".."
import "../../../qml/Stages"
import Ubuntu.Components 0.1
import Unity.Application 0.1

Rectangle {
    color: "black"
    id: root
    width: units.gu(70)
    height: units.gu(70)

    SurfaceContainer {
        id: surfaceContainer
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            topMargin: fullscreenCheckbox.checked ? 0 : units.gu(3) + units.dp(2)
        }
        width: units.gu(40)
    }

    Rectangle {
        color: "white"
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: surfaceContainer.right
            right: parent.right
        }

        Column {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
            spacing: units.gu(1)
            Row {
                anchors { left: parent.left; right: parent.right }
                CheckBox {
                    id: surfaceCheckbox;
                    checked: false;
                    onCheckedChanged: {
                        if (checked) {
                            surfaceContainer.surface = SurfaceManager.createSurface("fake-surface",
                                                                           MirSurfaceItem.Normal,
                                                                           MirSurfaceItem.Restored,
                                                                           Qt.resolvedUrl("../Dash/artwork/music-player-design.png"));
                        } else {
                            surfaceContainer.surface.release();
                        }
                    }
                }
                Label { text: "surface" }
            }
            Row {
                anchors { left: parent.left; right: parent.right }
                CheckBox {id: fullscreenCheckbox; checked: true; }
                Label { text: "fullscreen" }
            }
        }
    }

    SignalSpy {
        id: surfaceSpy
        target: SurfaceManager
        signalName: "surfaceDestroyed"
    }

    UT.UnityTestCase {
        id: testCase
        name: "SurfaceContainer"
        when: windowShown

        function cleanup() {
            // reload our test subject to get it in a fresh state once again
            surfaceCheckbox.checked = false;
            tryCompare(surfaceContainer, "surface", null);
            surfaceSpy.clear();

        }

        /*
            Add a first surface. Then remove it. Then add a second surface.
            That second surface should be properly sized.

            Regression test for https://bugs.launchpad.net/ubuntu/+source/qtmir/+bug/1359819
         */
        function test_resetSurfaceGetsProperlySized() {
            surfaceCheckbox.checked = true;
            surfaceCheckbox.checked = false;
            surfaceCheckbox.checked = true;
            var fakeSurface = surfaceContainer.surface;
            compare(fakeSurface.width, surfaceContainer.width);
            compare(fakeSurface.height, surfaceContainer.height);
        }

         function test_childSurfaces_data() {
             return [ { tag: "1", count: 1 },
                      { tag: "4", count: 4 } ];
         }

         function test_childSurfaces(data) {
             surfaceCheckbox.checked = true;

             var i;
             var surfaces = [];
             for (i = 0; i < data.count; i++) {
                 var surface = SurfaceManager.createSurface(surfaceContainer.surface.name + "-Child" + i,
                                                            MirSurfaceItem.Normal,
                                                            MirSurfaceItem.Restored,
                                                            Qt.resolvedUrl("../Dash/artwork/music-player-design.png"));
                 surfaceContainer.surface.addChildSurface(surface);
                 compare(surfaceContainer.childSurfaces.count(), i+1);

                 surfaces.push(surface);
             }

             for (i = data.count-1; i >= 0; i--) {
                 surfaces[i].release();
                 tryCompareFunction(function() { return surfaceContainer.childSurfaces.count(); }, i);
             }
             tryCompare(surfaceSpy, "count", data.count);
         }

         function test_nestedChildSurfaces_data() {
             return [
                 { tag: "2", count: 2 },
                 { tag: "10", count: 10 }
             ];
         }

         function test_nestedChildSurfaces(data) {
             surfaceCheckbox.checked = true;

             var i;
             var surfaces = [];
             var lastSurface = surfaceContainer.surface;
             var delegate;
             var container = surfaceContainer;
             for (i = 0; i < data.count; i++) {
                 var surface = SurfaceManager.createSurface(surfaceContainer.surface.name + "-Child" + i,
                                                            MirSurfaceItem.Normal,
                                                            MirSurfaceItem.Restored,
                                                            Qt.resolvedUrl("../Dash/artwork/music-player-design.png"));
                 lastSurface.addChildSurface(surface);
                 compare(container.childSurfaces.count(), 1);
                 surfaces.push(surface);

                 delegate = findChild(container, "childDelegate0");
                 container = findChild(delegate, "surfaceContainer");
                 lastSurface = surface;
             }

             surfaceSpy.clear();
             for (i = data.count-1; i >= 0; i--) {
                 surfaces[i].release();
             }

             compare(surfaceContainer.childSurfaces.count(), 0);
             tryCompare(surfaceSpy, "count", data.count)
         }
    }
}
