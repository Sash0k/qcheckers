#include <QDebug>
#include "settings.h"

// Ключи настроек в файле
const QString Settings::s_isWhiteKey = "white";
const QString Settings::s_notationKey = "notation";
const QString Settings::s_themeKey = "theme";

Settings::Settings(const QString &confFilePath, QObject *parent) : QObject(parent)
{
    qInfo() << "Create settings" << confFilePath;
    if (confFilePath.isEmpty()) {
        m_settings = new QSettings(this);
    } else {
        m_settings = new QSettings(confFilePath, QSettings::IniFormat, this);
    }
}

void Settings::setIsWhite(const bool white)
{
    setValue(s_isWhiteKey, white);
    emit whiteSideChanged(white);
}

void Settings::setShowNotation(const bool notation)
{
    setValue(s_notationKey, notation);
    emit notationChanged(notation);
}

void Settings::setTheme(const int theme)
{
    setValue(s_themeKey, theme);
    emit themeChanged(theme);
}

bool Settings::isWhite() const
{
    return value(s_isWhiteKey, true).toBool();
}

bool Settings::notation() const
{
    return value(s_notationKey, false).toBool();
}

int Settings::theme() const
{
    return value(s_themeKey, 0).toInt();
}

/*!
 * \brief Saves the given value with into settings by the given key.
 * \param key Setting key.
 * \param value Value to save.
 */
void Settings::setValue(const QString &key, const QVariant &value)
{
    m_settings->setValue(key, value);
    m_settings->sync();
}

/*!
 * \brief Retrieves the setting value by the given key.
 * \param key Setting key.
 * \param defaultValue Default value of the setting is empty.
 * \return Setting value as QVariant.
 */
QVariant Settings::value(const QString &key, const QVariant &defaultValue) const
{
    m_settings->sync();
    return m_settings->value(key, defaultValue);
}
