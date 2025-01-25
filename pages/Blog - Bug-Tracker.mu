#!/usr/bin/env python3


##############################################################################################################
# Manual


# - This program is compatible with: Communicator
# - Copy file to any subfolder or root folder of nomadnet pages.
# - Make the file executable with the command chmod +x <filename>
# - Rename the file as you want.
# - Modify the configuration section in this file according to your own needs. This can, but does not have to be changed.
# - Create a link to this file on the start page or another nomadnet page.
# - Open the page in nomandet client.
# - The first time the page is opened, the data file will be created in the .filename folder in the user's home directory.


##############################################################################################################
# Configuration


# Debug mode (display of debug information).
DEBUG = False #True/False

# Alternative path
PATH = None

# Number of datasets which will be saved (older datasets will be deleted).
DATA_COUNT_SAVE = 0 #0=No limit

# Number of datasets which will be viewed.
DATA_COUNT_VIEW = 50 #0=No limit

# Browser pages cache time in seconds.
CACHE_TIME = 0 #0=No cache, None=Default

# Date/time format for formatting on the screen.
DATE_TIME_FORMAT = "%Y-%m-%d %H:%M:%S"

# Admin destinations (LXMF-Adresses)
ADMINS = ["dece1ff47066e7e2ef55bf56e8b69aad"] #Array

# Screen template - Main
TEMPLATE_MAIN_ADMIN = """
>`cBug-Tracker`c
{msg}
`cHier finden Sie alle noch bekannten Fehler/Probleme mit der App. Sollten Sie einen Fehler feststellen, dann prüfen Sie bitte ob nicht schon ein Eintrag existiert.

Hierfür können Sie die Suche des Browsers verwenden. (Obere Toolbar)

Ansonsten klicken Sie auf `[Fehler melden`:`page=add]`" um einen neuen Fehler bekannt zu geben.

`[Aktualisieren`:]`

Letztes Update: {date_time}

>>Filter
`[Alle`:`filter=all]`        `[Offen`:`filter=open]`        `[Geschlossen`:`filter=closed]`        `[Eigene`:`filter=own]`
{entrys}

`[Startseite`:/page/index.mu]`
"""

TEMPLATE_MAIN_OWNER = TEMPLATE_MAIN_ADMIN

TEMPLATE_MAIN_USER = TEMPLATE_MAIN_ADMIN

# Screen template - Main - Entry
TEMPLATE_MAIN_ENTRY_ADMIN = """`;3s;;{title};{text};[b]Status:[/b] {state_name}  [b]#:[/b] {votes};>Eintrag\\n\\n`<|title|Titel`{title}>\\n\\n\\n\\n`<m|text|Beschreibung`{text}>\\n\\n\\n\\n\\n`<m|state_text|Status Info`{state_text}>\\n>>Status: `F{state_color}{state_name}`f\\n\\n`[Offen`:`*|id={id}|state=0]`    `[In Bearbeitung`:`*|id={id}|state=1]`    `[Erledigt`:`*|id={id}|state=5]`    `[Abgebrochen`:`*|id={id}|state=6]`\\n\\n`[Warten Entwickler`:`*|id={id}|state=2]`    `[Warten Anwender`:`*|id={id}|state=3]`    `[Pausiert`:`*|id={id}|state=4]`\\n\\n>># Stimmen: {votes}\\n{votes_link}\\n\\n>>Ersteller:\\n{name} `[lxmf@{dest}]\\n\\n>>Kommentare:\\n\\n`[EINTRAG LÖSCHEN`:`*|id={id}|delete=true]`;`"""

TEMPLATE_MAIN_ENTRY_OWNER = """`;3s;;{title};{text};[b]Status:[/b] {state_name}  [b]#:[/b] {votes};>Eintrag\\n\\n`<|title|Titel`{title}>\\n\\n\\n\\n`<m|text|Beschreibung`{text}>\\n\\n`[Speichern`:`*|id={id}]`\\n\\n>>Status: `F{state_color}{state_name}`f\\n\\n>>Status Info:\\n{state_text}\\n\\n>># Stimmen: {votes}\\n{votes_link}\\n\\n>>Ersteller:\\n{name} `[lxmf@{dest}]\\n\\n>>Kommentare:;`"""

TEMPLATE_MAIN_ENTRY_USER = """`;3s;;{title};{text};[b]Status:[/b] {state_name}  [b]#:[/b] {votes};>{title}\\n{text}\\n\\n>>Status: `F{state_color}{state_name}`f\\n\\n>>Status Info:\\n{state_text}\\n\\n>># Stimmen: {votes}\\n{votes_link}\\n\\n>>Ersteller:\\n{name} `[lxmf@{dest}]\\n\\n>>Kommentare:;`"""

# Screen template - Add
TEMPLATE_ADD = """
>`cBug-Tracker`c
{msg}
>>>`cNeuer Fehler melden:


`<|title|Titel`>




`<m|text|Beschreibung`>

`[Hinzufügen/Absenden`:`*|page=add|action=add]`        `[Zurück`:]`
"""

# Screen template - Vote
TEMPLATE_MAIN_VOTE_ADD = "`[Stimme hinzufügen`:`*|id={id}|vote=add]`"
TEMPLATE_MAIN_VOTE_DELETE = "`[Stimme entfernen`:`*|id={id}|vote=delete]`"

# States
STATES = {0: ["f00", "Offen"], 1: ["fa0", "In Bearbeitung"], 2: ["80f", "Warten (Rückmeldung vom Anwender)"], 3: ["80f", "Warten (Rückmeldung vom Entwickler)"], 4: ["fa0", "Pausiert"], 5: ["080", "Geschlossen (Erledigt)"], 6: ["080", "Geschlossen (Abgebrochen)"]}

# Text of the status confirmations.
MSG_ADD_OK = "\n>>>`cStatus: `F080Erfolgreich hinzugefügt!`f\n\nVielen Dank für Ihre Untersützung!`c\n"
MSG_ADD_ERROR = "\n>>>`cStatus: `Ff00Fehler beim hinzufügen!`f`c\n"

MSG_EDIT_OK = "\n>>>`cStatus: `F080Erfolgreich geändert!`f`c\n"
MSG_EDIT_ERROR = "\n>>>`cStatus: `Ff00Fehler beim ändern!`f`c\n"

MSG_DELETE_OK = "\n>>>`cStatus: `F080Erfolgreich gelöscht!`f`c\n"
MSG_DELETE_ERROR = "\n>>>`cStatus: `Ff00Fehler beim löschen!`f`c\n"

MSG_VOTE_ADD_OK = "\n>>>`cStatus: `F080Stimme erfolgreich hinzugefügt!`f`c\n"
MSG_VOTE_ADD_ERROR = "\n>>>`cStatus: `Ff00Fehler beim hinzufügen der Stimme!`f`c\n"

MSG_VOTE_DELETE_OK = "\n>>>`cStatus: `F080Stimme erfolgreich entfernt!`f`c\n"
MSG_VOTE_DELETE_ERROR = "\n>>>`cStatus: `Ff00Fehler beim entfernen der Stimme!`f`c\n"


##############################################################################################################
# Include


#### System ####
import os
import time

#### UID ####
import uuid

#### Reticulum ####
import RNS
import RNS.vendor.umsgpack as msgpack


##############################################################################################################
# Globals  - System (Not changeable)


FILE = os.path.splitext(os.path.basename(__file__))[0]

if PATH == None:
    PATH = os.path.expanduser("~")+"/.config/"+FILE

DATA_FILE = PATH+"/data.data"

DATA = {}
MSG = ""


##############################################################################################################
# Program


if "remote_identity" in os.environ:
    DEST = RNS.hexrep(RNS.Destination.hash_from_name_and_identity("lxmf.delivery", bytes.fromhex(os.environ["remote_identity"])), delimit=False)
else:
    DEST = ""


if "var_dn" in os.environ:
    NAME = os.environ["var_dn"]
else:
    NAME = ""


if not os.path.isdir(PATH):
    try:
        os.makedirs(PATH)
    except Exception:
        print(PATH)
        exit

if os.path.isfile(DATA_FILE):
    try:
        fh = open(DATA_FILE , "rb")
        DATA = msgpack.unpackb(fh.read())
        fh.close()
    except Exception as e:
        exit


if "var_page" in os.environ:
    PAGE = os.environ["var_page"]
else:
    PAGE = "main"


if DEST != "" and DEST in ADMINS:
    RIGHT = "admin"
elif "var_id" in os.environ and os.environ["var_id"] in DATA and DEST != "" and DATA[os.environ["var_id"]]["dest"] == DEST:
    RIGHT = "owner"
else:
    RIGHT = "user"


if CACHE_TIME != None:
    print("#!c="+str(CACHE_TIME))


if DEBUG:
    print(os.environ)


if PAGE == "main":
    if DEST and "var_id" in os.environ and os.environ["var_id"] in DATA and "var_vote" in os.environ and os.environ["var_vote"] == "add":
        try:
            if DEST not in DATA[os.environ["var_id"]]["votes"]:
                DATA[os.environ["var_id"]]["votes"].append(DEST)
                fh = open(DATA_FILE, "wb")
                fh.write(msgpack.packb(DATA))
                fh.close()
                MSG = MSG_VOTE_ADD_OK
            else:
                raise ValueError("")
        except:
            MSG = MSG_VOTE_ADD_ERROR


    elif DEST and "var_id" in os.environ and os.environ["var_id"] in DATA and "var_vote" in os.environ and os.environ["var_vote"] == "delete":
        try:
            if DEST in DATA[os.environ["var_id"]]["votes"]:
                DATA[os.environ["var_id"]]["votes"].remove(DEST)
                fh = open(DATA_FILE, "wb")
                fh.write(msgpack.packb(DATA))
                fh.close()
                MSG = MSG_VOTE_DELETE_OK
            else:
                raise ValueError("")
        except:
            MSG = MSG_VOTE_DELETE_ERROR


    elif RIGHT == "admin" and "var_id" in os.environ and os.environ["var_id"] in DATA:
        try:
            if "var_delete" in os.environ:
                MSG = MSG_DELETE_OK
                del DATA[os.environ["var_id"]]
            else:
                MSG = MSG_EDIT_OK
                if "field_title" in os.environ:
                    DATA[os.environ["var_id"]]["title"] = os.environ["field_title"].strip().replace("\n", " ")
                if "field_text" in os.environ:
                    DATA[os.environ["var_id"]]["text"] = os.environ["field_text"].strip().replace("\n", " ")
                if "var_state" in os.environ:
                    DATA[os.environ["var_id"]]["state"] = int(os.environ["var_state"])
                if "field_state_text" in os.environ:
                    DATA[os.environ["var_id"]]["state_text"] = os.environ["field_state_text"].strip().replace("\n", " ")
            fh = open(DATA_FILE, "wb")
            fh.write(msgpack.packb(DATA))
            fh.close()
        except:
            if "var_delete" in os.environ:
                MSG = MSG_DELETE_ERROR
            else:
                MSG = MSG_EDIT_ERROR


    elif RIGHT == "owner" and "var_id" in os.environ and os.environ["var_id"] in DATA:
        try:
            if "field_title" in os.environ:
                DATA[os.environ["var_id"]]["title"] = os.environ["field_title"].strip().replace("\n", " ")
            if "field_text" in os.environ:
                DATA[os.environ["var_id"]]["text"] = os.environ["field_text"].strip().replace("\n", " ")
            fh = open(DATA_FILE, "wb")
            fh.write(msgpack.packb(DATA))
            fh.close()
            MSG = MSG_EDIT_OK
        except:
            MSG = MSG_EDIT_ERROR


    entrys = ""
    if DATA:
        if "var_filter" in os.environ:
            filter = os.environ["var_filter"]
        else:
            filter = None
        i = 1
        for key in reversed(DATA):
            if (filter == "open" and DATA[key]["state"] > 4) or (filter == "closed" and DATA[key]["state"] < 5) or (filter == "own" and DATA[key]["dest"] != DEST):
                continue
            if DATA_COUNT_VIEW > 0 and i > DATA_COUNT_VIEW:
                break
            i += 1
            if RIGHT == "admin":
                tpl = TEMPLATE_MAIN_ENTRY_ADMIN
            elif DEST and DATA[key]["dest"] == DEST:
                tpl = TEMPLATE_MAIN_ENTRY_OWNER
            else:
                tpl = TEMPLATE_MAIN_ENTRY_USER
            if not DEST:
                tpl = tpl.replace("{votes_link}", "")
            elif DEST in DATA[key]["votes"]:
                tpl = tpl.replace("{votes_link}", TEMPLATE_MAIN_VOTE_DELETE)
            else:
                tpl = tpl.replace("{votes_link}", TEMPLATE_MAIN_VOTE_ADD)
            tpl = tpl.replace("{id}", key)
            tpl = tpl.replace("{date_time}", time.strftime(DATE_TIME_FORMAT, time.localtime(DATA[key]["ts"])))
            tpl = tpl.replace("{name}", DATA[key]["name"])
            tpl = tpl.replace("{dest}", DATA[key]["dest"])
            if DATA[key]["state"] in STATES:
                tpl = tpl.replace("{state_color}", STATES[DATA[key]["state"]][0])
                tpl = tpl.replace("{state_name}", STATES[DATA[key]["state"]][1])
            else:
                tpl = tpl.replace("{state_color}", "")
                tpl = tpl.replace("{state_name}", "")
            tpl = tpl.replace("{state_text}", DATA[key]["state_text"])
            tpl = tpl.replace("{votes}", str(len(DATA[key]["votes"])))
            tpl = tpl.replace("{title}", DATA[key]["title"])
            tpl = tpl.replace("{text}", DATA[key]["text"])
            entrys += tpl+"\n"


    if RIGHT == "admin":
        tpl = TEMPLATE_MAIN_ADMIN
    elif RIGHT == "owner":
        tpl = TEMPLATE_MAIN_OWNER
    else:
        tpl = TEMPLATE_MAIN_USER
    tpl = tpl.replace("{self}", FILE)
    tpl = tpl.replace("{date_time}", time.strftime(DATE_TIME_FORMAT, time.localtime(time.time())))
    tpl = tpl.replace("{msg}", MSG)
    tpl = tpl.replace("{entrys}", entrys)
    print(tpl)


elif PAGE == "add":
    if "var_action" in os.environ and os.environ["var_action"] == "add":
        if "field_title" in os.environ and os.environ["field_title"].strip() != "" and "field_text" in os.environ and os.environ["field_text"].strip() != "":
            try:
                DATA[str(uuid.uuid4())] = {"ts": time.time(), "dest": DEST, "name": NAME, "state": 0, "state_text": "", "title": os.environ["field_title"].strip().replace("\n", " "), "text": os.environ["field_text"].strip().replace("\n", " "), "comments": {}, "votes": []}

                if DATA_COUNT_SAVE > 0 and len(DATA) > DATA_COUNT_SAVE:
                    keys = list(DATA.keys())[:DATA_COUNT_SAVE]
                    for key in keys:
                        del DATA[key]

                fh = open(DATA_FILE, "wb")
                fh.write(msgpack.packb(DATA))
                fh.close()

                MSG = MSG_ADD_OK
            except:
                MSG = MSG_ADD_ERROR
        else:
            MSG = MSG_ADD_ERROR

    tpl = TEMPLATE_ADD
    tpl = tpl.replace("{self}", FILE)
    tpl = tpl.replace("{date_time}", time.strftime(DATE_TIME_FORMAT, time.localtime(time.time())))
    tpl = tpl.replace("{msg}", MSG)
    print(tpl)
