/***************************************************************************
 *   Copyright (C) 2004-2007 Artur Wiebe                                   *
 *   wibix@gmx.de                                                          *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#ifndef _BACKEND_H_
#define _BACKEND_H_

#include <QObject>
#include <QVariant>
#include <QVariantList>
#include <QVariantMap>
#include <QStringList>
#include <QUrl>
#include <QColor>
#include <QFont>
#include <QSettings>

#include "common.h"
#include "pdn.h"
#include "checkers.h"


#define MOVE_SPLIT	'#'


#define BEGINNER	2
#define NOVICE		4
#define AVERAGE		6
#define GOOD		7
#define EXPERT		8
#define MASTER		9

#define COMPUTER	0
#define HUMAN		1


#define CFG_THEME_PATH	"ThemePath"
#define CFG_FILENAME	"Filename"
#define CFG_KEEPDIALOG	"ShowKeepDialog"
#define CFG_NOTATION	"Notation"
#define CFG_NOT_ABOVE	"NotationAbove"
#define CFG_NOT_FONT	"NotationFont"
#define CFG_CLEAR_LOG	"ClearLogOnNewRound"
#define CFG_SKILL	"Skill"
#define CFG_RULES	"Rules"
#define CFG_WHITE	"White"
#define CFG_PLAYER1	"Player1"
#define CFG_PLAYER2	"Player2"
#define CFG_OPPONENT	"Opponent"
#define CFG_GEOMETRY	"WindowGeometry"


class myPlayer;
class HistoryController;


/*
 * Exposes the images and colors of a theme to the QML user interface.
 */
class ThemeInfo : public QObject
{
	Q_OBJECT

	Q_PROPERTY(QString themeName READ name CONSTANT)
	Q_PROPERTY(QUrl manWhite READ manWhite CONSTANT)
	Q_PROPERTY(QUrl manBlack READ manBlack CONSTANT)
	Q_PROPERTY(QUrl kingWhite READ kingWhite CONSTANT)
	Q_PROPERTY(QUrl kingBlack READ kingBlack CONSTANT)
	Q_PROPERTY(QUrl tile1 READ tile1 CONSTANT)
	Q_PROPERTY(QUrl tile2 READ tile2 CONSTANT)
	Q_PROPERTY(QUrl frame READ frame CONSTANT)
	Q_PROPERTY(QColor notationFontColor READ notationFontColor CONSTANT)
	Q_PROPERTY(QColor notationBackgroundColor READ notationBackgroundColor CONSTANT)

public:
	ThemeInfo(const QString& theme_path, QObject* parent = 0);

	QString name() const { return m_name; }
	bool isValid() const { return m_valid; }

	QUrl manWhite() const { return makeUrl(m_man_white_path); }
	QUrl manBlack() const { return makeUrl(m_man_black_path); }
	QUrl kingWhite() const { return makeUrl(m_king_white_path); }
	QUrl kingBlack() const { return makeUrl(m_king_black_path); }
	QUrl tile1() const { return makeUrl(m_tile1_path); }
	QUrl tile2() const { return makeUrl(m_tile2_path); }
	QUrl frame() const { return makeUrl(m_frame_path); }

	QColor notationFontColor() const { return m_notation_font_color; }
	QColor notationBackgroundColor() const { return m_notation_bg_color; }

private:
	static QUrl makeUrl(const QString& path)
	{
		if(path.startsWith("qrc:"))
			return QUrl(path);
		return QUrl::fromLocalFile(path);
	}

	QString m_name;
	QString m_tile1_path;
	QString m_tile2_path;
	QString m_frame_path;
	QString m_man_black_path;
	QString m_man_white_path;
	QString m_king_black_path;
	QString m_king_white_path;
	QColor m_notation_font_color;
	QColor m_notation_bg_color;
	bool m_valid;
};


/*
 * QML friendly re-implementation of the history dock. It wraps the PDN
 * parser and exposes games, tags and moves as plain lists.
 */
class HistoryController : public QObject
{
	Q_OBJECT

	Q_PROPERTY(QStringList games READ games NOTIFY changed)
	Q_PROPERTY(int currentGame READ currentGame NOTIFY changed)
	Q_PROPERTY(QVariantList tags READ tags NOTIFY changed)
	Q_PROPERTY(QVariantList moves READ moves NOTIFY changed)
	Q_PROPERTY(int currentMoveIndex READ currentMoveIndex NOTIFY currentMoveChanged)
	Q_PROPERTY(bool paused READ paused NOTIFY modeChanged)
	Q_PROPERTY(bool freePlacement READ freePlacement NOTIFY modeChanged)
	Q_PROPERTY(QString currentPlayer READ currentPlayer NOTIFY currentPlayerChanged)

public:
	HistoryController(QObject* parent = 0);
	~HistoryController();

	QStringList games() const { return m_games; }
	int currentGame() const { return m_gameIndex; }
	QVariantList tags() const { return m_tags; }
	QVariantList moves() const { return m_moves; }
	int currentMoveIndex() const { return m_currentMoveIndex; }

	bool paused() const { return m_paused; }
	bool freePlacement() const { return m_freeplace; }
	QString currentPlayer() const { return m_currentPlayer; }

	void newPdn(const QString& event, bool freePlacement);
	bool openPdn(const QString& filename, QString& log_text);
	bool savePdn(const QString& fn);
	void clear();

	void setTag(PdnGame::Tag, const QString& val);
	QString getTag(PdnGame::Tag);

    void appendMove(const QString& move, const QString& comment);
	int moveCount() const { return m_moves.count() - 1; }

	void setCurrent(const QString& t) { m_currentPlayer = t; emit currentPlayerChanged(); }

	static QString typeToString(int type);

public slots:
	void slotWorking(bool b) { emit changed(); }

	void selectGame(int index) { slot_game_selected(index); }
	void selectMove(int index) { m_currentMoveIndex = index; emit currentMoveChanged(); slot_move(index); }
	void undo();
	void redo();
	void continueGame();

signals:
	void changed();
	void modeChanged();
	void currentPlayerChanged();
	void currentMoveChanged();
	void previewGame(int game_type);
	void applyMoves(const QString& moves);
	void newMode(bool paused, bool freeplace);

private:
	QString tag_to_string(PdnGame::Tag);
	void set_mode(bool paused);
	void do_moves();
	void history_undo(bool move_backwards);
	void delete_moves();
	void slot_game_selected(int index);
	void slot_move(int item_index);

private:
	QStringList m_games;
	int m_gameIndex;
	QVariantList m_tags;
	QVariantList m_moves;
	int m_currentMoveIndex;

	Pdn* m_pdn;
	PdnGame* m_game;

	bool m_paused;
	bool m_freeplace;
	bool m_disableMoves;
	QString m_currentPlayer;
};


/*
 * The bridge between the QML user interface and the checkers engine.
 * Re-implements the controller logic of the former widgets view.
 */
class GameController : public QObject
{
	Q_OBJECT

	Q_PROPERTY(QObject* theme READ theme NOTIFY themeChanged)
	Q_PROPERTY(QObject* history READ history CONSTANT)
	Q_PROPERTY(QVariantList board READ board NOTIFY boardChanged)
	Q_PROPERTY(QVariantList labels READ labels NOTIFY labelsChanged)
	Q_PROPERTY(bool bottomIsWhite READ bottomIsWhite NOTIFY bottomIsWhiteChanged)
	Q_PROPERTY(int selectedField READ selectedField NOTIFY selectedChanged)
	Q_PROPERTY(bool working READ working NOTIFY workingChanged)
	Q_PROPERTY(bool aborted READ aborted NOTIFY abortedChanged)
	Q_PROPERTY(QString gameTypeName READ gameTypeName NOTIFY gameChanged)
	Q_PROPERTY(QString themePath READ themePath WRITE setThemePath)
	Q_PROPERTY(bool clearLog READ clearLog WRITE setClearLog)
	Q_PROPERTY(bool keepDialog READ keepDialog WRITE setKeepDialog)
	Q_PROPERTY(QFont notationFont READ notationFont WRITE setNotationFont)

public:
	GameController(QObject* parent = 0);
	~GameController();

	QObject* theme() const { return m_theme; }
	HistoryController* history() const { return m_history; }
	QVariantList board() const { return m_boardList; }
	QVariantList labels() const;
	bool bottomIsWhite() const { return m_bottomIsWhite; }
	int selectedField() const { return m_selectedField; }
	bool working() const { return m_working; }
	bool aborted() const { return m_aborted; }
	QString gameTypeName() const;

	QString themePath() const { return m_themePath; }
	bool clearLog() const { return m_clearLog; }
	bool keepDialog() const { return m_keepDialog; }
	QFont notationFont() const { return m_notationFont; }

public slots:
	void setThemePath(const QString& path) { setTheme(path); }
	void setClearLog(bool b) { m_clearLog = b; m_settings->setValue(CFG_CLEAR_LOG, b); }
	void setKeepDialog(bool b) { m_keepDialog = b; m_settings->setValue(CFG_KEEPDIALOG, b); }
	void setNotationFont(const QFont& f) { m_notationFont = f; m_settings->setValue(CFG_NOT_FONT, f.toString()); }

	// game controls, called from QML
	void newGame(int rules, bool freePlacement,
			const QString& name, bool is_white,
			int opponent, const QString& opp_name, int skill);
	void clickField(int field_num);
	void stopGame();
	void nextRound();
	bool openGame(const QString& fn) { return openPdn(fn); }
	bool saveGame(const QString& fn) { return savePdn(fn); }
	void setTheme(const QString& path);
	void setNotation(bool enabled, bool show_above);
	void slotClearLog(bool b) { m_clearLog = b; }

	// settings access for the "new game" dialog
	Q_INVOKABLE int newGameRules() const { return m_cfgRules; }
	Q_INVOKABLE QString player1Name() const { return m_cfgPlayer1; }
	Q_INVOKABLE bool player1White() const { return m_cfgWhite; }
	Q_INVOKABLE int player2Opponent() const { return m_cfgOpponent; }
	Q_INVOKABLE QString player2Name() const { return m_cfgPlayer2; }
	Q_INVOKABLE int player2Skill() const { return m_cfgSkill; }
	void saveNewGameSettings(int rules, bool white, const QString& p1,
			int opponent, const QString& p2, int skill);
	Q_INVOKABLE QString lastFilename() const { return m_filename; }
	Q_INVOKABLE void setLastFilename(const QString& fn) { m_filename = fn; }

	// themes
	Q_INVOKABLE QVariantList themes() const;

	// window handling
	Q_INVOKABLE QVariantList windowGeometry() const;
	Q_INVOKABLE void storeWindowGeometry(int x, int y, int w, int h);
	Q_INVOKABLE void storeSettings();

signals:
	void themeChanged();
	void boardChanged();
	void labelsChanged();
	void bottomIsWhiteChanged();
	void selectedChanged();
	void workingChanged();
	void abortedChanged();
	void gameChanged();
	void currentChanged();
	void logMessage(int type, const QString& text);
	void clearLogRequested();
	void moveAnimate(int from, int to);

private slots:
	void slot_move_done(const QString& board_str);
	void slot_move_done_step_two();
	void slot_preview_game(int rules);
	void slot_apply_moves(const QString& moves);
	void slot_new_mode(bool paused, bool freeplace);

private:
	enum LogType {
		None,
		Error,
		Warning,
		System,
		User,
		Opponent,
	};

	void begin_game(unsigned int round, bool freePlacement);
	void setGame(int rules);
	void resetBoard();
	void updateBoard();
	void updateLabels();
	void perform_jumps(const QString& from_board, const QString& to_board);
	QString doMove(int from_num, int to_num, bool white_player);
	bool doMove(const QString& move, bool white_player);
	bool convert_move(const QString& move, int* from_num, int* to_num);
	void doFreeMove(int from, int to);
	bool check_game_over();
	void you_won(bool yes);
	void add_log(enum LogType type, const QString& text);
	myPlayer* get_first_player() const;
	bool openPdn(const QString& fn);
	bool savePdn(const QString& fn);
	void setWorking(bool w);
	void readSettings();

private:
	QSettings* m_settings;

	myPlayer* m_player;
	myPlayer* m_current;
	HistoryController* m_history;
	Checkers* m_game;
	ThemeInfo* m_theme;

	bool m_clearLog;
	bool m_keepDialog;
	bool m_gameOver;
	bool m_aborted;
	bool m_working;
	bool m_bottomIsWhite;

	int m_selectedField;
	int m_freeplaceFrom;

	QVariantList m_boardList;
	QStringList m_labels;

	QString m_themePath;
	QString m_filename;
	QFont m_notationFont;

	// new game defaults
	int m_cfgRules;
	int m_cfgSkill;
	bool m_cfgWhite;
	int m_cfgOpponent;
	QString m_cfgPlayer1;
	QString m_cfgPlayer2;
};

#endif
