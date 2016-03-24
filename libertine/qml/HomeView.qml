/**
 * @file HomeView.qml
 * @brief Libertine container apps view
 */
/*
 * Copyright 2015-2016 Canonical Ltd
 *
 * Libertine is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3, as published by the
 * Free Software Foundation.
 *
 * Libertine is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import Libertine 1.0
import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Components.Popups 1.0


Page {
    id: homeView
    title: i18n.tr("Classic Apps") + " - " + mainView.currentContainer

    head.actions: [
        Action {
	    iconName: "add"
	    onTriggered: pageStack.push(Qt.resolvedUrl("AppAddView.qml"))
	},
        Action {
	    id: settingsButton
	    iconName: "settings"
	    onTriggered: PopupUtils.open(settingsMenu, homeView)
	}
    ]

    Component {
	id: settingsMenu
	ActionSelectionPopover {
	    actions: ActionList {
		Action {
		    text: "Configure Container"
		    onTriggered: {
                        pageStack.push(Qt.resolvedUrl("ConfigureContainer.qml"))
                    }
		}
                Action {
                    text: "Update Container"
                    onTriggered: {
                        updateContainer()
                    }
                }
		Action {
		    text: "Switch Container"
		    onTriggered: {
                        pageStack.pop()
                        pageStack.push(Qt.resolvedUrl("ContainersView.qml"))
                    }
		}
	    }
	}
    }

    Component.onCompleted: {
        containerConfigList.configChanged.connect(reloadAppList)
    }

    Component.onDestruction: {
        containerConfigList.configChanged.disconnect(reloadAppList)
    }

    function reloadAppList() {
        containerAppsList.setContainerApps(mainView.currentContainer)
    }

    UbuntuListView {
        anchors.fill: parent
        model: containerAppsList
        delegate: ListItem {
            Label {
                text: packageName
            }
            leadingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "delete"
                        text: i18n.tr("delete")
                        description: i18n.tr("Remove Package")
                        onTriggered: {
                            mainView.currentPackage = packageName
                            removePackage(packageName)
                            pageStack.push(Qt.resolvedUrl("PackageInfoView.qml"))
                        }
                    }
                ]
            }
            trailingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "info"
                        text: i18n.tr("info")
                        description: i18n.tr("Package Info")
                        onTriggered: {
                            mainView.currentPackage = packageName
                            pageStack.push(Qt.resolvedUrl("PackageInfoView.qml"))
                        }
                    }
                ]
            }
        }
    }

    function updateContainer() {
        var comp = Qt.createComponent("ContainerManager.qml")
        var worker = comp.createObject(mainView, {"containerAction": ContainerManagerWorker.Update,
                                                  "containerId": mainView.currentContainer,
                                                  "containerType": containerConfigList.getContainerType(mainView.currentContainer)})
        worker.start()
    }

    function removePackage(packageName) {
        var comp = Qt.createComponent("ContainerManager.qml")
        var worker = comp.createObject(mainView, {"containerAction": ContainerManagerWorker.Remove,
                                                  "containerId": mainView.currentContainer,
                                                  "containerType": containerConfigList.getContainerType(mainView.currentContainer),
                                                  "data": packageName})
        worker.finishedRemove.connect(finishedRemove)
        worker.start()
    }

    function finishedRemove(result, errorMsg) {
        containerAppsList.removeApp()
    }
        
}
