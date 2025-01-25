#!/usr/bin/env python3


##############################################################################################################
# Manual


# - This is only for a testing.


##############################################################################################################
# Configuration


TEMPLATE = """>
>`cFields and Submitting Data`c

Nomad Network let's you use simple input fields for submitting data to node-side applications. Submitted data, along with other session variables will be available to the node-side script / program as environment variables. This page contains a few examples.

>> Read Environment Variables

{@ENV}
>>Examples of Fields and Submissions

The following section contains a simple set of fields, and a few different links that submit the field data in different ways.

-=

An input field    :
`B444`<username`Entered data>`b

An masked field   :
`B444`<!|password`Value of Field>`b

An small field    :
`B444`<8|small`test>`b, and some more text.

Two fields        :
`B444`<8|one`One>`b `B444`<8|two`Two>`b


The data can be `!`[submitted`:/page/Eingabe Felder.mu`username|two]`!.


You can `!`[submit`:/page/Eingabe Felder.mu`one|password|small]`! other fields, or just `!`[a single one`:/page/Eingabe Felder.mu`username]`!


Or simply `!`[submit them all`:/page/Eingabe Felder.mu`*]`!.


Submission links can also `!`[include pre-configured variables`:/page/Eingabe Felder.mu`username|two|entitiy_id=4611|action=view]`!.


Or take all fields and `!`[pre-configured variables`:/page/Eingabe Felder.mu`*|entitiy_id=4611|action=view]`!.


Or only `!`[pre-configured variables`:/page/Eingabe Felder.mu`entitiy_id=4688|task=something]`!

-=

"""


##############################################################################################################
# Include


#### System ####
import os


##############################################################################################################
# Program


env_string = ""
for e in os.environ:
    env_string += "{}={}\n".format(e, os.environ[e])

print(TEMPLATE.replace("{@ENV}", env_string))
