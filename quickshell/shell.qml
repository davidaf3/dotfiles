import QtQuick
import QtQuick.Shapes 1.0
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: root

    Colors {
        id: colors
    }

    property int barHeight: 34
    property int radius: 20 // 12 window border radius + 8 gap
    property color barColor: colors.surface 

    component InverseCorner: PanelWindow {
        id: win

        WlrLayershell.layer: WlrLayer.Top
        exclusionMode: ExclusionMode.Ignore 

        implicitWidth: root.radius
        implicitHeight: root.radius
        color: "transparent"

        property string side: "left"

        anchors {
            top: true
            left: side === "left"
            right: side === "right"
        }

        margins.top: root.barHeight

        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 4

            ShapePath {
                strokeWidth: 0
                strokeColor: "transparent"
                fillColor: root.barColor

                PathSvg {
                    path: {
                        if (win.side === "left") {
                            return `M 0 0 L ${win.width} 0 A ${win.width} ${win.height} 0 0 0 0 ${win.height} Z`;
                        } 
                        else {
                            return `M 0 0 L ${win.width} 0 L ${win.width} ${win.height} A ${win.width} ${win.height} 0 0 0 0 0 Z`;
                        }
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            Item {
                width: 0; height: 0
                visible: false 

                InverseCorner {
                    screen: modelData
                    side: "left"
                }

                InverseCorner {
                    screen: modelData
                    side: "right"
                }
            }
        }
    }
}
