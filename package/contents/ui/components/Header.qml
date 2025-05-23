import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support

RowLayout {
    id: root
    readonly property string ghUser: "luisbocanegra"
    readonly property string projectName: "plasma-smart-video-wallpaper-reborn"
    readonly property string ghRepo: "https://github.com/"+ghUser+"/"+projectName
    readonly property string kofi: "https://ko-fi.com/luisbocanegra"
    readonly property string paypal: "https://www.paypal.com/donate/?hosted_button_id=Y5TMH3Z4YZRDA"
    readonly property string email: "mailto:luisbocanegra17b@gmail.com"
    readonly property string projects: "https://github.com/"+ghUser+"?tab=repositories&q=&type=source&language=&sort=stargazers"
    readonly property string kdeStore: "https://store.kde.org/p/2139746"
    property string wallpaperVersion

    P5Support.DataSource {
        id: runCommand
        engine: "executable"
        connectedSources: []

        onNewData: function (source, data) {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(source, exitCode, exitStatus, stdout, stderr)
            disconnectSource(source) // cmd finished
            sourceConnected(source)
        }

        function exec(cmd) {
            runCommand.connectSource(cmd)
        }

        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }

    Connections {
        target: runCommand
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            if (exitCode !== 0 ) {
                wallpaperVersion = stderr
                console.log(cmd, stder)
            } else {
                try {
                    wallpaperVersion = JSON.parse(stdout).KPlugin.Version
                } catch (e) {
                    console.log(e)
                    wallpaperVersion = e
                }
            }
        }
    }

    Component.onCompleted: {
        const metaDataFile = Qt.resolvedUrl("../../../").toString().substring(7) + "metadata.json"
        console.log(metaDataFile)
        runCommand.exec(`cat "${metaDataFile}"`)
    }

    Item {
        Layout.fillWidth: true
    }
    RowLayout {
        Layout.alignment: Qt.AlignRight
        Label {
            text: i18nd("plasma_wallpaper_luisbocanegra.smart.video.wallpaper.reborn","Version:")
        }
        Label {
            text: wallpaperVersion
            font.weight: Font.DemiBold
        }
    }

    Menu {
        id: menu
        y: linksButton.height
        x: linksButton.x
        Action {
            text: "Changelog"
            onTriggered: Qt.openUrlExternally(ghRepo+"/blob/main/CHANGELOG.md")
            icon.name: "view-calendar-list-symbolic"
        }
        Action {
            text: "Releases"
            onTriggered: Qt.openUrlExternally(ghRepo+"/releases")
            icon.name: "update-none-symbolic"
        }

        MenuSeparator { }

        Menu {
            title: "Project page"
            icon.name: "globe"
            Action {
                text: "GitHub"
                onTriggered: Qt.openUrlExternally(ghRepo)
            }
            Action {
                text: "KDE Store"
                onTriggered: Qt.openUrlExternally(kdeStore)
            }
        }

        Menu {
            title: "Issues"
            icon.name: "project-open-symbolic"
            Action {
                text: "Current issues"
                onTriggered: Qt.openUrlExternally(ghRepo+"/issues?q=sort%3Aupdated-desc+is%3Aissue+is%3Aopen")
            }
            Action {
                text: "Report a bug"
                onTriggered: Qt.openUrlExternally(ghRepo+"/issues/new?assignees=&labels=bug&projects=&template=bug_report.md&title=%5BBug%5D%3A+")
            }
            Action {
                text: "Request a feature"
                onTriggered: Qt.openUrlExternally(ghRepo+"/issues/new?assignees=&labels=enhancement&projects=&template=feature_request.md&title=%5BFeature+Request%5D%3A+")
            }
        }

        Menu {
            title: "Help"
            icon.name: "question-symbolic"
            Action {
                text: "Discussions"
                onTriggered: Qt.openUrlExternally(ghRepo+"/discussions")
            }
            Action {
                text: "Send an email"
                onTriggered: Qt.openUrlExternally(email)
            }
        }

        Menu {
            title: "Donate"
            icon.name: "love"
            Action {
                text: "Ko-fi"
                onTriggered: Qt.openUrlExternally(kofi)
            }
            Action {
                text: "Paypal"
                onTriggered: Qt.openUrlExternally(paypal)
            }
            Action {
                text: "GitHub sponsors"
                onTriggered: Qt.openUrlExternally("https://github.com/sponsors/"+ghUser)
            }
        }

        MenuSeparator { }

        Action {
            text: "More projects"
            onTriggered: Qt.openUrlExternally(projects)
            icon.name: "starred-symbolic"
        }
    }
    ToolButton {
        icon.name: "application-menu"
        id: linksButton
        onClicked: {
            if (menu.opened) {
                menu.close()
            } else {
                menu.open()
            }
        }
    }
}
