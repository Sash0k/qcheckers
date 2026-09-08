#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QStandardPaths>
#include <QSettings>

class Settings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isWhite READ isWhite WRITE setIsWhite NOTIFY whiteSideChanged)
    Q_PROPERTY(bool notation READ notation WRITE setShowNotation NOTIFY notationChanged)
    Q_PROPERTY(int theme READ theme WRITE setTheme NOTIFY themeChanged)

public:
    explicit Settings(const QString &confFilePath = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation)
            .append("/settings.ini"), QObject *parent = nullptr);

    bool isWhite() const;
    bool notation() const;
    int theme() const;

    void setIsWhite(const bool white);
    void setShowNotation(const bool notation);
    void setTheme(const int theme);

private:
    static const QString s_isWhiteKey;
    static const QString s_notationKey;
    static const QString s_themeKey;

private:
    void setValue(const QString &key, const QVariant &value = QVariant());
    QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;

private:
    QSettings *m_settings;

signals:
    void whiteSideChanged(const bool white);
    void notationChanged(const bool notation);
    void themeChanged(const int theme);
};

#endif // SETTINGS_H
