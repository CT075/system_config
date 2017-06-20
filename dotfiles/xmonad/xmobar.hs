
Config { font = "-*-Fixed-Bold-R-Normal-*-13-*-*-*-*-*-*-*"
       , borderColor = "black"
       , border = TopB
       , bgColor = "black"
       , fgColor = "grey"
       , position = TopW L 100
       , commands = [ Run Cpu [ "-L", "10", "-H", "50", "--normal", "green", "--high", "red" ] 10
                    , Run Network "wlp2s0" [ "-L", "3", "-H", "32", "--normal", "green", "--high", "red" ] 10
                    , Run Memory [ "-t", "Mem: <usedratio>%" ] 10
                    , Run Battery [ "-t", "<acstatus>: <left>% - <timeleft>"
                                  , "--"
                                  , "-O", "AC"
                                  , "-o", "Bat"
                                  , "-h", "green"
                                  , "-l", "red"
                                  ] 10
                    , Run Com "date" ["+%a %Y %b %d -- %H:%M:%S"] "mydate" 10
                    , Run Com "whoami" [] "" 100
                    , Run Com "hostname" [] "" 100
                    , Run StdinReader
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%StdinReader% | %cpu% | %memory% }{<fc=#ee9a00>%mydate%</fc> | %battery% | %wlp2s0% | %whoami%@%hostname%"
       , overrideRedirect = False
       , lowerOnStart = False
       , hideOnStart = False
       , allDesktops = True
       , persistent = True
       }

