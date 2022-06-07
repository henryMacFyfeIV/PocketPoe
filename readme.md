# Readme

## Description
PocketPoe is a program for the [playdate console](https://play.date) that lets you read an assortment of short stories by author Edger Allen Poe.

## Running the program in playdate emulator with vscode
~~Download and setup your playdate sdk as described [here](https://sdk.play.date/1.11.1/Inside%20Playdate.html#_compiling_a_project).
I'm using vscode to build and debug PocketPoe with vscode extensions [Playdate by Orta](https://github.com/orta/vscode-playdate) and [Playdate Debug by midouest](https://github.com/midouest/vscode-playdate-debug).
After installing the sdk, vscode, and the two extensions, you should be able to run .vscode/launch.json with the vscode debugger. 
Alternatively, you can use the playdate compiler via the cli as described in the Inside Playdate doc linked above.~~ 
Scratch the above for now, vscode debug config got messed up, just run this to compile and run.
> rm -rf pocket Pocket\ Poe.pdx/ ; pdc source "Pocket Poe"; open Pocket\ Poe.pdx/

## Playing PocketPoe on your playdate
This repo contains a PocketPoe.pdx that can be added to your playdate [here](https://play.date/account/sideload/). 
I don't have a playdate yet, so PocketPoe may behave differently on actual hardware. If it does, please let me know.

## Contributing
On the off chance you want to contribute in anyway (feedback, feature requests, bugs etc) feel free to submit merge requests, comments or msg me on github. Thanks for reading.
 
