#!/usr/bin/env python3


##############################################################################################################
# Manual


# - This program is compatible with: Communicator, NomadNet
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

# Sorting
SORT = "ASC" #ASC/DESC

# Preview text length
TEXT_LENGHT_VIEW = 256

# Browser pages cache time in seconds.
CACHE_TIME = 0 #0=No cache, None=Default

# Date/time format for formatting on the screen.
DATE_TIME_FORMAT = "%Y-%m-%d"

# Admin destinations (LXMF-Adresses)
ADMINS = ["dece1ff47066e7e2ef55bf56e8b69aad"] #Array

# Screen template - Main (Use on all pages)
TEMPLATE_MAIN_ADMIN = """
>`cBlog`c
{msg}
`[HINZUFÜGEN`:`action=add]`
{entrys}
`[Startseite`:/page/index.mu]`
"""

TEMPLATE_MAIN_USER = """
>`cBlog`c
{msg}
{entrys}
`[Startseite`:/page/index.mu]`
"""

TEMPLATE_VIEW_ADMIN = """
>`cBlog`c
>>{title}
{text}

`!Erstellt: `!{date_time}

`[BEARBEITEN`:`action=edit|id={id}]`


`[Zurück`:]`


`[Startseite`:/page/index.mu]`
"""

TEMPLATE_VIEW_USER = """
>`cBlog`c
>>{title}
{text}

`!Erstellt: `!{date_time}

`[Zurück`:]`


`[Startseite`:/page/index.mu]`
"""

TEMPLATE_ADD = """
>`cBlog`c
{msg}
`<m|title|Titel`>




















`<m|text|Text`>

`c`[Hinzufügen`:`*|action=add]`


`[Abbrechen`:]`
"""

TEMPLATE_EDIT = """
>`cBlog`c
{msg}
`<m|title|Titel`{title}>




















`<m|text|Text`{text}>

`c`[Speichern`:`*|action=edit|id={id}]`


`[Abbrechen`:]`


`[LÖSCHEN`:`action=delete|id={id}]`
"""

# Screen template - Entry (Use for each entry)
TEMPLATE_ENTRY_ADMIN = """>>{title}
{text}
`[Weiterlesen`:`id={id}]`      `[BEARBEITEN`:`action=edit|id={id}]`
`!Erstellt: `!{date_time}

"""

TEMPLATE_ENTRY_USER = """>>{title}
{text}
`[Weiterlesen`:`id={id}]`
`!Erstellt: `!{date_time}

"""

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
else:
    RIGHT = "user"


if CACHE_TIME != None:
    print("#!c="+str(CACHE_TIME))


if DEBUG:
    print(os.environ)


if RIGHT == "admin" and "var_action" in os.environ and os.environ["var_action"] == "add":
    if "field_title" in os.environ and "field_text" in os.environ:
        if os.environ["field_title"].strip() != "" and os.environ["field_text"].strip() != "":
            try:
                DATA[str(uuid.uuid4())] = {"ts": time.time(), "title": os.environ["field_title"].strip().replace("\n", " "), "text": os.environ["field_text"].strip().replace("\n", " ")}

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
    view_list = False


elif RIGHT == "admin" and "var_action" in os.environ and os.environ["var_action"] == "edit" and "var_id" in os.environ and os.environ["var_id"] in DATA:
    if "field_title" in os.environ and "field_text" in os.environ:
        if os.environ["field_title"].strip() != "" and os.environ["field_text"].strip() != "":
            try:
                DATA[os.environ["var_id"]]["title"] = os.environ["field_title"].strip().replace("\n", " ")
                DATA[os.environ["var_id"]]["text"] = os.environ["field_text"].strip().replace("\n", " ")

                if DATA_COUNT_SAVE > 0 and len(DATA) > DATA_COUNT_SAVE:
                    keys = list(DATA.keys())[:DATA_COUNT_SAVE]
                    for key in keys:
                        del DATA[key]

                fh = open(DATA_FILE, "wb")
                fh.write(msgpack.packb(DATA))
                fh.close()

                MSG = MSG_EDIT_OK
            except:
                MSG = MSG_EDIT_ERROR
        else:
            MSG = MSG_EDIT_ERROR
    tpl = TEMPLATE_EDIT
    tpl = tpl.replace("{self}", FILE)
    tpl = tpl.replace("{date_time}", time.strftime(DATE_TIME_FORMAT, time.localtime(time.time())))
    tpl = tpl.replace("{msg}", MSG)
    tpl = tpl.replace("{id}", os.environ["var_id"])
    tpl = tpl.replace("{date_time}", time.strftime(DATE_TIME_FORMAT, time.localtime(DATA[os.environ["var_id"]]["ts"])))
    tpl = tpl.replace("{title}", DATA[os.environ["var_id"]]["title"])
    tpl = tpl.replace("{text}", DATA[os.environ["var_id"]]["text"])
    print(tpl)
    view_list = False


elif RIGHT == "admin" and "var_action" in os.environ and os.environ["var_action"] == "delete" and "var_id" in os.environ and os.environ["var_id"] in DATA:
    try:
        MSG = MSG_DELETE_OK
        del DATA[os.environ["var_id"]]

        fh = open(DATA_FILE, "wb")
        fh.write(msgpack.packb(DATA))
        fh.close()
    except:
        MSG = MSG_DELETE_ERROR
    view_list = True


elif "var_id" in os.environ and os.environ["var_id"] in DATA:
    if RIGHT == "admin":
        tpl = TEMPLATE_VIEW_ADMIN
    else:
        tpl = TEMPLATE_VIEW_USER
    tpl = tpl.replace("{self}", FILE)
    tpl = tpl.replace("{msg}", MSG)
    tpl = tpl.replace("{id}", os.environ["var_id"])
    tpl = tpl.replace("{date_time}", time.strftime(DATE_TIME_FORMAT, time.localtime(DATA[os.environ["var_id"]]["ts"])))
    tpl = tpl.replace("{title}", DATA[os.environ["var_id"]]["title"])
    tpl = tpl.replace("{text}", DATA[os.environ["var_id"]]["text"])
    print(tpl)
    view_list = False


else:
    view_list = True


if view_list:
    entrys = ""
    if DATA:
        i = 1
        if SORT == "ASC":
            data = reversed(DATA)
        else:
            data = DATA
        for key in data:
            if DATA_COUNT_VIEW > 0 and i > DATA_COUNT_VIEW:
                break
            i += 1
            if RIGHT == "admin":
                tpl = TEMPLATE_ENTRY_ADMIN
            else:
                tpl = TEMPLATE_ENTRY_USER
            tpl = tpl.replace("{id}", key)
            tpl = tpl.replace("{date_time}", time.strftime(DATE_TIME_FORMAT, time.localtime(DATA[key]["ts"])))
            tpl = tpl.replace("{title}", DATA[key]["title"])
            text = DATA[key]["text"]
            if len(text) > TEXT_LENGHT_VIEW:
                text = text[:TEXT_LENGHT_VIEW]+"..."
            tpl = tpl.replace("{text}", text)
            entrys += tpl+"\n"

    if RIGHT == "admin":
        tpl = TEMPLATE_MAIN_ADMIN
    else:
        tpl = TEMPLATE_MAIN_USER
    tpl = tpl.replace("{self}", FILE)
    tpl = tpl.replace("{date_time}", time.strftime(DATE_TIME_FORMAT, time.localtime(time.time())))
    tpl = tpl.replace("{msg}", MSG)
    tpl = tpl.replace("{entrys}", entrys)
    print(tpl)
