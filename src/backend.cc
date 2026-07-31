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

#include <QDate>
#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>
#include <QTimer>
#include <QList>
#include <QPair>
#include <QDebug>
#include <stdlib.h>

#include "backend.h"
#include "echeckers.h"
#include "rcheckers.h"
#include "player.h"
#include "humanplayer.h"
#include "computerplayer.h"


#define MOVE_PAUSE		1000


/***************************************************************************
 *  ThemeInfo
 ***************************************************************************/
ThemeInfo::ThemeInfo(const QString& theme_path, QObject* parent)
	: QObject(parent)
{
	m_valid = false;
	m_notation_font_color = Qt::white;
	m_notation_bg_color = Qt::black;

	if(theme_path == DEFAULT_THEME) {
		m_name = QString(DEFAULT_THEME);
		m_tile1_path = "qrc:/icons/theme/tile1.png";
		m_tile2_path = "qrc:/icons/theme/tile2.png";
		m_frame_path = "qrc:/icons/theme/frame.png";
		m_man_black_path = "qrc:/icons/theme/manblack.png";
		m_man_white_path = "qrc:/icons/theme/manwhite.png";
		m_king_black_path = "qrc:/icons/theme/kingblack.png";
		m_king_white_path = "qrc:/icons/theme/kingwhite.png";
		m_notation_font_color = Qt::white;
		m_notation_bg_color = Qt::black;
		m_valid = true;
		return;
	}

	QDir dir(theme_path);
	if(!dir.exists())
		return;

	QSettings settings(theme_path + "/" THEME_FILE, QSettings::IniFormat);
	m_name = settings.value("name", dir.dirName()).toString();

	m_tile1_path = theme_path + "/" + settings.value("tile1", THEME_TILE1).toString();
	m_tile2_path = theme_path + "/" + settings.value("tile2", THEME_TILE2).toString();
	m_frame_path = theme_path + "/" + settings.value("frame", THEME_FRAME).toString();
	m_man_black_path = theme_path + "/" + settings.value("man_black", THEME_MANBLACK).toString();
	m_man_white_path = theme_path + "/" + settings.value("man_white", THEME_MANWHITE).toString();
	m_king_black_path = theme_path + "/" + settings.value("king_black", THEME_KINGBLACK).toString();
	m_king_white_path = theme_path + "/" + settings.value("king_white", THEME_KINGWHITE).toString();
	m_notation_font_color = QColor(settings.value("field_notation_color", "white").toString());
	m_notation_bg_color = QColor(settings.value("field_notation_background", "black").toString());

	m_valid =
		QFileInfo::exists(m_tile1_path) &&
		QFileInfo::exists(m_tile2_path) &&
		QFileInfo::exists(m_frame_path) &&
		QFileInfo::exists(m_man_black_path) &&
		QFileInfo::exists(m_man_white_path) &&
		QFileInfo::exists(m_king_black_path) &&
		QFileInfo::exists(m_king_white_path);
}


/***************************************************************************
 *  HistoryController
 ***************************************************************************/
HistoryController::HistoryController(QObject* parent)
	: QObject(parent)
{
	m_pdn = new Pdn();
	m_game = 0;
	m_disableMoves = false;
	m_paused = true;
	m_freeplace = false;
	m_gameIndex = 0;
	m_currentMoveIndex = 0;

	clear();
	set_mode(false);
}


HistoryController::~HistoryController()
{
	delete m_pdn;
}


void HistoryController::clear()
{
	m_games.clear();
	m_pdn->clear();
	m_tags.clear();
	m_moves.clear();

	QVariantMap root;
	root["number"] = "";
	root["move"] = "";
	root["comment"] = "";
	m_moves.append(root);

	m_gameIndex = 0;
	m_currentMoveIndex = 0;
	m_game = 0;

	emit changed();
}


QString HistoryController::typeToString(int type)
{
	switch(type) {
	case ENGLISH:	return tr("English draughts");
	case RUSSIAN:	return tr("Russian draughts");
	};
	return tr("Unknown game type");
}


QString HistoryController::tag_to_string(PdnGame::Tag tag)
{
	switch(tag) {
	case PdnGame::Date:	return QString("Date");
	case PdnGame::Site:	return QString("Site");
	case PdnGame::Type:	return QString("Type");
	case PdnGame::Event:	return QString("Event");
	case PdnGame::Round:	return QString("Round");
	case PdnGame::White:	return QString("White");
	case PdnGame::Black:	return QString("Black");
	case PdnGame::Result:	return QString("Result");
	}

	return QString("Site");
}


void HistoryController::setTag(PdnGame::Tag tag, const QString& val)
{
	QString name = tag_to_string(tag);
	QString display = val;

	if(tag == PdnGame::Type) {
		display = val + " (" + typeToString(QString("%1").arg(val).toInt()) + ")";
	}

	bool found = false;
	for(int i = 0; i < m_tags.count(); ++i) {
		QVariantMap m = m_tags[i].toMap();
		if(m["name"].toString() == name) {
			m["value"] = display;
			m_tags[i] = m;
			found = true;
			break;
		}
	}
	if(!found) {
		QVariantMap m;
		m["name"] = name;
		m["value"] = display;
		m_tags.append(m);
	}

	if(m_game) {
		m_game->set(tag, val);
	}
	emit changed();
}


QString HistoryController::getTag(PdnGame::Tag tag)
{
	QString name = tag_to_string(tag);
	for(int i = 0; i < m_tags.count(); ++i) {
		QVariantMap m = m_tags[i].toMap();
		if(m["name"].toString() == name) {
			QString val = m["value"].toString();
			if(tag == PdnGame::Type) {
				int p = val.lastIndexOf(" (");
				if(p > 0)
					val = val.left(p);
			}
			return val;
		}
	}
	return "";
}


void HistoryController::appendMove(const QString& text, const QString& comm)
{
	m_disableMoves = true;

	QVariantMap new_item;
	new_item["number"] = "";
	new_item["move"] = text;
	new_item["comment"] = comm;
	m_moves.append(new_item);

	int move_nr = (m_moves.count() - 2) / 2;
	PdnMove* m = m_game->getMove(move_nr);

	if(m_moves.count() % 2) {
		m->m_second = text;
		m->m_comsecond = comm;
	} else {
		QVariantMap last = m_moves.last().toMap();
		last["number"] = QString("%1.").arg(move_nr + 1);
		m_moves[m_moves.count() - 1] = last;
		m->m_first = text;
		m->m_comfirst = comm;
	}

	m_currentMoveIndex = m_moves.count() - 1;
	m_disableMoves = false;

	emit currentMoveChanged();
	emit changed();
}


void HistoryController::slot_game_selected(int index)
{
	if(!m_pdn || index < 0 || index >= m_pdn->count())
		return;

	m_gameIndex = index;
	m_game = m_pdn->game(index);

	m_moves.clear();
	QVariantMap root;
	root["number"] = "";
	root["move"] = "";
	root["comment"] = "";
	m_moves.append(root);
	m_currentMoveIndex = 0;

	m_disableMoves = true;
	for(int i = 0; i < m_game->movesCount(); ++i) {
		PdnMove* m = m_game->getMove(i);
		appendMove(m->m_first, m->m_comfirst);
		if(m->m_second.length())
			appendMove(m->m_second, m->m_comsecond);
	}
	m_disableMoves = false;

	setTag(PdnGame::Site,	m_game->get(PdnGame::Site));
	setTag(PdnGame::Black,	m_game->get(PdnGame::Black));
	setTag(PdnGame::White,	m_game->get(PdnGame::White));
	setTag(PdnGame::Result,	m_game->get(PdnGame::Result));
	setTag(PdnGame::Date,	m_game->get(PdnGame::Date));
	setTag(PdnGame::Type,	m_game->get(PdnGame::Type));
	setTag(PdnGame::Round,	m_game->get(PdnGame::Round));
	setTag(PdnGame::Event,	m_game->get(PdnGame::Event));

	if(m_paused && !m_freeplace) {
		emit previewGame(m_game->get(PdnGame::Type).toInt());
	}

	m_currentMoveIndex = 0;
	emit currentMoveChanged();
	slot_move(0);
	emit changed();
}


bool HistoryController::openPdn(const QString& filename, QString& log_text)
{
	if(!m_pdn->open(filename, log_text)) {
		set_mode(false);
		return false;
	}

	set_mode(true);

	m_games.clear();
	m_tags.clear();
	m_moves.clear();
	QVariantMap root;
	root["number"] = "";
	root["move"] = "";
	root["comment"] = "";
	m_moves.append(root);

	for(int i = 0; i < m_pdn->count(); ++i) {
		m_games.append(m_pdn->game(i)->get(PdnGame::Event));
	}

	slot_game_selected(0);
	emit changed();
	return true;
}


bool HistoryController::savePdn(const QString& fn)
{
	return m_pdn->save(fn);
}


void HistoryController::newPdn(const QString& event, bool freePlacement)
{
	m_freeplace = freePlacement;
	m_paused = !m_freeplace;
	set_mode(m_freeplace);

	m_game = m_pdn->newGame();
	m_game->set(PdnGame::Event, event);

	m_games.append(event);
	slot_game_selected(m_games.count() - 1);
}


void HistoryController::set_mode(bool paused)
{
	if(m_paused != paused) {
		m_paused = paused;
		emit modeChanged();
		emit newMode(m_paused, m_freeplace);
	}
}


void HistoryController::slot_move(int item_index)
{
	if(m_paused && !m_disableMoves && item_index >= 0 && item_index < m_moves.count()) {
		do_moves();
	}
	emit currentMoveChanged();
}


void HistoryController::do_moves()
{
	QString moves;
	for(int i = 1; i <= m_currentMoveIndex && i < m_moves.count(); ++i) {
		moves += m_moves[i].toMap()["move"].toString() + MOVE_SPLIT;
	}
	emit applyMoves(moves);
}


void HistoryController::history_undo(bool move_backwards)
{
	int next = m_currentMoveIndex + (move_backwards ? -1 : +1);
	if(next >= 0 && next < m_moves.count()) {
		m_currentMoveIndex = next;
		emit currentMoveChanged();
		emit changed();
	}
}


void HistoryController::delete_moves()
{
	while(m_moves.count() > m_currentMoveIndex + 1) {
		m_moves.removeLast();
	}
	emit changed();
}


void HistoryController::undo()
{
	set_mode(true);
	history_undo(true);
	do_moves();
}


void HistoryController::redo()
{
	set_mode(true);
	history_undo(false);
	do_moves();
}


void HistoryController::continueGame()
{
	delete_moves();
	set_mode(false);
}


/***************************************************************************
 *  GameController
 ***************************************************************************/
GameController::GameController(QObject* parent)
	: QObject(parent)
{
	m_settings = new QSettings(APPNAME, APPNAME, this);

	m_player = 0;
	m_current = 0;
	m_game = 0;
	m_theme = 0;

	m_clearLog = true;
	m_keepDialog = true;
	m_gameOver = false;
	m_aborted = false;
	m_working = false;
	m_bottomIsWhite = false;

	m_selectedField = -1;
	m_freeplaceFrom = -1;

	m_themePath = DEFAULT_THEME;

	m_history = new HistoryController(this);

	connect(m_history, SIGNAL(previewGame(int)),
			this, SLOT(slot_preview_game(int)));
	connect(m_history, SIGNAL(applyMoves(const QString&)),
			this, SLOT(slot_apply_moves(const QString&)));
	connect(m_history, SIGNAL(newMode(bool,bool)),
			this, SLOT(slot_new_mode(bool,bool)));
	connect(m_history, SIGNAL(modeChanged()),
			this, SIGNAL(currentChanged()));

	readSettings();

	setTheme(m_themePath);

	// start a default game, like the old main window did.
	newGame(m_cfgRules, false, m_cfgPlayer1, m_cfgWhite,
			m_cfgOpponent, m_cfgPlayer2, m_cfgSkill);
}


GameController::~GameController()
{
	if(m_player) {
		delete m_player;
		delete m_player->opponent();
	}
	if(m_game) {
		delete m_game;
	}
	delete m_theme;
}


void GameController::readSettings()
{
	m_themePath = m_settings->value(CFG_THEME_PATH, DEFAULT_THEME).toString();
	m_filename = m_settings->value(CFG_FILENAME).toString();
	m_clearLog = m_settings->value(CFG_CLEAR_LOG, true).toBool();
	m_keepDialog = m_settings->value(CFG_KEEPDIALOG, true).toBool();

	QFont f;
	if(f.fromString(m_settings->value(CFG_NOT_FONT, "").toString()))
		m_notationFont = f;

	m_cfgSkill = m_settings->value(CFG_SKILL, BEGINNER).toInt();
	m_cfgRules = m_settings->value(CFG_RULES, ENGLISH).toInt();
	m_cfgWhite = m_settings->value(CFG_WHITE, false).toBool();
	m_cfgOpponent = m_settings->value(CFG_OPPONENT, COMPUTER).toInt();
	m_cfgPlayer1 = m_settings->value(CFG_PLAYER1, QString(getenv("USER"))).toString();
	m_cfgPlayer2 = m_settings->value(CFG_PLAYER2, "Player2").toString();
}


void GameController::storeSettings()
{
	m_settings->setValue(CFG_THEME_PATH, m_themePath);
	m_settings->setValue(CFG_FILENAME, m_filename);
	m_settings->setValue(CFG_NOTATION, true);
	m_settings->setValue(CFG_NOT_ABOVE, true);
	m_settings->setValue(CFG_KEEPDIALOG, m_keepDialog);
	m_settings->setValue(CFG_CLEAR_LOG, m_clearLog);
	m_settings->setValue(CFG_NOT_FONT, m_notationFont.toString());
	m_settings->setValue(CFG_SKILL, m_cfgSkill);
	m_settings->setValue(CFG_RULES, m_cfgRules);
	m_settings->setValue(CFG_WHITE, m_cfgWhite);
	m_settings->setValue(CFG_PLAYER1, m_cfgPlayer1);
	m_settings->setValue(CFG_PLAYER2, m_cfgPlayer2);
	m_settings->setValue(CFG_OPPONENT, m_cfgOpponent);
}


void GameController::saveNewGameSettings(int rules, bool white,
		const QString& p1, int opponent, const QString& p2, int skill)
{
	m_cfgRules = rules;
	m_cfgWhite = white;
	m_cfgOpponent = opponent;
	m_cfgPlayer1 = p1;
	m_cfgPlayer2 = p2;
	m_cfgSkill = skill;

	m_settings->setValue(CFG_SKILL, skill);
	m_settings->setValue(CFG_RULES, rules);
	m_settings->setValue(CFG_WHITE, white);
	m_settings->setValue(CFG_PLAYER1, p1);
	m_settings->setValue(CFG_PLAYER2, p2);
	m_settings->setValue(CFG_OPPONENT, opponent);
}


QVariantList GameController::themes() const
{
	QVariantList result;

	QVariantMap def;
	def["name"] = tr(DEFAULT_THEME);
	def["path"] = DEFAULT_THEME;
	result.append(def);

	QStringList paths;
	paths << QDir::homePath() + "/" USER_PATH "/" THEME_DIR;
	QString system = QStandardPaths::locate(QStandardPaths::DataLocation,
			THEME_DIR, QStandardPaths::LocateDirectory);
	if(!system.isEmpty())
		paths << system;

	foreach(QString path, paths) {
		QDir dir(path);
		if(!dir.exists())
			continue;

		QStringList sub = dir.entryList(QDir::Dirs | QDir::Readable);
		sub.removeAll(".");
		sub.removeAll("..");
		foreach(QString s, sub) {
			QString theme_dir = dir.absoluteFilePath(s);
			ThemeInfo* info = new ThemeInfo(theme_dir, 0);
			if(info->isValid()) {
				QVariantMap m;
				m["name"] = info->name();
				m["path"] = theme_dir;
				result.append(m);
			}
			delete info;
		}
	}

	return result;
}


QVariantList GameController::windowGeometry() const
{
	QVariantList g;
	QByteArray ba = m_settings->value(CFG_GEOMETRY).toByteArray();
	if(ba.size() != 4 * sizeof(int))
		return g;
	const int* p = (const int*)ba.constData();
	g << p[0] << p[1] << p[2] << p[3];
	return g;
}


void GameController::storeWindowGeometry(int x, int y, int w, int h)
{
	int data[4];
	data[0] = x;
	data[1] = y;
	data[2] = w;
	data[3] = h;
	m_settings->setValue(CFG_GEOMETRY,
			QByteArray((const char*)data, 4 * sizeof(int)));
}


QString GameController::gameTypeName() const
{
	if(!m_game)
		return "";
	return HistoryController::typeToString(m_game->type());
}


void GameController::setTheme(const QString& path)
{
	m_themePath = path;
	m_settings->setValue(CFG_THEME_PATH, path);

	delete m_theme;
	m_theme = new ThemeInfo(path, this);
	emit themeChanged();
}


void GameController::setNotation(bool enabled, bool show_above)
{
	Q_UNUSED(enabled);
	Q_UNUSED(show_above);
	m_settings->setValue(CFG_NOTATION, enabled);
	m_settings->setValue(CFG_NOT_ABOVE, show_above);
}


void GameController::setWorking(bool w)
{
	if(m_working != w) {
		m_working = w;
		emit workingChanged();
	}
}


void GameController::newGame(int rules, bool freePlacement,
		const QString& name, bool is_white,
		int opponent, const QString& opp_name, int skill)
{
	m_freeplaceFrom = -1;
	m_selectedField = -1;
	emit selectedChanged();

	if(m_player) {
		delete m_player;
		delete m_player->opponent();
	}

	m_bottomIsWhite = is_white;
	emit bottomIsWhiteChanged();

	myPlayer* plr = new myHumanPlayer(name, is_white, false);
	myPlayer* opp = 0;
	if(opponent == HUMAN)
		opp = new myHumanPlayer(opp_name, !is_white, true);
	else
		opp = new myComputerPlayer(opp_name, !is_white, skill);

	m_player = plr;

	plr->setOpponent(opp);
	opp->setOpponent(plr);

	plr->disconnect();
	opp->disconnect();

	connect(plr, SIGNAL(moveDone(const QString&)),
			this, SLOT(slot_move_done(const QString&)));
	connect(opp, SIGNAL(moveDone(const QString&)),
			this, SLOT(slot_move_done(const QString&)));

	setGame(rules);
	m_history->clear();

	begin_game(1, freePlacement);
}


void GameController::setGame(int rules)
{
	if(m_game) {
		delete m_game;
	}

	if(rules == ENGLISH)
		m_game = new ECheckers();
	else
		m_game = new RCheckers();

	resetBoard();
	updateBoard();
	updateLabels();
	emit gameChanged();
}


void GameController::resetBoard()
{
	int new_board[32];
	for(int i = 0; i < 12; i++)
		new_board[i] = MAN2;
	for(int i = 12; i < 20; i++)
		new_board[i] = FREE;
	for(int i = 20; i < 32; i++)
		new_board[i] = MAN1;

	if(m_game)
		m_game->setup(new_board);
}


void GameController::updateBoard()
{
	m_boardList.clear();
	for(int i = 0; i < 32; i++) {
		m_boardList.append(m_game->item(i));
	}
	emit boardChanged();
}


void GameController::updateLabels()
{
	m_labels.clear();
	for(int i = 0; i < 32; i++) {
		m_labels.append(m_game->getFieldNotation(i, m_bottomIsWhite));
	}
	emit labelsChanged();
}


QVariantList GameController::labels() const
{
	QVariantList result;
	foreach(QString label, m_labels) {
		result.append(label);
	}
	return result;
}


void GameController::stopGame()
{
	if(m_player) {
		m_player->stop();
		m_player->opponent()->stop();
	}
}


void GameController::begin_game(unsigned int round, bool freePlacement)
{
	if(m_clearLog)
		emit clearLogRequested();

	updateLabels();

	m_history->newPdn(APPNAME" Game", freePlacement);
	m_history->setTag(PdnGame::Type, QString::number(m_game->type()));
	m_history->setTag(PdnGame::Date, QDate::currentDate().toString("yyyy.MM.dd"));
	m_history->setTag(PdnGame::Result, "*");
	m_history->setTag(PdnGame::Round, QString::number(round));

	myPlayer* last_player = get_first_player()->opponent();

	m_gameOver = false;
	m_aborted = false;
	m_current = last_player;

	if(m_player->isWhite()) {
		m_history->setTag(PdnGame::White, m_player->name());
		m_history->setTag(PdnGame::Black, m_player->opponent()->name());
	} else {
		m_history->setTag(PdnGame::White, m_player->opponent()->name());
		m_history->setTag(PdnGame::Black, m_player->name());
	}

	emit currentChanged();

	if(m_history->freePlacement())
		setWorking(false);
	else
		slot_move_done(m_game->toString(false));
}


void GameController::clickField(int field_num)
{
	if(m_gameOver || m_aborted)
		return;

	if(m_history->paused()) {
		if(m_history->freePlacement()) {
			if(m_freeplaceFrom < 0) {
				m_freeplaceFrom = field_num;
				m_selectedField = field_num;
				emit selectedChanged();
			} else {
				doFreeMove(m_freeplaceFrom, field_num);
				m_freeplaceFrom = -1;
				m_selectedField = -1;
				emit selectedChanged();
			}
		}
	} else {
		bool select = false;
		QString err_msg;
		if(!m_current->fieldClicked(field_num, &select, m_player->isWhite(), err_msg)) {
			add_log(Warning,
					m_current->name() + ": "
					+ (err_msg.length() ? err_msg : tr("Invalid move.")));
		} else {
			m_selectedField = select ? field_num : -1;
			emit selectedChanged();
		}
	}
}


void GameController::doFreeMove(int from, int to)
{
	int old_to = m_game->item(to);
	int old_from = m_game->item(from);
	m_game->setItem(to, old_from);
	m_game->setItem(from, old_to);
	updateBoard();
}


QString GameController::doMove(int from_num, int to_num, bool white_player)
{
	bool bottom_player = (white_player && m_bottomIsWhite)
		|| (!white_player && !m_bottomIsWhite);

	int from_pos = from_num;
	int to_pos = to_num;

	if(!bottom_player) {
		from_pos = 31 - from_pos;
		to_pos = 31 - to_pos;
		m_game->fromString(m_game->toString(true));
	}
	if(!m_game->go1(from_pos, to_pos)) {
		return QString::null;
	}
	if(!bottom_player) {
		m_game->fromString(m_game->toString(true));
	}

	updateBoard();
	emit moveAnimate(from_num, to_num);

	return QString("%1?%2")
		.arg(m_labels[from_num])
		.arg(m_labels[to_num]);
}


bool GameController::doMove(const QString& move, bool white_player)
{
	int from_pos, to_pos;
	if(convert_move(move, &from_pos, &to_pos)) {
		doMove(from_pos, to_pos, white_player);
		return true;
	}
	return false;
}


bool GameController::convert_move(const QString& move_orig, int* from_num, int* to_num)
{
	QString move = move_orig.toUpper().replace('X', '-');
	QString from;
	QString to;
	int sect = move.count('-');

	*from_num = *to_num = -1;

	from = move.section('-', 0, 0);
	to = move.section('-', sect, sect);

	if(!from.isNull() && !to.isNull()) {
		for(int i = 0; i < 32; i++) {
			if(m_labels[i] == from)
				*from_num = i;
			if(m_labels[i] == to)
				*to_num = i;
		}

		if(*from_num >= 0 && *to_num >= 0)
			return true;
	}

	return false;
}


void GameController::perform_jumps(const QString& from_board, const QString& to_board)
{
	if(from_board == to_board)
		return;

	QString new_to_board = to_board;

	QList<QPair<int, QPair<int, int> > > diff_list;

	for(int i = 0; i < 32; i++) {
		if(from_board[2*i] != new_to_board[2*i]
				|| from_board[2*i+1] != new_to_board[2*i+1]) {
			diff_list.append(qMakePair(i,
					qMakePair(from_board.mid(2*i, 2).toInt(),
						new_to_board.mid(2*i, 2).toInt())));
		}
	}

	int from_pos = -1;
	int to_pos = -1;
	bool captured = (diff_list.count() > 2);

	int man = -1;
	for(int d = 0; d < diff_list.count(); d++) {
		if(diff_list[d].second.second != FREE) {
			man = diff_list[d].second.second;
			to_pos = diff_list[d].first;
			break;
		}
	}

	int king = -1;
	switch(man) {
	case MAN1:	king = KING1; break;
	case KING1:	king = MAN1; break;
	case MAN2:	king = KING2; break;
	case KING2:	king = MAN2; break;
	}

	for(int d = 0; d < diff_list.count(); d++) {
		if(diff_list[d].second.second == FREE) {
			if(diff_list[d].second.first == man
					|| diff_list[d].second.first == king) {
				from_pos = diff_list[d].first;
				break;
			}
		}
	}

	QString move = doMove(from_pos, to_pos, m_current->isWhite());
	m_history->appendMove(move.replace("?", captured ? "x" : "-"), "");
}


void GameController::slot_move_done(const QString& board_str)
{
	if(m_history->paused())
		return;

	perform_jumps(m_game->toString(false), board_str);

	m_current = m_current->opponent();
	m_history->setCurrent(m_current->name());

	if(!m_current->isHuman()) {
		setWorking(true);
	} else {
		setWorking(false);
	}

	if(m_current->opponent()->isHuman() && !m_current->isHuman())
		QTimer::singleShot(MOVE_PAUSE, this, SLOT(slot_move_done_step_two()));
	else
		slot_move_done_step_two();
}


void GameController::slot_move_done_step_two()
{
	m_current->yourTurn(m_game);

	if(check_game_over())
		setWorking(false);
}


bool GameController::check_game_over() // returns m_game_over
{
	if(m_gameOver)
		return true;

	m_gameOver = true;

	bool player_can = m_game->checkMove1() || m_game->checkCapture1();
	bool opp_can = m_game->checkMove2() || m_game->checkCapture2();

	if(m_player == m_current && !player_can && opp_can) {
		you_won(false);
		return m_gameOver;
	}
	if(m_player != m_current && player_can && !opp_can) {
		you_won(true);
		return m_gameOver;
	}
	if(!player_can && !opp_can) {
		add_log(System, tr("Drawn game."));
		m_history->setTag(PdnGame::Result, "1/2-1/2");
		return m_gameOver;
	}

	m_gameOver = false;
	return m_gameOver;
}


void GameController::you_won(bool yes)
{
	if(yes && m_player->isWhite() || !yes && !m_player->isWhite()) {
		m_history->setTag(PdnGame::Result, "1-0");
		add_log(System, tr("White wins!"));
	} else {
		m_history->setTag(PdnGame::Result, "0-1");
		add_log(System, tr("Black wins!"));
	}

	setWorking(false);
}


void GameController::add_log(enum LogType type, const QString& text)
{
	QString str = text;
	str = str.replace('<', "&lt;");
	str = str.replace('>', "&gt;");
	emit logMessage(type, str);
}


void GameController::nextRound()
{
	if(m_aborted)
		return;

	m_player->setWhite(!m_player->isWhite());
	m_player->opponent()->setWhite(!m_player->isWhite());

	m_bottomIsWhite = m_player->isWhite();
	emit bottomIsWhiteChanged();

	resetBoard();
	updateBoard();
	updateLabels();

	unsigned int round = m_history->getTag(PdnGame::Round).toUInt() + 1;
	begin_game(round, m_history->freePlacement());
}


bool GameController::openPdn(const QString& fn)
{
	setWorking(false);

	m_current->stop();

	QString log_text;
	if(!m_history->openPdn(fn, log_text))
		return false;

	if(log_text.length()) {
		add_log(System, tr("Opened:") + " " + fn);
		add_log(Error, log_text.trimmed());
		add_log(Warning, tr("Warning! Some errors occured."));
	}

	return true;
}


bool GameController::savePdn(const QString& fn)
{
	if(!m_history->savePdn(fn)) {
		qDebug() << "GameController::savePdn failed.";
		return false;
	}
	add_log(System, tr("Saved:") + " " + fn);
	return true;
}


void GameController::slot_preview_game(int rules)
{
	if(rules != RUSSIAN && rules != ENGLISH) {
		qDebug() << "GameController::slot_preview_game" << rules << "Wrong game type.";
		return;
	}

	setGame(rules);

	if(m_player->isWhite() && rules == RUSSIAN) {
		m_player->setName(m_history->getTag(PdnGame::White));
		m_player->opponent()->setName(m_history->getTag(PdnGame::Black));
	} else {
		m_player->setName(m_history->getTag(PdnGame::Black));
		m_player->opponent()->setName(m_history->getTag(PdnGame::White));
	}

	m_player->setWhite(rules == RUSSIAN);
	m_player->opponent()->setWhite(!m_player->isWhite());
	m_bottomIsWhite = m_player->isWhite();
	emit bottomIsWhiteChanged();
	updateLabels();
	emit currentChanged();
}


void GameController::slot_apply_moves(const QString& moves)
{
	QStringList move_list = moves.split(MOVE_SPLIT, QString::SkipEmptyParts);

	resetBoard();
	updateBoard();

	bool white_player = get_first_player()->isWhite();
	foreach(QString move, move_list) {
		doMove(move, white_player);
		white_player = !white_player;
	}

	m_current = (m_player->isWhite() ? m_player : m_player->opponent());
	if(!white_player)
		m_current = m_current->opponent();
	m_history->setCurrent(m_current->name());
	emit currentChanged();
}


void GameController::slot_new_mode(bool paused, bool freeplace)
{
	if(paused) {
		return;
	}

	myPlayer* next = 0;
	if(m_history->moveCount() % 2 == 0)
		next = get_first_player();
	else
		next = get_first_player()->opponent();

	m_current = next->opponent();
	slot_move_done(m_game->toString(false));
}


myPlayer* GameController::get_first_player() const
{
	bool white = m_game->type() == RUSSIAN ? true : false;
	if((white && m_player->isWhite()) || (!white && !m_player->isWhite()))
		return m_player;
	return m_player->opponent();
}
