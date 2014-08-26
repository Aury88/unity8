/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#ifndef MIRSESSIONITEM_H
#define MIRSESSIONITEM_H

#include "MirSessionItemModel.h"

#include <QQuickItem>

class ApplicationInfo;

class MirSessionItem : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(MirSurfaceItem* surface READ surface NOTIFY surfaceChanged)
    Q_PROPERTY(MirSessionItem* parentSession READ parentSession NOTIFY parentSessionChanged DESIGNABLE false)
    Q_PROPERTY(MirSessionItemModel* childSessions READ childSessions DESIGNABLE false CONSTANT)

    // Only exists in this fake implementation

    // whether the test code will explicitly control the creation of the application surface
    Q_PROPERTY(bool manualSurfaceCreation READ manualSurfaceCreation WRITE setManualSurfaceCreation NOTIFY manualSurfaceCreationChanged)

public:
    explicit MirSessionItem(const QString &name,
                            const QUrl& screenshot,
                            QQuickItem *parent = 0);
    ~MirSessionItem();

    Q_INVOKABLE void release();

    //getters
    QString name() const { return m_name; }
    ApplicationInfo* application() const { return m_application; }
    MirSurfaceItem* surface() const { return m_surface; }
    MirSessionItem* parentSession() const { return m_parentSession; }

    void setApplication(ApplicationInfo* item);
    void setSurface(MirSurfaceItem* surface);
    void setScreenshot(const QUrl& m_screenshot);

    Q_INVOKABLE void addChildSession(MirSessionItem* session);
    void insertChildSession(uint index, MirSessionItem* session);
    void removeChildSession(MirSessionItem* session);

    bool manualSurfaceCreation() const { return m_manualSurfaceCreation; }
    void setManualSurfaceCreation(bool value);

Q_SIGNALS:
    void surfaceChanged(MirSurfaceItem*);
    void parentSessionChanged(MirSessionItem*);
    void removed();
    void aboutToBeDestroyed();
    void manualSurfaceCreationChanged(bool value);

public Q_SLOTS:
    Q_INVOKABLE void createSurface();

private:
    MirSessionItemModel* childSessions() const;
    void setParentSession(MirSessionItem* session);

    QString m_name;
    QUrl m_screenshot;
    ApplicationInfo* m_application;
    MirSurfaceItem* m_surface;
    MirSessionItem* m_parentSession;
    MirSessionItemModel* m_children;

    bool m_manualSurfaceCreation;
};

Q_DECLARE_METATYPE(MirSessionItem*)

#endif // MIRSESSIONITEM_H
