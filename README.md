# Simple photo gallery for the traveller

Generates a static fullscreen photo website from a bunch of photos.

## Source

Put photo files into ``src`` and rename them according to the schema
``[id]_[title]_[description].jpg``. Title and Description are optional.

Run ``rake check`` to find potential troubles.

## Compile

``rake compile``

## Deploy

Copy the resulting ``bin`` directory to your web server
