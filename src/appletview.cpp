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


#include "appletview.h"

#include <QDebug>
#include <QFile>
#include <QGuiApplication>
#include <QTextStream>
#include <QQmlEngine>
#include <QQmlContext>

#include <qpa/qplatformnativeinterface.h>

void AppletView::updateWindowProperties()
{
    m_nativeHandle = QGuiApplication::platformNativeInterface();

    if(m_lipstickSupportsApplets)
        m_nativeHandle->setWindowProperty(handle(), QLatin1String("CATEGORY"), "applet");
    else
        m_nativeHandle->setWindowProperty(handle(), QLatin1String("CATEGORY"), "notification");
}

void AppletView::updateActiveRegion(QRegion region)
{
    if(m_nativeHandle)
        m_nativeHandle->setWindowProperty(handle(), QLatin1String("MOUSE_REGION"), region);
}

AppletView::AppletView(QWindow *parent) :
    QQuickView(parent),
    m_lipstickSupportsApplets(false),
    m_activeAreaShape(Rectangle),
    m_nativeHandle(0)
{

    setColor(QColor(0.0,0.0,0.0,0.0));
    setClearBeforeRendering(true);

    engine()->rootContext()->setContextProperty("thisWindow", this);

    QFile compositorSource("/usr/share/lipstick-jolla-home-qt5/compositor.qml");
    if(compositorSource.open(QFile::ReadOnly) && compositorSource.readAll().contains("appletLayer"))
        m_lipstickSupportsApplets = true;
    else qWarning() << "Lipstick patch not detected. Running in fallback mode!";
}

QRect AppletView::activeArea() const
{
    return m_activeArea;
}

AppletView::Shape AppletView::activeAreaShape() const
{
    return m_activeAreaShape;
}

bool AppletView::fallbackMode() const
{
    return !m_lipstickSupportsApplets;
}

void AppletView::setActiveArea(const QRect &rect)
{
    if(rect != m_activeArea)
    {
        m_activeArea = rect;
        updateActiveRegion(QRegion(m_activeArea, (QRegion::RegionType)m_activeAreaShape));
        emit activeAreaChanged(rect);
    }
}

void AppletView::setActiveAreaShape(AppletView::Shape shape)
{
    if(shape != m_activeAreaShape)
    {
        m_activeAreaShape = shape;
        updateActiveRegion(QRegion(m_activeArea, (QRegion::RegionType)m_activeAreaShape));
        emit activeAreaShapeChanged(shape);
    }
}

void AppletView::show()
{
    QQuickView::show();
    updateWindowProperties();
}

void AppletView::showFullscreen()
{
    QQuickView::showFullScreen();
    updateWindowProperties();
}

void AppletView::showMaxized()
{
    QQuickView::showMaximized();
    updateWindowProperties();
}

void AppletView::showMinimzed()
{
    QQuickView::showMinimized();
    updateWindowProperties();
}

void AppletView::showNormal()
{
    QQuickView::showNormal();
    updateWindowProperties();
}

void AppletView::quit()
{
    qGuiApp->quit();
}
