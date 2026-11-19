pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool dnd: false

    readonly property int maxToasts: 6
    readonly property int defaultTimeout: 4000
    readonly property int criticalTimeout: 0

    readonly property ListModel model: toastModel
    readonly property int count: toastModel.count
    property int revision: 0

    property var _objects: ({})
    property int _sequence: 0

    ListModel {
        id: toastModel
    }

    NotificationServer {
        id: server

        keepOnReload: false
        bodySupported: true
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        bodyImagesSupported: false
        actionsSupported: true
        actionIconsSupported: false
        imageSupported: true
        inlineReplySupported: false
        persistenceSupported: true

        onNotification: notification => root._ingest(notification)
    }

    function notificationFor(id) {
        const entry = root._objects[String(Number(id))]
        return entry ? entry.notification : null
    }

    function actionsFor(id) {
        const notification = root.notificationFor(id)
        return notification ? notification.actions : []
    }

    function dismissToast(id) {
        const notification = root.notificationFor(id)
        root._removeRow(id)
        if (notification)
            notification.dismiss()
    }

    function expireToast(id) {
        const notification = root.notificationFor(id)
        root._removeRow(id)
        if (notification)
            notification.expire()
    }

    function invokeAction(id, identifier) {
        const notification = root.notificationFor(id)
        if (!notification)
            return
        const actions = notification.actions || []
        for (let i = 0; i < actions.length; ++i) {
            if (String(actions[i].identifier) === String(identifier)) {
                actions[i].invoke()
                break
            }
        }
        root._finish(id, notification)
    }

    function activate(id) {
        const notification = root.notificationFor(id)
        if (!notification) {
            root._removeRow(id)
            return
        }
        const actions = notification.actions || []
        let target = null
        for (let i = 0; i < actions.length; ++i) {
            if (String(actions[i].identifier) === "default") {
                target = actions[i]
                break
            }
        }
        if (!target && actions.length === 1)
            target = actions[0]
        if (target)
            target.invoke()
        root._finish(id, notification)
    }

    function _ingest(notification) {
        if (!notification)
            return

        const id = Number(notification.id)
        root._removeRow(id)

        if (root.dnd && notification.urgency !== NotificationUrgency.Critical)
            return

        notification.tracked = true

        const entry = {
            notification: notification,
            sequence: ++root._sequence
        }

        const objects = root._objects
        objects[String(id)] = entry
        root._objects = objects

        notification.closed.connect(() => root._forget(id, entry))

        const urgent = notification.urgency === NotificationUrgency.Critical
        const rawTimeout = notification.expireTimeout
        const timeout = urgent ? root.criticalTimeout
            : (rawTimeout > 0
               ? (rawTimeout < 100 ? Math.round(rawTimeout * 1000) : Math.round(rawTimeout))
               : root.defaultTimeout)

        toastModel.append({
            nid: id,
            seq: entry.sequence,
            appName: String(notification.appName || ""),
            summary: String(notification.summary || ""),
            body: String(notification.body || ""),
            icon: root._iconFor(notification),
            urgent: urgent,
            timeout: timeout
        })

        root.revision++

        while (toastModel.count > root.maxToasts) {
            const victim = toastModel.get(1)
            if (!victim)
                break
            const old = root.notificationFor(victim.nid)
            root._removeRow(victim.nid)
            if (old)
                old.expire()
        }
    }

    function _iconFor(notification) {
        let source = String(notification.appIcon || "")
        if (source.length === 0)
            source = String(notification.image || "")
        if (source.length === 0)
            return ""
        if (source.indexOf("image://icon/") === 0)
            return Quickshell.iconPath(source.substring(13).split("?")[0], true)
        if (source.indexOf("/") >= 0 || source.indexOf(":") >= 0)
            return source
        return Quickshell.iconPath(source, true)
    }

    function _finish(id, notification) {
        root._removeRow(id)
        try {
            notification.dismiss()
        } catch (e) {
        }
    }

    function _removeRow(id) {
        const key = Number(id)
        for (let i = 0; i < toastModel.count; ++i) {
            if (toastModel.get(i).nid === key) {
                toastModel.remove(i)
                root.revision++
                return
            }
        }
    }

    function _forget(id, entry) {
        const key = String(Number(id))
        if (root._objects[key] !== entry)
            return
        root._removeRow(id)
        const objects = root._objects
        delete objects[key]
        root._objects = objects
    }
}
