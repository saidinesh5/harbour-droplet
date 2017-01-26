/**
* Project: Droplet Browser
* Copyright 2017, Dinesh Manajipet <saidinesh5@gmail.com>
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful, but
* WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
* or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
* for more details.
*
* You should have received a copy of the GNU Lesser General Public License along
* with this program; if not, write to the Free Software Foundation, Inc.,
* 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

#ifndef QQUICKOVERLAYVIEW_H
#define QQUICKOVERLAYVIEW_H

#include <QQuickView>
#include <QRect>

class QPlatformNativeInterface;

class AppletView : public QQuickView
{
    Q_OBJECT

    Q_PROPERTY(QRect activeArea READ activeArea WRITE setActiveArea NOTIFY activeAreaChanged)
    Q_PROPERTY(Shape activeAreaShape READ activeAreaShape WRITE setActiveAreaShape NOTIFY activeAreaShapeChanged)
    Q_PROPERTY(bool fallbackMode READ fallbackMode CONSTANT)

private:
    void updateWindowProperties();
    void updateActiveRegion(QRegion region);

public:
    enum Shape {
        Rectangle = 0,
        Ellipse = 1
    };
    Q_ENUMS(Shape)

    explicit AppletView(QWindow *parent = 0);

    QRect activeArea() const;
    Shape activeAreaShape() const;
    bool fallbackMode() const;

signals:
    void activeAreaChanged(QRect r);
    void activeAreaShapeChanged(Shape s);

public slots:
    void setActiveArea(const QRect& rect);
    void setActiveAreaShape(Shape shape);

    void show();
    void showFullscreen();
    void showMaxized();
    void showMinimzed();
    void showNormal();

    void quit();

private:
    bool m_lipstickSupportsApplets;
    QString m_sourceFile;
    QRect m_activeArea;
    Shape m_activeAreaShape;

    QPlatformNativeInterface *m_nativeHandle;
};

#endif // QQUICKOVERLAYVIEW_H
