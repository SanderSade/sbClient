;
; 2.23.1
; mostly style changes, usage of $qt()
; added sbClientdll alias & used it for all dll calls.
; changed :dialog:sbClient_options:sclick:61: to no longer need $numtok() call.
; fixed? several errors in :dialog:sbClient_search:sclick:1: unsure if logic used matches what was intended.
; rewrote sbClient.Online to be shorter, no longer returns 0 or 1, but 0 or > 0, other code changed to reflect this.
; rewrote sbclient.GetFileName to correctly return the filename upto first ext.
; changed :load: to check for connected status before trying to ctcp.
; changed :filercvd:*SearchBot*results*for*: to use $remove instead of $replace
; changed sbclient.FindHeaders loop to abit leaner ;)
; changed sbclient.FindResults to use a simpler method of getting the line.
; changed sbClient.error to use /noop
; changed sbClient.ColorNicks
; changed sbClient.LS.Loadresults
; 2.23.2
; changed sbClient.ColorNicks to take another arg $2 that is either 1 or 0 (or $null) & tells the alias that the line must start with a ! before being coloured.
; 2.23.3
; fixed :dialog:sbClient_search:sclick:1: I got the logic wrong in the previous fix.
; 2.23.4
; changed sbClient.SearchDone to show text in titlebar instead of using $input
; 2.23.5
; changed sbclient.GetFileName to use a regex
; added fixes for some tabs issues
; 2.23.6
; removed tabs fixes.
; 2.23.7
; changed sbClient.LS.Loadresults to correctly filter tabs
; changed sbClient.LS.Loadresults to take 2 args a window name & a filename
; changed load old results code to use new sbClient.LS.Loadresults
; 2.23.8
; rewrote Copy line(s) to clipboard: menu item for @sbClient.* windows
; fixed issue with lines that used to contain $chr(9) not being copied to clipboard.
; 2.23.9
; added KEYDOWN:@sbClient.*:*: event press ctrl-z in a list window to copy the whole line or ctrl-c to copy the filename part.
; added a key check to the copy to clipboard menutitem, now is ctrl is pressed when the item is selected the whole line is copied instead of just the filename.
; 2.23.10
; fixed sbclient.GetFileName not returning unknown ext's
; 2.23.11
; added a workaround to KEYDOWN event for bugs in pre 7.11 mIRC.
; 2.23.12
; added sbClient.LoadOldResults alias & changed menu items to use it.
; reworked the logic of :dialog:sbClient_search:sclick:1: again, should be finally fixed now.
; 2.23.13
; changed search done code to stop shifting focus to dialog.
; changed search done code to open results window minimized if the search dialog has lost focus
; fixed multi-line copy to clipboard issue.
; 2.23.14
; changed qt alias to give the same output as the built in qt alias in all conditions.
; changed sbclient.GetFileName to match any ext without needing a known list.
; 2.23.15
; changed sbclient.GetFileName to match the whole filesname upto the last ext.
; 2.23.16
; removed some commented code.
; 2.23.17
; added sbClient.remove alias
; added sbClient.rename alias
; added sbClient.loadbuf alias
; 2.23.18
; added update for titlebar after 'Remove Offline Nicks' menu item is used.
; 2.23.19
; added image file types to file types filter.
; 2.23.20
; added a workaround for a search dll bug that causes searches like: "miss mary is scary" to fail when they shouldn't. This only affects local searches.
; 2.23.21
; fixed clipboard multiline-copy missing a crlf
; 2.23.22
; Improved bugfix applied in 2.23.20
; 2.23.23
; Removed workaround for v1.8.3 dll bugs, using new v2+ dll instead.
; Updated sbClient.dll to v2.0.2
; 2.23.24
; fixed clipboard multiline-copy missing a crlf
; 2.23.25
; Updated sbClient.dll to v2.0.4.18
; 2.23.26
; Updated sbClient.dll to v2.0.4.19
; 2.23.27
; added sbClient.mkdir alias to provide error protected mkdir
; fixed bugs in file recieved event due to file name changes in latest searchbots
; changed `remove offline nicks` filter in search results window to also remove all non-nick lines
;

alias sbClient.version return 2.23.27

; Ook: added shortcut for dll
alias sbClientdll return $dll($qt($scriptdirsbClient.dll),$1,$2-)

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
    while ($chan(%cnter2) != $null) {
      did -a sbClient_options 31 $+($v1,@,$network)
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
  if ($istok(%sbClient.channels,$did(31).seltext,44)) halt
  set %sbClient.channels $addtok(%sbClient.channels,$did(31).seltext,44)
  did -r sbClient_options 51
  didtok sbClient_options 51 44 %sbClient.channels
  sbClient.GetTrigger $did(31).seltext
}
on *:dialog:sbClient_options:sclick:56: {
  if (!$did(51).seltext) halt
  set %sbClient.channels $remtok(%sbClient.channels,$did(51).seltext,44)
  did -r sbClient_options 51
  didtok sbClient_options 51 44 %sbClient.channels
}
on *:dialog:sbClient_options:sclick:91: url -an http://www.dukelupus.com
on *:dialog:sbClient_options:sclick:76: sbClient.update
on *:dialog:sbClient_options:sclick:96: set %sbClient.groupfind $did(96).state
on *:dialog:sbClient_options:close:*: {
  set %sbClient.storetxt $did(26).state
  set %sbClient.nomax $did(66).state
  set %sbClient.checkver $did(71).state
  set %sbClient.groupfind $did(96).state
}
on *:dialog:sbClient_options:sclick:61: {
  var %cnter = 1
  while ($gettok(%sbClient.channels,%cnter,44) != $null) {
    sbClient.GetTrigger $v1
    inc %cnter
  }
}
on *:dialog:sbClient_options:sclick:16: {
  set %sbClient.storetxt $did(26).state
  set %sbClient.nomax $did(66).state
  set %sbClient.checkver $did(71).state
  dialog -x sbClient_options sbClient_options
  dialog -am sbClient_search sbClient_search
}
alias sbClient.GetTrigger {
  scon $sbClient.GetNetworkID($1)
  echo -s 1,9<<sbClient>> Requesting SearchBot trigger from $sbClient.GetChannel($1) (network $gettok($1,2,64) $+ ).
  msg $sbClient.GetChannel($1) @SearchBot-trigger
  set $+(%,sbClient.,$1,.requested) 1
}
alias sbClient.GetChannel return $gettok($1,1,64)
alias sbClient.GetNetworkID {
  var %net = $gettok($1,2,64), %cnter = 1
  while (%cnter <= $scon(0)) {
    if ($scon(%cnter).$network == %net) return %cnter
    inc %cnter
  }
}
ctcp *:TRIGGER: {
  if ($($+(%,sbClient.,$3,@,$2,.requested),2) == 1) {
    set $+(%,sbClient.,$3,@,$2,.trigger) $4
    unset $+(%,sbClient.,$3,@,$2,.requested)
    echo -s 1,9<<sbClient>> Received SearchBot trigger from $3 (network $2 $+ ): $4
  }
}
ctcp *:VERSION: {
  if ($network != DejaToons) .ctcpreply $nick VERSION 1,9<<sbClient>> version $sbClient.version by DukeLupus.1,15 Get it from 12,15http://www.dukelupus.com (Modified by Ook)
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
  var %cnter = 1, %channels
  while (%cnter <= $scon(0)) {
    scon %cnter
    var %cnter2 = 1
    while ($chan(%cnter2) != $null) {
      var %channels = $addtok(%channels,$+($v1,@,$network),44)
      inc %cnter2
    }
    inc %cnter
  }
  didtok sbClient_search 21 44 %channels
  did -c sbClient_search 21 %sbClient.last2
}
on *:dialog:sbClient_search:close:0: {
  set %sbClient.last1 $did(20).sel
  set %sbClient.last2 $did(21).sel
}
on *:dialog:sbClient_search:sclick:15: {
  ; if not set alrdy then set to default.
  if (%sbClient.ListFolder == $null) set %sbClient.ListFolder $mircdirLists
  ; use previous folder as start location.
  set %sbClient.ListFolder $sdir(%sbClient.ListFolder, Select list folder)
  if (%sbClient.ListFolder == $null) did -o sbClient_search 6 1 Not selected
  else did -o sbClient_search 6 1 %sbClient.ListFolder
}
on *:dialog:sbClient_search:sclick:16: set %sbClient.Separate $did(16).state
on *:dialog:sbClient_search:sclick:10: set %sbClient.menu.local $did(10).state
on *:dialog:sbClient_search:sclick:11: set %sbClient.menu.channel $did(11).state
on *:dialog:sbClient_search:sclick:25: set %sbClient.find.channel $did(25).state
on *:dialog:sbClient_search:sclick:1: {
  if ((!$did(10).state) && (!$did(25).state) && (!$did(11).state)) {
    sbClient.error You really should choose at least one search method.
    halt
  }
  if ($did(5).text == $null) {
    sbClient.error No search string!
    halt
  }
  var %sstring = $sbClient.FixString($did(5).text)
  if (%sstring == $null) {
    sbClient.error I don't like your search string!
    halt
  }
  if ($did(10).state) {
    ; do local search
    if (%sbClient.searching == 1) {
      if ($input(Local search seems to be already active. Do you want to stop active local search and start your current search?,yqd,Local search is active) == $true) {
        sbClientdll Stop 1
        set %sbClient.searching 0
      }
      else halt
      if ($did(11).state) goto chansearch
    }
    if (!%sbClient.ListFolder) {
      sbClient.error No list folder!
      if ($did(11).state) goto chansearch
      halt
    }
    if ($findfile(%sbClient.ListFolder,*.txt,0,1) == 0) {
      sbClient.error There are no lists in the selected folder!
      if ($did(11).state) goto chansearch
      halt
    }
    sbClient.DoLocalSearch %sstring
  }
  :chansearch
  if ($did(25).state) {
    .set -u600 %sbclient.searchactive 1
    .set -u600 %DLF.searchactive 1
    scon $sbClient.GetNetworkID($did(21).seltext) msg $sbClient.GetChannel($did(21).seltext) @find %sstring
  }
  if ($did(11).state) {
    if (!$did(20).seltext) { sbClient.error No channel selected! | halt }
    var %schan = $did(20).seltext
    if ($sbClient.Check(%schan,%sstring) == 0) halt
    set %sbClient.SearchChannel %schan
    sbClient.DoSearch %schan %sstring
  }
  did -r sbClient_search 5
  dialog -t sbClient_search Now searching for $+(",%sstring,".)
}
alias sbClient.error noop $input($1-,ohd,sbClient error)
alias sbClient.FixString return $replace($1-,$chr(34),$null,$chr(39), $chr(32),$chr(42),$chr(32),$chr(63),$chr(32),$chr(32) $+ $chr(32),$chr(32))
alias sbClient.DoLocalSearch {
  set %sbClient.string $1-
  var %folder = $+(%sbClient.ListFolder,*.txt)
  if (%sbClient.nomax == 1) var %maxresults = 10000000
  else var %maxresults = 3000
  set %sbClient.searching 1
  if ($sbClient.remove($mircdirsbClient.ls.results.txt)) {
    sbClientdll SetOutputName $mircdirsbClient.ls.results.txt
    sbClientdll SetListFolder %folder
    sbClientdll SetSearchString %sbClient.string
    sbClientdll SetMaxReplies %maxresults
    sbClientdll SetReturnAlias sbClient.SearchDone
    sbClientdll Search 1
  }
  else sbClient.error Unable to remove $qt($mircdirsbClient.ls.results.txt)
}
alias sbClient.SearchDone {
  set %sbClient.searching 0
  if ($1 == 0) {
    if ($dialog(sbClient_search) != $null) dialog -t sbClient_search No results for $qt(%sbClient.string)
    else dialog -am sbClient_search sbClient_search
    halt
  }
  if (%sbClient.Separate) var %window = $+(@sbClient.local.,$gettok(%sbClient.string,1,32))
  else var %window = @sbClient.local
  if (!$window(%window)) {
    if ($dialog(sbClient_search).active) window -ek0lmwz %window Arial 12
    else window -ek0lmwzn %window Arial 12
  }
  else clear %window
  titlebar %window -|- sbClient local search results for $qt(%sbClient.string) -|- $findfile(%sbClient.ListFolder,*.txt,0,1) lists searched -|- $1 results -|- rclick for options -|-
  sbClient.LS.Loadresults %window $2-
  if ($dialog(sbClient_search) != $null) dialog -t sbClient_search Search for $qt(%sbClient.string) Complete.
}
; Ook: changed to handle $chr(9) (tab) issues in some mIRC's
;alias sbClient.LS.Loadresults {
;  ; Ook: %file not used?
;  ;var %file = $qt($1-)
;  loadbuf -r %sbClient.window $qt($mircdirsbClient.ls.results.txt)
;  sbClient.ColorNicks %sbClient.window
;  .remove $qt($mircdirsbClient.ls.results.txt)
;}
; $1 = @window, $2- = filename
alias sbClient.LS.Loadresults {
  ; Ook: remove tabs
  set %sbClient.window $1
  var %file = $qt($2-)
  if (!$isfile(%file)) return
  clear %sbClient.window
  filter -fk %file sbClient.window.filter !*
  sbClient.ColorNicks %sbClient.window
  if (sbClient.ls.results.txt == $nopath(%file)) {
    if (!$sbClient.remove(%file)) sbClient.error Unable to remove %file
  }
}
alias -l sbClient.window.filter {
  ; if using !* filter then its never going to be $null even after removing $chr(9)
  aline %sbClient.window $replace($1-,$chr(9),$chr(32))
}
; $1 = @win, ($2 = only !lines, 0 or 1)
alias sbClient.ColorNicks {
  var %cnter = 1, %tot = $line($1,0)
  while (%cnter <= %tot) {
    if ($line($1,%cnter) != $null) {
      set -ln %l $v1
      if ((!$2) || ($left(%l,1) == !)) {
        if ($sbClient.Online(%l)) cline 3 $1 %cnter
        else cline 4 $1 %cnter
      }
    }
    inc %cnter
  }
}
alias sbClient.Online {
  tokenize 32 $1
  var %nick = $remove($1,-new)
  if ($left(%nick,1) == !) %nick = $right(%nick,-1)
  if (%nick == $null) return 0
  var %c = 0
  scon -at1 inc % $+ c $!comchan( %nick ,0)
  return %c
}
on *:input:@sbClient.local*,@sbClient.OldResults: {
  if ($left($1-,1) == /) halt
  if (%sbClient.searching == 1) {
    if ($input(Local search seems to be already active. Do you want to stop active search and start your current search?,yqd,Local search is active) == $true) { sbClient.Cleanup }
    else halt
  }
  var %sstring = $sbClient.FixString($1-)
  ; Ook: should be == $null to allow search for 0 ?
  if (!%sstring) {
    sbClient.error I don't like your search string!
    halt
  }
  sbClient.DoLocalSearch %sstring
}
menu @sbClient.OldResults,@sbClient.@find.results,@sbClient.combined {
  Check online status: sbClient.ColorNicks $active 1
}
menu @sbClient.* {
  Remove off-line nicks: {
    ; Ook: local var, can't use sbClient.ColorNicks here.
    var %cnter = 1
    while (%cnter <= $line($active,0)) {
      var %line = $line($active,%cnter)
      ;if ($left(%line,1) == $chr(33)) {
      ;  if (!$sbClient.Online(%line)) {
      ;    dline $active %cnter
      ;    continue
      ;  }
      ;  else cline 3 $active %cnter
      ;}
      if ($asc(%line) != 33) {
        dline $active %cnter
        continue
      }
      if (!$sbClient.Online(%line)) {
        dline $active %cnter
        continue
      }
      else cline 3 $active %cnter
      inc %cnter
    }
    titlebar $active -|- sbClient local search results for $qt(%sbClient.string) -|- $findfile(%sbClient.ListFolder,*.txt,0,1) lists searched -|- $line($active,0) results -|- rclick for options -|-
  }
  Remove File Types: {
    window -h @sbClient.tmp
    var %types = $input(Enter a $chr(124) seperated list of filetypes to remove,euywm,Remove File Types,(si)?pdf|epub|mobi|azw3?|docx?|txt|tif|cbr|rtf|fb2,epub|mobi|azw3?,(si)?pdf|epub|mobi|azw3?|docx?|txt|tif|cbr|rtf|fb2,epub|mobi|azw3?,docx?|txt|rtf,tif|cbr|pdf,html?,jpe?g|png|gif|tiff?)
    if (%types == $null) return
    filter -wwxzg $menu @sbClient.tmp /(?:\.(?: $+ %types $+ )\s|[\(\[] $+ %types $+ [\)\]])/i
    filter -wwzc @sbClient.tmp $menu *
    window -c @sbClient.tmp
    titlebar $active -|- sbClient local search results for $qt(%sbClient.string) -|- $findfile(%sbClient.ListFolder,*.txt,0,1) lists searched -|- $line($active,0) results -|- rclick for options -|-
  }
  -
  Copy line(s) to clipboard: {
    var %t = $sline($active,0), %cnter = 1
    if (!%t) halt
    clipboard
    while ($sline($active,%cnter) != $null) {
      var %l = $v1
      if ($sbClient.Online(%l)) cline 10 $active $sline($active,%cnter).ln
      else cline 6 $active $sline($active,%cnter).ln
      if (%t == 2) clipboard -an $+($crlf,$iif($mouse.key & 2,%l,$sbClient.GetFileName(%l)))
      elseif (%t > 1) clipboard -an $iif($mouse.key & 2,%l,$sbClient.GetFileName(%l))
      else clipboard -n $iif($mouse.key & 2,%l,$sbClient.GetFileName(%l))
      inc %cnter
    }
    titlebar $active -|- $sline($active,0) line(s) copied to clipboard -|-
  }
  $iif(!$script(AutoGet.mrc), $style(2)) Send to AutoGet 7: {
    var %path = $nofile($script(AutoGet.mrc))
    .fopen MTlisttowaiting $+(",%path,AGwaiting.ini,")
    if ($fopen(MTlisttowaiting).err) return
    .fseek -l MTlisttowaiting $lines($+(",%path,AGwaiting.ini,"))
    if ($fopen(MTlisttowaiting).err) return
    var %i = 1, %j = 0
    while (%i <= $sline($active,0)) {
      var %temp = $MTlisttowaiting($sline($active,%i))
      inc %j $gettok(%temp,1,32)
      if ($sbClient.Online($sline($active,%i))) cline 10 $active $sline($active,%i).ln
      else cline 6 $active $sline($active,%i).ln
      inc %i
    }
    .fclose MTlisttowaiting
    if (%MTautorequest == 1) MTkickstart $gettok(%temp,2,32)
    MTwhosinque
    if ($dialog(Autoget)) updatewaitinglist
    if (%MTecho) echo -s %MTlogo Added %j File(s) To Waiting List From sbClient
  }
  $iif(!$script(vPowerGet.net.mrc), $style(2)) Send to vPowerGet.NET: {
    var %lines = $sline($active,0)
    if (!%lines) return
    var %cnter = 1
    while (%cnter <= %lines) {
      if ($com(vPG.NET,AddFiles,1,bstr,$sline($active,%cnter)) == 0) echo -s vPG.NET: AddFiles failed
      if ($sbClient.Online($sline($active,%cnter))) cline 10 $active $sline($active,%cnter).ln
      else cline 6 $active $sline($active,%cnter).ln
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
    var %num = $numtok(%win,44), %v = 1
    while (%v <= %num) {
      var %b = 1
      while (%b <= $line($gettok(%win,%v,44),0)) {
        var %line = $line($gettok(%win,%v,44),%b)
        if ($left(%line,1) == !) aline -n @sbClient.combined %line
        inc %b
      }
      window -c $gettok(%win,%v,44)
      inc %v
    }
    window -bs @sbClient.combined
    sbClient.ColorNicks @sbClient.combined 1
  }
  -
  Save search results: {
    var %file = $+(",$sfile($mircdir, Save search results,Save),.txt")
    if (!%file) halt
    .savebuf $active $replace(%file,.txt.txt",.txt")
  }
  Load saved results: sbClient.LoadOldResults $active
  -
  Start new search: dialog -am sbClient_search sbClient_search
  sbClient options: dialog -am sbClient_options sbClient_options
  -
  Close: window -c $active
  -
}
; $1 = @window
alias -l sbClient.LoadOldResults {
  var %file = $sfile($mircdir,Load search results,Load)
  if (%file == $null) return
  if ($1 != @sbClient.OldResults) renwin $1 @sbClient.OldResults
  if (!$window(@sbClient.OldResults)) window -ek0lmwz @sbClient.OldResults Arial 12
  if (!$isfile(%file)) {
    titlebar @sbClient.OldResults [ERROR] Invalid file: $qt(%file)
    return
  }
  sbClient.LS.Loadresults @sbClient.OldResults %file
  titlebar @sbClient.OldResults -|- File $qt($nopath(%file)) loaded. -|- $line(@sbClient.OldResults,0) lines -|- rclick for options -|-
}
alias sbclient.GetFileName {
  var %r = /^(.*\.[a-z][a-z\d]{1,4})(?:\s|$)/
  tokenize 32 $replace($1-,$chr(160),$chr(32))
  if ($regex($1-,%r)) return $regml(1)
  ; didn't get extension :(
  return $1-
}
menu menubar,channel {
  sbClient
  .Search dialog (F4): {
    if ($dialog(sbClient_search) == $null) dialog -am sbClient_search sbClient_search
    else dialog -v sbClient_search
  }
  .sbClient options: dialog -am sbClient_options sbClient_options
  .-
  .Load saved results: sbClient.LoadOldResults @sbClient.OldResults
  .-
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
  if ($script != $script(1)) .load -rs1 $qt($script)
  echo -s 1,9<<sbClient>> Loading sbClient v $+ $sbClient.version by DukeLupus
  echo -s 1,9<<sbClient>> Check 12www.dukelupus.com1,9 for help and updates.
  echo -s 1,9<<sbClient>> Checking sbClient.dll
  if (!$isfile($qt($scriptdirsbClient.dll))) {
    echo -s 1,9<<sbClient>> sbClient.dll not found in script folder. Loading stopped.
    unload -rs $script
  }
  else echo -s 1,9<<sbClient>> sbClient.dll version $sbClientdll(GetDllVersion, nothing) by Iczelion found.
  ; Ook: check for connected status before sending ctcp
  ;if (($me != DukeLupus) && ($status == connected)) .ctcp DukeLupus DLX $me is loading sbClient version $sbClient.version
  echo -s 1,9<<sbClient>> Checking mUnzip.dll
  if (!$isfile($qt($scriptdirmUnzip.dll))) {
    echo -s 1,9<<sbClient>> mUnzip.dll not found in script folder. Loading stopped.
    unload -rs $script
  }
  else echo -s 1,9<<sbClient>> mUnzip.dll found: $replace($dll($scriptdirmUnzip.dll, DLLInfo, .),S_OK,$null, $chr(32) $+ $chr(32), $chr(32))
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
  if (!$($+(%,sbClient.,$1,.trigger),2)) { sbClient.error No trigger from $1 received! | return 0) }
  return 1
}
alias sbClient.DoSearch {
  if (!$($+(%,sbClient.,$1,.trigger),2)) halt
  scon $sbClient.GetNetworkID($1)
  msg $sbClient.GetChannel($1) $($+(%,sbClient.,$1,.trigger),2) $2-
}
on *:filercvd:Search*results*for*: {
  var %resultdir = $+($mircdir,SearchBot results), %fn = $nopath($filename)
  if (!$isdir(%resultdir)) {
    if (!$sbClient.mkdir(%resultdir)) { sbClient.error Unable to make folder: %resultdir | halt }
  }
  ; try to determine if its a valid results file & not something else.
  if (!$regex(%fn,/^(Search\w+?)[_\s]results[_\s]for[_\s]/i)) return
  var %r = $regsubex(%fn,/(Search\w+?)[_\s]results[_\s]for[_\s](.*)$/,$+(\1_results_for_,$chr(1),$replace(\2,_,$chr(32),.txt.zip,.txt)))
  if ($right(%fn,4) == .zip) {
    if (OK !isin $dll($scriptdirmUnzip.dll,Unzip,-oM *.txt $qt($filename) $qt(%resultdir))) { sbClient.error Unzipping of the results failed! | halt }
    if (!$sbClient.remove($filename)) { sbClient.error Unable to remove archive: $filename | halt }
    ;var %rfile = $+(",%resultdir,\, SearchBot_results_for_,$replace($mid(%fn,23-),_,$chr(32),.txt.zip,.txt),")
    ;var %rfile = $+(",%resultdir,\,$gettok(%r,1,1),$replace($gettok(%r,2,1),_,$chr(32),.txt.zip,.txt),")
    var %rfile = $+(",%resultdir,\,$gettok(%r,1,1),$gettok(%r,2,1),")
  }
  else {
    var %rfile = $+(",%resultdir,%fn,")
    if (!$sbClient.rename($filename,%rfile)) { sbClient.error Unable to move file: $filename | halt }
  }
  ;var %a = $replace($nopath(%rfile),_,$chr(32),SearchBot_results_for_,$null,SearchBot results for,$null,.txt,$null,.zip,$null,$chr(32),.)
  var %a = $replace($gettok(%r,2,1),.txt,$null,.zip,$null,$chr(32),.)
  if (%sbClient.Separate) var %window = @sbClient.results. $+ %a
  else var %window = @sbClient.results
  window -ek0lmwz %window Arial 12
  if (!$sbClient.loadbuf(-r %window %rfile)) { sbClient.error Unable to load %rfile | window -c %window | halt }
  sbClient.ColorNicks %window
  ;titlebar %window -|- SearchBot results for $qt($remove($nopath(%rfile),SearchBot_results_for_,SearchBot results for,")) -|- Current channel is %sbClient.SearchChannel -|- rclick for options -|-
  ;titlebar %window -|- SearchBot results for $qt($remove($nopath(%rfile),$gettok(%r,1,1),.txt,")) -|- Current channel is %sbClient.SearchChannel -|- rclick for options -|-
  titlebar %window -|- SearchBot results for $qt($right($left($gettok(%r,2,1),-4),-1)) -|- Current channel is %sbClient.SearchChannel -|- rclick for options -|-
  if (%sbClient.storetxt) {
    ;var %filename = $+(",$mircdir,SearchBot results,\,$remove($nopath(%rfile),SearchBot_results_for_,"),")
    var %filename = $+(",$mircdir,SearchBot results,\,$gettok(%r,2,1),")
    var %filename = $replace(%filename,.txt,$+(.,$asctime(yyyy-mm-dd-HH-mm-ss),.txt))
    if ($isfile(%filename)) var %filename = $replace(%filename,.txt,$+(.,$ticks,.txt))
    if (!$sbClient.rename(%rfile,%filename)) sbClient.error Unable to rename %rfile to %filename
  }
  elseif (!$sbClient.remove(%rfile)) sbClient.error Unable to remove %rfile
  return
  :error
  if (*unable to open file*Search*_results* iswm $error) {
    echo 4 -sa [ERROR] Unable to open search results, possible file access restrictions.
    echo 4 -sa [ERROR] Try & manually open the file, if this fails (access denied) look at the security details for the file.
  }
}
on *:input:@sbClient.results*: {
  if ($left($1-,1) == /) halt
  var %sstring = $sbclient.FixString($1-)
  if ($sbClient.Check(%sbClient.SearchChannel,%sstring) == 0) halt
  sbClient.DoSearch %sbClient.SearchChannel %sstring
}
on *:start: {
  ; compatibility stuff...
  .disable #sbclient_nonoop
  .disable #sbclient_noqt
  if ($version < 6.17) {
    if (!$isalias(noop)) .enable #sbclient_nonoop
    if (!$isalias(qt)) .enable #sbclient_noqt
  }
  ;
  sbClient.Cleanup
  if ($script(1) != $script) .reload -rs1 $script
  if (%sbClient.checkver == 1) sbClient.update
}
#sbclient_nonoop off
alias noop
#sbclient_nonoop end
#sbclient_noqt off
; gives the same results as the real qt alias
alias qt {
  var %l = ", %r = "
  if ($left($1,1) == ") var %l
  if ($right($1-,1) == ") var %r
  return $+(%l,$1-,%r)
}
#sbclient_noqt end

on *:exit: sbClient.Cleanup
alias sbClient.Cleanup {
  if (%sbClient.searching == 1) {
    sbClientdll Stop 1
    %sbClient.searching = 0
  }
  var %f = $mircdirsbClient.ls.results.txt
  if ($isfile(%f)) {
    if (!$sbClient.remove(%f)) sbClient.error Unable to remove %f
  }
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
  var %net = $1, %nick = $2, %text = $3-
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
  if ((*Omen* iswm $1) && (! isin $2)) sbclient.FindResults %nick %text
  if ($left($1,1) == !) sbclient.FindResults %nick %text
  if (($1 == $chr(58)) && ($left($2,1) == !)) sbclient.FindResults %nick %text
}
alias sbclient.FindHeaders {
  var %net = $1, %nick = $2, %text = $3-, %cnter = 1
  while ($gettok(%text,%cnter,32) != $null) {
    var %tok = $v1
    if ((%tok isnum) && (!%fndfiles)) var %fndfiles = %tok
    elseif (($left(%tok,1) == @) && ($len(%tok) > 1)) var %trigger = %tok
    inc %cnter
  }
  if ((!%fndfiles) || (!%trigger)) {  halt }
  if (!$window(@find.ServerData)) window -slk1wnz -t5,15,25,35,45 @find.ServerData Arial 12
  aline -n @find.ServerData $+(%net,$chr(9),%nick,$chr(9),%fndfiles,$chr(9),%trigger)
  titlebar @find.ServerData -=- Network -=- Nick -=- Number of matches -=- List trigger -=- rclick for options -=-
  halt
}
alias sbclient.FindResults {
  if (!$window(@sbClient.@find.results)) window -slk0wnz @sbClient.@find.results Arial 12
  var %line = $+(!,$gettok($2-,2,33))
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
  Clear: clear
  Close: window -c $active
  -
}
alias sbClient.cid {
  var %cnter = 1
  while ($scon(%cnter) != $null) {
    var %cid = $v1
    if ($scon(%cnter).$network == $1) return %cid
    inc %cnter
  }
}
alias sbClient.AG {
  scon $sbClient.GetNetworkID($gettok($sline(@find.ServerData,1),1,9))
  var %nick = $gettok($sline(@find.ServerData,1),2,9), %cnter = 1
  while ($comchan(%nick,%cnter) != $null) {
    var %c = $v1, %nwc = $+(%c,:,$gettok($sline(@find.ServerData,1),1,9))
    if ($istok(%MTchanservs,%nwc,255) == $true) return %c
    inc %cnter
  }
}
; $1 = filename to remove
alias -l sbClient.remove {
  .remove $qt($1-)
  return 1
  :error
  reseterror
  return 0
}
; $1 = filename, $2 = filename to rename as
alias -l sbClient.rename {
  .rename $qt($1) $qt($2)
  return 1
  :error
  reseterror
  return 0
}
alias -l sbClient.loadbuf {
  loadbuf $1-
  return 1
  :error
  reseterror
  return 0
}
alias -l sbClient.mkdir {
  mkdir $qt($1-)
  return 1
  :error
  reseterror
  return 0
}
on *:KEYDOWN:@sbClient.*:*: {
  if ($keyrpt) return

  ; handle bugs in this event that pre 7.11 mIRC's have.
  var %ctrlc = 0, %ctrlz = 0
  if (($keyval == 3) || (($keyval == 67) && ($mouse.key == 2))) var %ctrlc = 1
  if (($keyval == 26) || (($keyval == 90) && ($mouse.key == 2))) var %ctrlz = 1

  if (%ctrlc || %ctrlz) {
    ; ctrl-c or ctrl-z
    ; ctrl-z copies the whole line.
    ; ctrl-c copies the line upto the end of the filename (only works with known file types)
    var %t = $sline($active,0), %cnter = 1
    if (!%t) return
    clipboard
    while ($sline($active,%cnter) != $null) {
      var %l = $v1
      if ($sbClient.Online(%l)) cline 10 $active $sline($active,%cnter).ln
      else cline 6 $active $sline($active,%cnter).ln
      if (%t == 2) clipboard -an $+($crlf,$iif(!%ctrlc,%l,$sbClient.GetFileName(%l)))
      elseif (%t > 1) clipboard -an $iif(!%ctrlc,%l,$sbClient.GetFileName(%l))
      else clipboard -n $iif(!%ctrlc,%l,$sbClient.GetFileName(%l))
      inc %cnter
    }
    titlebar $active -|- $sline($active,0) line(s) copied to clipboard -|-
  }
}
