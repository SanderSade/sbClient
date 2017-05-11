alias sbClient.version { return 2.23 }
dialog sbClient_options {
title sbClient v $+ $sbClient.version
size -1 -1 198 202
option dbu notheme
tab "General", 1, 1 3 196 173
tab "SearchBot", 6
button "Close", 11, 20 183 70 12, ok
button "Search dialog", 16, 108 183 70 12
box "Channels", 21, 2 19 192 140, tab 6
check "Store search result .txt files", 26, 5 162 79 8, tab 6
list 31, 6 37 134 45, tab 6 vsbar size
button "Add", 36, 143 37 45 45, tab 6
text "Current channels:", 41, 6 27 50 8, tab 6
text "SearchBot channels:", 46, 6 84 64 8, tab 6
list 51, 6 93 134 45, tab 6 vsbar size
button "Remove", 56, 143 93 45 45, tab 6
button "Request search triggers", 61, 6 143 182 13, tab 6 flat
check "No max results limit for local searches (not recommended)", 66, 10 24 180 8, tab 1
check "Check for a new sbClient version on mIRC start", 71, 10 35 125 8, tab 1
button "Check now", 76, 137 35 54 8, tab 1 flat multi
box "sbClient", 81, 8 59 182 93, tab 1
text "Here will be some kind of intro text as soon as I figure out what it will be", 86, 15 80 120 40, tab 1 multi
link "www.dukelupus.com", 91, 68 157 62 8, tab 1
check "Group @find results", 96, 10 46 81 8, tab 1
}
on *:dialog:sbClient_options:init:0: {
if (%sbClient.storetxt == 1) did -c sbClient_options 26
if (%sbClient.groupfind == 1) did -c sbClient_options 96
var %cnter = 1
while (%cnter <= $scon(0)) {
scon %cnter
var %cnter2 = 1
while (%cnter2 <= $chan(0)) {
did -a sbClient_options 31 $+($chan(%cnter2),@,$network)
inc %cnter2
}
inc %cnter
}
didtok sbClient_options 51 44 %sbClient.channels
if (%sbClient.nomax == 1) did -c sbClient_options 66
if (%sbClient.checkver == 1) did -c sbClient_options 71
}
on *:dialog:sbClient_options:sclick:36: {
if (!$did(31).seltext) halt
if ($did(31).seltext isin %sbClient.channels) halt
%sbClient.channels = $addtok(%sbClient.channels,$did(31).seltext,44)
did -r sbClient_options 51
didtok sbClient_options 51 44 %sbClient.channels
sbClient.GetTrigger $did(31).seltext
}
on *:dialog:sbClient_options:sclick:56: {
if (!$did(51).seltext) halt
%sbClient.channels = $remtok(%sbClient.channels,$did(51).seltext,44)
did -r sbClient_options 51
didtok sbClient_options 51 44 %sbClient.channels
}
on *:dialog:sbClient_options:sclick:91: { url -an http://www.dukelupus.com }
on *:dialog:sbClient_options:sclick:76: { sbClient.update }
on *:dialog:sbClient_options:sclick:96: {
%sbClient.groupfind = $did(96).state
}
on *:dialog:sbClient_options:close:*: {
%sbClient.storetxt = $did(26).state
%sbClient.nomax = $did(66).state
%sbClient.checkver = $did(71).state
%sbClient.groupfind = $did(96).state
}
on *:dialog:sbClient_options:sclick:61: {
var %cnter = 1
while (%cnter <= $numtok(%sbClient.channels,44)) {
sbClient.GetTrigger $gettok(%sbClient.channels,%cnter,44)
inc %cnter
}
}
on *:dialog:sbClient_options:sclick:16: {
%sbClient.storetxt = $did(26).state
%sbClient.nomax = $did(66).state
%sbClient.checkver = $did(71).state
dialog -x sbClient_options sbClient_options
dialog -am sbClient_search sbClient_search
}
alias sbClient.GetTrigger {
scon $sbClient.GetNetworkID($1)
echo -s 1,9<<sbClient>> Requesting SearchBot trigger from $sbClient.GetChannel($1) (network $gettok($1,2,64) $+ ).
msg $sbClient.GetChannel($1) @SearchBot-trigger
%sbClient. [ $+ [ $1 ] $+ ] .requested = 1
}
alias sbClient.GetChannel { return $gettok($1,1,64) }
alias sbClient.GetNetworkID {
var %net = $gettok($1,2,64)
var %cnter = 1
while (%cnter <= $scon(0)) {
if ($scon(%cnter).$network == %net) { return %cnter }
inc %cnter
}
}
ctcp *:TRIGGER: {
if (%sbClient. [ $+ [ $3 ] $+ [ @ ] $+ [ $2 ] $+ ] .requested == 1) {
set %sbClient. [ $+ [ $3 ] $+ [ @ ] $+ [ $2 ] $+ ] .trigger $4
unset %sbClient. [ $+ [ $3 ] $+ [ @ ] $+ [ $2 ] $+ ] .requested
echo -s 1,9<<sbClient>> Received SearchBot trigger from $3 (network $2 $+ ): $4
}
}
ctcp *:VERSION: {
if ($network != DejaToons) .ctcpreply $nick VERSION 1,9<<sbClient>> version $sbClient.version by DukeLupus.1,15 Get it from 12,15http://www.dukelupus.com
}
dialog sbClient_search {
title "sbClient search dialog"
size -1 -1 219 103
option dbu notheme
edit "", 5, 6 6 207 10
button "Search!", 1, 5 19 207 10, flat default
check "Local search in folder:", 10, 12 35 77 8
text "Not selected", 6, 50 47 163 8
button "Select folder", 15, 12 47 36 9, flat
check "Online SearchBot search in channel:", 11, 12 61 97 8
combo 20, 112 61 101 35, drop
check "Use separate windows for each search", 16, 12 73 105 8
check "@find search in channel:", 25, 12 86 97 8
combo 21, 112 86 101 35, drop
}
on *:dialog:sbClient_search:init:0: {
if (%sbClient.ListFolder) did -o sbClient_search 6 1 %sbClient.ListFolder
didtok sbClient_search 20 44 %sbClient.channels
did -c sbClient_search 20 %sbClient.last1
if (%sbClient.Separate) did -c sbClient_search 16
did -f sbClient_search 5
if (%sbClient.menu.local) did -c sbClient_search 10
if (%sbClient.menu.channel) did -c sbClient_search 11
if (%sbClient.find.channel) did -c sbClient_search 25
var %cnter = 1
var %channels
while (%cnter <= $scon(0)) {
scon %cnter
var %cnter2 = 1
while (%cnter2 <= $chan(0)) {
%channels = %channels $+ , $+ $+($chan(%cnter2),@,$network)
inc %cnter2
}
inc %cnter
}
didtok sbClient_search 21 44 %channels
did -c sbClient_search 21 %sbClient.last2
}
on *:dialog:sbClient_search:close:0: {
%sbClient.last1 = $did(20).sel
%sbClient.last2 = $did(21).sel
}
on *:dialog:sbClient_search:sclick:15: {
%sbClient.ListFolder = $sdir($mircdir $+ Lists, Select list folder)
if (!%sbClient.ListFolder) did -o sbClient_search 6 1 Not selected
else did -o sbClient_search 6 1 %sbClient.ListFolder
}
on *:dialog:sbClient_search:sclick:16: { %sbClient.Separate = $did(16).state }
on *:dialog:sbClient_search:sclick:10: { %sbClient.menu.local = $did(10).state }
on *:dialog:sbClient_search:sclick:11: { %sbClient.menu.channel = $did(11).state }
on *:dialog:sbClient_search:sclick:25: { %sbClient.find.channel = $did(25).state }
on *:dialog:sbClient_search:sclick:1: {
if ((!$did(10).state) && (!$did(25).state) && (!$did(11).state)) {
sbClient.error You really should choose at least one search method.
halt
}
if (!$did(5).text) {
sbClient.error No search string!
halt
}
var %sstring = $sbClient.FixString($did(5).text)
if (!%sstring) {
sbClient.error I don't like your search string!
halt
}
if ($did(10).state) {
if (%sbClient.searching == 1) {
if ($input(Local search seems to be already active. Do you want to stop active local search and start your current search?,yqd,Local search is active) == $true) {
dll $+(",$scriptdir,sbClient.dll,") Stop 1
%sbClient.searching = 0
}
else { if ($did(11).state) goto chansearch }
else halt
}
if (!%sbClient.ListFolder) {
sbClient.error No list folder!
else { if ($did(11).state) goto chansearch }
else halt
}
if ($findfile(%sbClient.ListFolder,*.txt,0,1) == 0) {
sbClient.error There are no lists in the selected folder!
else { if ($did(11).state) goto chansearch }
else halt
}
sbClient.DoLocalSearch %sstring
}
:chansearch
if ($did(25).state) {
.set -u600 %sbclient.searchactive 1
.set -u600 %DLF.searchactive 1
scon $sbClient.GetNetworkID($did(21).seltext)
msg $sbClient.GetChannel($did(21).seltext) @find %sstring
}
if ($did(11).state) {
if (!$did(20).seltext) { sbClient.error No channel selected! | halt }
var %schan = $did(20).seltext
if ($sbClient.Check(%schan,%sstring) == 0) halt
%sbClient.SearchChannel = %schan
sbClient.DoSearch %schan %sstring
}
did -r sbClient_search 5
dialog -t sbClient_search Now searching for " $+ %sstring $+ ".
}
alias sbClient.error { var %i = $input($1-,ohd,sbClient error) }
alias sbClient.FixString { return $replace($1-,$chr(34),$null,$chr(39), $chr(32),$chr(42),$chr(32),$chr(63),$chr(32),$chr(32) $+ $chr(32),$chr(32)) }
alias sbClient.DoLocalSearch {
%sbClient.string = $1-
var %folder = %sbClient.ListFolder $+ *.txt
if (%sbClient.nomax == 1) var %maxresults = 10000000
else var %maxresults = 3000
%sbClient.searching = 1
.remove $+(",$mircdir,sbClient.ls.results.txt,")
dll $+(",$scriptdir,sbClient.dll,") SetOutputName $+($mircdir,sbClient.ls.results.txt)
dll $+(",$scriptdir,sbClient.dll,") SetListFolder %folder
dll $+(",$scriptdir,sbClient.dll,") SetSearchString %sbClient.string
dll $+(",$scriptdir,sbClient.dll,") SetMaxReplies %maxresults
dll $+(",$scriptdir,sbClient.dll,") SetReturnAlias sbClient.SearchDone
dll $+(",$scriptdir,sbClient.dll,") Search 1
}
alias sbClient.SearchDone {
%sbClient.searching = 0
if ($1 == 0) {
if ($input(No results were found. Would you like to start a new search?,yi,No search results) == $true) {
dialog -am sbClient_search sbClient_search
halt
}
else halt
}
if (%sbClient.Separate) var %window = $replace(@sbClient.local. $+ $gettok(%sbClient.string,1,$chr(32)),$chr(32),.)
else var %window = @sbClient.local
if (!$window(%window)) window -ek0lmwz %window Arial 12
else clear %window
titlebar %window -|- sbClient local search results for " $+ %sbClient.string $+ " -|- $findfile(%sbClient.ListFolder,*.txt,0,1) lists searched -|- $1 results -|- rclick for options -|-
%sbClient.window = %window
sbClient.LS.Loadresults $2-
}
alias sbClient.LS.Loadresults {
var %file = " $+ $1- $+ "
loadbuf -r %sbClient.window $+(",$mircdir,sbClient.ls.results.txt,")
sbClient.ColorNicks %sbClient.window
.remove $+(",$mircdir,sbClient.ls.results.txt,")
}
alias sbClient.ColorNicks {
var %cnter = 1
while (%cnter <= $line($1,0)) {
var %line = $line($1,%cnter)
if (%line != $null) {
if ($sbClient.Online(%line) == 1) cline 3 $1 %cnter
else cline 4 $1 %cnter
}
inc %cnter
}
}
alias sbClient.Online {
tokenize 32 $1
var %nick = $1
%nick = $replace($1,-new,$null)
if ($left(%nick,1) = $chr(33)) %nick = $mid(%nick,2-)
var %cnter = 1
while (%cnter <= $scon(0)) {
scon %cnter
if ($comchan(%nick,1)) return 1
inc %cnter
}
return 0
}
on *:input:@sbClient.local*,@sbClient.OldResults: {
if ($left($1-,1) == /) halt
if (%sbClient.searching == 1) {
if ($input(Local search seems to be already active. Do you want to stop active search and start your current search?,yqd,Local search is active) == $true) { sbClient.Cleanup }
else halt
}
var %sstring = $sbClient.FixString($1-)
if (!%sstring) {
sbClient.error I don't like your search string!
halt
}
sbClient.DoLocalSearch %sstring
}
menu @sbClient.OldResults,@sbClient.@find.results,@sbClient.combined {
Check online status: {
%cnter = 1
while (%cnter <= $line($active,0)) {
var %line = $line($active,%cnter)
if ($left(%line,1) == $chr(33)) {
if ($sbClient.Online(%line) == 1) cline 3 $active %cnter
else cline 4 $active %cnter
}
inc %cnter
}
}
}
menu @sbClient.* {
Remove off-line nicks: {
%cnter = 1
while (%cnter <= $line($active,0)) {
var %line = $line($active,%cnter)
if ($left(%line,1) == $chr(33)) {
if ($sbClient.Online(%line) == 0) {
dline $active %cnter
continue
}
else cline 3 $active %cnter
}
inc %cnter
}
}
-
Copy line(s) to clipboard: {
if (!$sline($active,0)) halt
var %cnter = 1
clipboard
while (%cnter <= $sline($active,0)) {
if ($sbClient.Online($sline($active,%cnter)) == 1) cline 10 $active $sline($active,%cnter).ln
else cline 6 $active $sline($active,%cnter).ln
if ($sline($active,0) == 1) {
clipboard $sbClient.GetFileName($sline($active,1))
titlebar $active -|- $sline($active,0) line(s) copied to clipboard -|-
halt
}
clipboard -an $sbClient.GetFileName($sline($active,%cnter))
inc %cnter
}
titlebar $active -|- $sline($active,0) line(s) copied to clipboard -|-
}
$iif(!$script(AutoGet.mrc), $style(2)) Send to AutoGet 7: {
var %path = $nofile($script(AutoGet.mrc))
.fopen MTlisttowaiting $+(",%path,AGwaiting.ini,")
.fseek -l MTlisttowaiting $lines($+(",%path,AGwaiting.ini,"))
var %i = 1
var %j = 0
while (%i <= $sline($active,0)) {
var %temp = $MTlisttowaiting($sline($active,%i))
var %j = $calc(%j + $gettok(%temp,1,32))
if ($sbClient.Online($sline($active,%i)) == 1) { cline 10 $active $sline($active,%i).ln }
else { cline 6 $active $sline($active,%i).ln }
inc %i
}
.fclose MTlisttowaiting
if (%MTautorequest == 1) { MTkickstart $gettok(%temp,2,32) }
MTwhosinque
if ($dialog(Autoget)) updatewaitinglist
if (%MTecho) echo -s %MTlogo Added %j File(s) To Waiting List From sbClient
}
$iif(!$script(vPowerGet.net.mrc), $style(2)) Send to vPowerGet.NET: {
var %lines = $sline($active,0)
if (!%lines) halt
var %cnter = 1
while (%cnter <= %lines) {
if ($com(vPG.NET,AddFiles,1,bstr,$sline($active,%cnter)) == 0) {
echo -s vPG.NET: AddFiles failed
}
if ($sbClient.Online($sline($active,%cnter)) == 1) { cline 10 $active $sline($active,%cnter).ln }
else { cline 6 $active $sline($active,%cnter).ln }
inc %cnter
}
}
-
Combine all sbClient result windows: {
var %c = 1
while (%c <= $window(@sbClient.*,0)) {
if ($window(@sbClient.*,%c) == @sbClient.combined) { inc %c | continue }
var %win = $addtok(%win, $window(@sbClient.*,%c),44)
inc %c
}
if (!$window(@sbClient.combined)) window -slk0wnz @sbClient.combined Arial 12
var %num = $numtok(%win,44)
var %v = 1
while (%v <= %num) {
var %b = 1
while (%b <= $line($gettok(%win,%v,44),0)) {
var %line = $line($gettok(%win,%v,44),%b)
if ((!%line) || ($pos(%line,$chr(33),1) != 1)) { var %f = 1 }
else aline -n @sbClient.combined %line
inc %b
}
window -c $gettok(%win,%v,44)
inc %v
}
window -bs @sbClient.combined
%cnter = 1
while (%cnter <= $line(@sbClient.combined,0)) {
var %line = $line(@sbClient.combined,%cnter)
if ($left(%line,1) == $chr(33)) {
if ($sbClient.Online(%line) == 1) cline 3 @sbClient.combined %cnter
else cline 4 @sbClient.combined %cnter
}
inc %cnter
}
}
-
Save search results: {
var %file = $+(",$sfile($mircdir, Save search results,Save),.txt")
if (!%file) halt
%file = $replace(%file,.txt.txt",.txt")
.savebuf $active %file
}
Load saved results: {
var %file = $+(",$sfile($mircdir,Load search results,Load),")
if (!%file) halt
loadbuf -r $active %file
titlebar $active
renwin $active @sbClient.OldResults -|- File " $+ $nopath(%file) $+ " loaded. -|- $line($active,0) lines -|- rclick for options -|-
}
-
Start new search: dialog -am sbClient_search sbClient_search
sbClient options: dialog -am sbClient_options sbClient_options
-
Close: window -c $active
-
}
alias sbclient.GetFileName {
var %Filetypes = .mp3;.wma;.mpg;.mpeg;.zip;.bz2;.txt;.exe;.rar;.tar;.jpg;.gif;.wav;.aac;.asf;.vqf;.avi;.mov;.mp2;.m3u;.kar;.nfo;.sfv;.m2v;.iso;.vcd;.doc;.lit;.pdf;.r00;.r01;.r02;.r03;.r04;.r05;.r06;.r07;.r08;.r09;.r10;.shn;.md5;.html;.htm;.jpeg;.ace;.png;.c01;.c02;.c03;.c04;.rtf;.wri;.txt
tokenize 32 $replace($1-,$chr(160),$chr(32))
var %Temp.Count = 1
while (%Temp.Count <= $numtok($1-,46)) {
var %Temp.Position = $pos($1-,.,%Temp.Count)
var %Temp.Filetype = $mid($1-,%Temp.Position,5)
var %Temp.Length = $len(%Temp.Filetype)
if ($istok(%Filetypes,%Temp.Filetype,59)) { return $left($1-,$calc(%Temp.Position + %Temp.Length)) }
inc %Temp.Count
}
return $1-
}
menu menubar,channel {
sbClient
.Search dialog (F4): dialog -am sbClient_search sbClient_search
.sbClient options: dialog -am sbClient_options sbClient_options
.-
.Load saved results: {
var %file = " $+ $sfile($mircdir,Load search results,load) $+ "
if (!$window(@sbClient.OldResults)) window -ek0lmwz @sbClient.OldResults Arial 12
loadbuf -r @sbClient.OldResults %file
titlebar @sbClient.OldResults -|- File " $+ $nopath(%file) $+ " loaded. -|- $line(@sbClient.OldResults,0) lines -|- rclick for options -|-
.-
}
}
menu menubar {
sbClient
.-
.Unload sbClient {
if ($?!="Do you really want to unload sbClient?" == $true) unload -rs $script
}
}
on *:unload: {
echo -s 1,9<<sbClient>> Unloading...
echo -s 1,9<<sbClient>> Closing sbClient windows
close -@sbClient.*
echo -s 1,9<<sbClient>> Removing variables...
unset %sbClient.*
echo -s 1,9<<sbClient>> sbClient removed. Note that sbClient files were not deleted.
}
on *:load: {
if ($script != $script(1)) .load -rs1 " $+ $script $+ "
echo -s 1,9<<sbClient>> Loading sbClient v $+ $sbClient.version by DukeLupus
echo -s 1,9<<sbClient>> Check 12www.dukelupus.com1,9 for help and updates.
echo -s 1,9<<sbClient>> Checking sbClient.dll
if (!$exists(" $+ $scriptdir $+ sbClient.dll $+ ")) {
echo -s 1,9<<sbClient>> sbClient.dll not found in script folder. Loading stopped.
unload -rs $script
}
else echo -s 1,9<<sbClient>> sbClient.dll version $dll(" $+ $scriptdir $+ sbClient.dll $+ ",GetDllVersion, nothing) by Iczelion found.
if ($me != DukeLupus) .ctcp DukeLupus DLX $me is loading sbClient version $sbClient.version
echo -s 1,9<<sbClient>> Checking mUnzip.dll
if (!$exists(" $+ $scriptdir $+ mUnzip.dll $+ ")) {
echo -s 1,9<<sbClient>> mUnzip.dll not found in script folder. Loading stopped.
unload -rs $script
}
else echo -s 1,9<<sbClient>> mUnzip.dll found: $replace($dll($scriptdir $+ mUnzip.dll, DLLInfo, .),S_OK,$null, $chr(32) $+ $chr(32), $chr(32))
echo -s 1,9<<sbClient>> Initializing variables...
%sbClient.storetxt = 1
%sbClient.checkver = 1
echo -s 1,9<<sbClient>> All done, sbClient successfully loaded
.timer 1 0 dialog -am sbClient_options sbClient_options
}
alias sbClient.Check {
if (!$server) { sbClient.error mIRC is not connected! | return 0 }
if ($len($2-) < 3) { sbClient.error Search string is too short - minimum search string length is three letters (excluding wildcards) | return 0 }
scon $sbClient.GetNetworkID($1)
if (!$chan($sbClient.GetChannel($1))) { sbClient.error You are not on selected channel! | return 0 }
if (!%sbClient. [ $+ [ $1 ] $+ ] .trigger) { sbClient.error No trigger from $1 received! | return 0) }
return 1
}
alias sbClient.DoSearch {
if (!%sbClient. [ $+ [ $1 ] $+ ] .trigger) halt
scon $sbClient.GetNetworkID($1)
msg $sbClient.GetChannel($1) %sbClient. [ $+ [ $1 ] $+ ] .trigger $2-
}
on *:filercvd:*SearchBot*results*for*: {
var %resultdir = $+($mircdir,SearchBot results)
if (!$exists($+(",%resultdir,"))) .mkdir $+(",%resultdir, ")
if ($right($nopath($filename),4) == .zip) {
if (OK isin $dll($scriptdir $+ mUnzip.dll,Unzip,-oM *.txt $+(",$filename,") $+(",%resultdir,"))) {
.remove $+(",$filename,")
var %rfile = $+(",%resultdir,\, SearchBot_results_for_,$replace($mid($nopath($filename),23-),_,$chr(32),.txt.zip,.txt),")
}
else { sbClient.error Unzipping of the results failed! | halt }
}
else {
.rename $+(",$filename,") $+(",%resultdir,$filename,")
var %rfile = $+(",%resultdir,$filename,")
}
var %a = $replace($nopath(%rfile),_,$chr(32),SearchBot_results_for_,$null,SearchBot results for,$null,.txt,$null,.zip,$null,$chr(32),.)
if (%sbClient.Separate) var %window = @sbClient.results. $+ %a
else var %window = @sbClient.results
window -ek0lmwz %window Arial 12
loadbuf -r %window %rfile
sbClient.ColorNicks %window
titlebar %window -|- SearchBot results for $+(",$replace($nopath(%rfile),SearchBot_results_for_,$null,SearchBot results for,$null,",$null),") -|- Current channel is %sbClient.SearchChannel -|- rclick for options -|-
if (%sbClient.storetxt) {
var %filename = $+(",$mircdir,SearchBot results,\,$replace($nopath(%rfile),SearchBot_results_for_,$null,",$null),")
if ($exists(%filename)) {
%filename = $replace(%filename,.txt,$+(.,$asctime(HH-mm-ss),.txt)) 
.rename %rfile %filename
}
}
else .remove %rfile
}
on *:input:@sbClient.results*: {
if ($left($1-,1) == /) halt
var %sstring = $sbclient.FixString($1-)
if ($sbClient.Check(%sbClient.SearchChannel,%sstring) == 0) halt
sbClient.DoSearch %sbClient.SearchChannel %sstring
}
on *:start: {
sbClient.Cleanup
if ($script(1) != $script) .reload -rs1 $script
if (%sbClient.checkver == 1) sbClient.update
}
on *:exit: { sbClient.Cleanup }
alias sbClient.Cleanup {
if (%sbClient.searching == 1) {
dll $+(",$scriptdir,sbClient.dll,") Stop 1
%sbClient.searching = 0
}
if ($exists($+(",$mircdir,sbClient.ls.results.txt,"))) .remove $+(",$mircdir,sbClient.ls.results.txt,")
}
alias sbClient.update {
if (!$server) halt
sockopen sbClient dukelupus.com 80
}
on *:sockopen:sbClient: {
.sockwrite -n $sockname GET /versions.txt HTTP/1.1
.sockwrite -n $sockname Host: dukelupus.com $+ $crlf $+ $crlf
}
on *:sockread:sbClient: {
if ($sockerr) {
.sockclose sbClient
halt
}
else {
var %t
sockread %t
if (($gettok(%t,1,59) == sbClient) && ($gettok(%t,2,59) != $sbClient.version)) {
echo -s 1,9<<sbClient>> You should update sbClient. You are using version $sbClient.version $+ , but version $gettok(%t,2,59) is available from sbClient website at 12http://www.dukelupus.com
.sockclose sbClient
}
elseif (($gettok(%t,1,59) == sbClient) && ($gettok(%t,2,59) == $sbClient.version)) {
if ($dialog(sbClient_options)) echo -s 1,9<<sbClient>> You have current version of sbClient
.sockclose sbClient
}
}
}
alias F4 { dialog -am sbClient_search sbClient_search }
on *:input:#: {
if (($1 == @find) || ($1 == @locator)) set -u600 %sbclient.searchactive 1
}
on ^*:open:?: {
if ((%sbclient.searchactive == 1) && (%sbClient.groupfind == 1)) {
sbclient.CheckPrivText $network $nick $strip($1-)
}
}
on ^*:text:*:?: {
if ((%sbclient.searchactive == 1) && (%sbClient.groupfind == 1)) {
sbclient.CheckPrivText $network $nick $strip($1-)
}
}
on ^*:notice:*:?: {
if ((%sbclient.searchactive == 1) && (%sbClient.groupfind == 1)) {
sbclient.CheckPrivText $network $nick $strip($1-)
}
}
alias sbclient.CheckPrivText {
var %net = $1
var %nick = $2
var %text = $3-
if (*Search Result*OmeNServE* iswm %text) sbclient.FindHeaders $1-
if (*OmeN*Search Result*ServE* iswm %text) sbclient.FindHeaders $1-
if (*Matches for*Copy and paste in channel* iswm %text) sbclient.FindHeaders $1-
if (*Total*files found* iswm %text) sbclient.FindHeaders $1-
if (*Search Results*QwIRC* iswm %text) sbclient.FindHeaders $1-
if (*Search Result*Too many files*Type* iswm %text) sbclient.FindHeaders $1-
if (*@Find Results*SysReset* iswm %text) sbclient.FindHeaders $1-
if (*End of @Find* iswm %text) sbclient.FindHeaders $1-
if (*I have*for*in listfile*type* iswm %text) sbclient.FindHeaders $1-
if (*SoftServe*Search result* iswm %text) sbclient.FindHeaders $1-
if (*Tengo*coincidencia* para* iswm %text) sbclient.FindHeaders $1-
if (*I have*match*for*Copy and Paste* iswm %text) sbclient.FindHeaders $1-
if (*Too many results*@* iswm %text) sbclient.FindHeaders $1-
if (*Tengo*resultado*slots* iswm %text) sbclient.FindHeaders $1-
if (*I have*matches for*You might want to get my list by typing* iswm %text) sbclient.FindHeaders $1-
if (*Résultat De Recherche*OmeNServE* iswm %text) sbclient.FindHeaders $1-
if (*Resultados De Busqueda*OmenServe* iswm %text) sbclient.FindHeaders $1-
if (*Total de*fichier*Trouvé* iswm %text) sbclient.FindHeaders $1-
if (*Fichier* Correspondant pour*Copie* iswm %text) sbclient.FindHeaders $1-
if (*Search Result*Matches For*Copy And Paste* iswm %text) sbclient.FindHeaders $1-
if (*Resultados de la búsqueda*DragonServe* iswm %text) sbclient.FindHeaders $1-
if (*Results for your search*DragonServe* iswm %text) sbclient.FindHeaders $1-
if (*«SoftServe»* iswm %text) sbclient.FindHeaders $1-
if (*search for*returned*results on list* iswm %text) sbclient.FindHeaders $1-
if (*List trigger:*Slots*Next Send*CPS in use*CPS Record* iswm %text) sbclient.FindHeaders $1-
if (*Searched*files and found*matching*To get a file, copy !* iswm %text) sbclient.FindHeaders $1-
if (*Note*Hey look at what i found!* iswm %text) sbclient.FindHeaders $1-
if (*Note*MP3-MP3* iswm %text) sbclient.FindHeaders $1-
if (*Search Result*Matches For*Get My List Of*Files By Typing @* iswm %text) sbclient.FindHeaders $1-
if (*Resultado Da Busca*Arquivos*Pegue A Minha Lista De*@* iswm %text) sbclient.FindHeaders $1-
if (*J'ai Trop de Résultats Correspondants*@* iswm %text) sbclient.FindHeaders $1-
if (*I have found*files that match your search* iswm %text) sbclient.FindHeaders $1-
if (*Search Results*Found*matches for*Type @*to download my list* iswm %text) sbclient.FindHeaders $1-
tokenize 32 %text
if ((*Omen* iswm $1) && ($chr(33) isin $2)) sbclient.FindResults %nick %text
if ($pos($1,$chr(33),1) == 1) sbclient.FindResults %nick %text
if (($1 == $chr(58)) && ($pos($2,$chr(33),1) == 1)) sbclient.FindResults %nick %text
}
alias sbclient.FindHeaders {
var %net = $1
var %nick = $2
var %text = $3-
var %cnter = 1
while (%cnter <= $numtok(%text,32)) {
if (($gettok(%text,%cnter,32) isnum) && (!%fndfiles)) {
var %fndfiles = $gettok(%text,%cnter,32)
}
if ($pos($gettok(%text,%cnter,32),$chr(64),1) == 1) {
if ($len($gettok(%text,%cnter,32)) > 1) var %trigger = $gettok(%text,%cnter,32)
}
inc %cnter
}
if ((!%fndfiles) || (!%trigger)) {  halt }
if (!$window(@find.ServerData)) window -slk1wnz -t5,15,25,35,45 @find.ServerData Arial 12
aline -n @find.ServerData %net $+ $chr(9) $+ %nick $+ $chr(9) $+ %fndfiles $+ $chr(9) $+ %trigger
titlebar @find.ServerData -=- Network -=- Nick -=- Number of matches -=- List trigger -=- rclick for options -=-
halt
}
alias sbclient.FindResults {
if (!$window(@sbClient.@find.results)) window -slk0wnz @sbClient.@find.results Arial 12
var %line = $right($2-,$calc($len($2-) - ($pos($2-,$chr(33),1) - 1)))
aline -n @sbClient.@find.results %line
window -b @sbClient.@find.results
titlebar @sbClient.@find.results -=- $line(@sbClient.@find.results,0) results so far -=- Right-click for options
halt
}
menu @find.ServerData {
Copy trigger to clipboard: {
if (!$sline($active,0)) halt
.clipboard
.clipboard $gettok($sline(@find.ServerData,1),4,9)
}
-
$iif(!$script(AutoGet.mrc), $style(2)) Open/Request list with AG7 {
var %line = $gettok($sline(@find.ServerData,1),2,9) $sbClient.AG $sbClient.cid($gettok($sline(@find.ServerData,1),1,9))
MTgetlist %line
}
$iif(!$script(AutoGet.mrc), $style(2)) Update list with AG7 {
var %line = $gettok($sline(@find.ServerData,1),2,9) $sbClient.AG $sbClient.cid($gettok($sline(@find.ServerData,1),1,9))
MTupdatelist %line
}
-
Start new search: dialog -am sbClient_search sbClient_search
sbClient options: dialog -am sbClient_options sbClient_options
-
Clear: /clear
Close: window -c $active
-
}
alias sbClient.cid {
var %cnter = 1
while (%cnter <= 10) {
if (!$scid(%cnter)) { inc %cnter | continue }
if ($scid(%cnter).$network == $1) return %cnter
inc %cnter
}
}
alias sbClient.AG {
scon $sbClient.GetNetworkID($gettok($sline(@find.ServerData,1),1,9))
var %nick = $gettok($sline(@find.ServerData,1),2,9)
var %comchans = $comchan(%nick,0)
%cnter = 1
while (%cnter <= %comchans) {
var %nwc = $comchan(%nick,%cnter) $+ : $+ $gettok($sline(@find.ServerData,1),1,9)
if ($istok(%MTchanservs,%nwc,255) == $true) return $comchan(%nick,%cnter)
inc %cnter
}
}
