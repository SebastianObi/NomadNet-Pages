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

# Screen template - Main (Use on all pages)
TEMPLATE_MAIN_ADMIN = """
>`cGästebuch`c
{msg}


{input}

Letztes Update: {date_time}

>Einträge`c
{entrys}

`[Startseite`:/page/index.mu]`
"""

TEMPLATE_MAIN_OWNER = TEMPLATE_MAIN_ADMIN

TEMPLATE_MAIN_USER = TEMPLATE_MAIN_ADMIN

# Screen template - Input (Input fields)
TEMPLATE_INPUT_ADD = """
`c`<m|text|Neuer Eintrag`>

`[Hinzufügen/Absenden`:`*|action=add]`        `[Aktualisieren`:]`
"""

TEMPLATE_INPUT_EDIT = """
`c`<m|text|Eintrag bearbeiten`{text}>

`[Speichern`:`*|id={id}|edit=True]`        `[Aktualisieren`:]`
"""

# Screen template - Entry (Use for each entry)
TEMPLATE_ENTRY_ADMIN = """`;0s;;[b]{name}[/b] {date_time}\\n{text};;;`[lxmf@{dest}]`\\n\\n`[BEARBEITEN`:`*|id={id}]`\\n\\n`[LÖSCHEN`:`*|id={id}|delete=true]`;`"""

TEMPLATE_ENTRY_OWNER = """`;0s;;[b]{name}[/b] {date_time}\\n{text};;;`[BEARBEITEN`:`*|id={id}]`\\n\\n`[LÖSCHEN`:`*|id={id}|delete=true]`;`"""

TEMPLATE_ENTRY_USER = """`;0l;;[b]{name}[/b] {date_time}\\n{text};;;lxmf@{dest};`"""

# Text of the status confirmations.
MSG_ADD_OK = "\n>>>`cStatus: `F080Erfolgreich hinzugefügt!`f`c\n"
MSG_ADD_ERROR = "\n>>>`cStatus: `Ff00Fehler beim hinzufügen!`f`c\n"

MSG_EDIT_OK = "\n>>>`cStatus: `F080Erfolgreich geändert!`f`c\n"
MSG_EDIT_ERROR = "\n>>>`cStatus: `Ff00Fehler beim ändern!`f`c\n"

MSG_DELETE_OK = "\n>>>`cStatus: `F080Erfolgreich gelöscht!`f`c\n"
MSG_DELETE_ERROR = "\n>>>`cStatus: `Ff00Fehler beim löschen!`f`c\n"


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
TEMPLATE_INPUT = TEMPLATE_INPUT_ADD
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


if "var_action" in os.environ and os.environ["var_action"] == "add":
    if "field_text" in os.environ and os.environ["field_text"].strip() != "":
        try:
            DATA[str(uuid.uuid4())] = {"ts": time.time(), "dest": DEST, "name": NAME, "text": os.environ["field_text"].strip().replace("\n", " ")}

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


elif (RIGHT == "admin" or RIGHT == "owner") and "var_id" in os.environ and os.environ["var_id"] in DATA:
    try:
        if "var_delete" in os.environ:
            MSG = MSG_DELETE_OK
            del DATA[os.environ["var_id"]]
        elif "var_edit" in os.environ:
            MSG = MSG_EDIT_OK
            if "field_text" in os.environ:
                DATA[os.environ["var_id"]]["text"] = os.environ["field_text"].strip().replace("\n", " ")

        if not "var_delete" in os.environ:
            TEMPLATE_INPUT = TEMPLATE_INPUT_EDIT
            TEMPLATE_INPUT = TEMPLATE_INPUT.replace("{text}", DATA[os.environ["var_id"]]["text"])
            TEMPLATE_INPUT = TEMPLATE_INPUT.replace("{id}", os.environ["var_id"])

        if "var_delete" in os.environ or "var_edit" in os.environ:
            fh = open(DATA_FILE, "wb")
            fh.write(msgpack.packb(DATA))
            fh.close()
    except:
        if "var_delete" in os.environ:
            MSG = MSG_DELETE_ERROR
        elif "var_edit" in os.environ:
            MSG = MSG_EDIT_ERROR


entrys = ""
if DATA:
    i = 1
    for key in reversed(DATA):
        if DATA_COUNT_VIEW > 0 and i > DATA_COUNT_VIEW:
            break
        i += 1
        if RIGHT == "admin":
            tpl = TEMPLATE_ENTRY_ADMIN
        elif DEST and DATA[key]["dest"] == DEST:
            tpl = TEMPLATE_ENTRY_OWNER
        else:
            tpl = TEMPLATE_ENTRY_USER
        tpl = tpl.replace("{id}", key)
        tpl = tpl.replace("{date_time}", time.strftime(DATE_TIME_FORMAT, time.localtime(DATA[key]["ts"])))
        tpl = tpl.replace("{name}", DATA[key]["name"])
        tpl = tpl.replace("{dest}", DATA[key]["dest"])
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
tpl = tpl.replace("{input}",TEMPLATE_INPUT)
tpl = tpl.replace("{entrys}", entrys)
print(tpl)
