#ifndef Gb2312Def
#define Gb2312Def

library Gb2312 requires YDWEBase
    globals
        private string S = ""
        private string St = ""
        private string I
    endglobals
    function F_S2G takes nothing returns nothing
        local string i
        set I = ""
        loop
            exitwhen StringLength(St)< 1
            set S = SubStringBJ(St, 1, 3)
            //call BJDebugMsg( S)
            if(HaveSavedValue(StringHashBJ(S), bj_HASHTABLE_INTEGER, 1, udg_H_zifuji)==true)then
    if(LoadInteger(udg_H_zifuji, 1, StringHashBJ(S))< 100)then
                    set I = I + "00" + I2S(LoadInteger(udg_H_zifuji, 1, StringHashBJ(S)))
    else
                    if(LoadInteger(udg_H_zifuji, 1, StringHashBJ(S))< 1000)then
                        set I = I + "0" + I2S(LoadInteger(udg_H_zifuji, 1, StringHashBJ(S)))
                    else
                        set I = I + I2S(LoadInteger(udg_H_zifuji, 1, StringHashBJ(S)))
                    endif
    endif
    set St = SubStringBJ(St, 4, StringLength(St))
            else
    set S = SubStringBJ(St, 1, 2)
    if(HaveSavedValue(StringHashBJ(S), bj_HASHTABLE_INTEGER, 1, udg_H_zifuji)==true)then
                    if(LoadInteger(udg_H_zifuji, 1, StringHashBJ(S))< 100)then
                        set I = I + "00" + I2S(LoadInteger(udg_H_zifuji, 1, StringHashBJ(S)))
                    else
                        set I = I + "0" + I2S(LoadInteger(udg_H_zifuji, 1, StringHashBJ(S)))
                    endif
                    set St = SubStringBJ(St, 3, StringLength(St))
    else
                    set S = SubStringBJ(St, 1, 1)
                    set i = "0000"
                    if(S=="~") then
                        set i = "0001"
                    else
                        if(S=="!") then
                            set i = "0002"
                        else
                            if(S=="\"") then
                                set i = "0003"
                            else
                                if(S=="#") then
                                    set i = "0004"
                                else
                                    if(S=="$") then
                                        set i = "0005"
                                    else
                                        if(S=="%") then
                                            set i = "0006"
                                        else
                                            if(S=="&") then
                                                set i = "0007"
                                            else
                                                if(S=="'") then
                                                    set i = "0008"
                                                else
                                                    if(S==")") then
                                                        set i = "0009"
                                                    else
                                                        if(S=="(") then
                                                            set i = "0010"
                                                        else
                                                            if(S=="*") then
                                                                set i = "0011"
                                                            else
                                                                if(S=="+") then
                                                                    set i = "0012"
                                                                else
                                                                    if(S==".") then
                                                                        set i = "0013"
                                                                    else
                                                                        if(S=="-") then
                                                                            set i = "0014"
                                                                        else
                                                                            if(S==",") then
                                                                                set i = "0015"
                                                                            else
                                                                                if(S=="/") then
                                                                                    set i = "0016"
                                                                                else
                                                                                    if(S=="0") then
                                                                                        set i = "0017"
                                                                                    else
                                                                                        if(S=="1") then
                                                                                            set i = "0018"
                                                                                        else
                                                                                            if(S=="2") then
                                                                                                set i = "0019"
                                                                                            else
                                                                                                if(S=="3") then
                                                                                                    set i = "0020"
                                                                                                else
                                                                                                    if(S=="4") then
                                                                                                        set i = "0021"
                                                                                                    else
                                                                                                        if(S=="5") then
                                                                                                            set i = "0022"
                                                                                                        else
                                                                                                            if(S=="6") then
                                                                                                                set i = "0023"
                                                                                                            else
                                                                                                                if(S=="7") then
                                                                                                                    set i = "0024"
                                                                                                                else
                                                                                                                    if(S=="8") then
                                                                                                                        set i = "0025"
                                                                                                                    else
                                                                                                                        if(S=="9") then
                                                                                                                            set i = "0026"
                                                                                                                        else
                                                                                                                            if(S==":") then
                                                                                                                                set i = "0027"
                                                                                                                            else
                                                                                                                                if(S==";") then
                                                                                                                                    set i = "0028"
                                                                                                                                else
                                                                                                                                    if(S=="<") then
                                                                                                                                        set i = "0029"
                                                                                                                                    else
                                                                                                                                        if(S=="=") then
                                                                                                                                            set i = "0030"
                                                                                                                                        else
                                                                                                                                            if(S==">") then
                                                                                                                                                set i = "0031"
                                                                                                                                            else
                                                                                                                                                if(S=="?") then
                                                                                                                                                    set i = "0032"
                                                                                                                                                else
                                                                                                                                                    if(S=="@") then
                                                                                                                                                        set i = "0033"
                                                                                                                                                    else
                                                                                                                                                        if(S=="A") then
                                                                                                                                                            set i = "0034"
                                                                                                                                                        else
                                                                                                                                                            if(S=="B") then
                                                                                                                                                                set i = "0035"
                                                                                                                                                            else
                                                                                                                                                                if(S=="C") then
                                                                                                                                                                    set i = "0036"
                                                                                                                                                                else
                                                                                                                                                                    if(S=="D") then
                                                                                                                                                                        set i = "0037"
                                                                                                                                                                    else
                                                                                                                                                                        if(S=="E") then
                                                                                                                                                                            set i = "0038"
                                                                                                                                                                        else
                                                                                                                                                                            if(S=="F") then
                                                                                                                                                                                set i = "0039"
                                                                                                                                                                            else
                                                                                                                                                                                if(S=="G") then
                                                                                                                                                                                    set i = "0040"
                                                                                                                                                                                endif
                                                                                                                                                                            endif
                                                                                                                                                                        endif
                                                                                                                                                                    endif
                                                                                                                                                                endif
                                                                                                                                                            endif
                                                                                                                                                        endif
                                                                                                                                                    endif
                                                                                                                                                endif
                                                                                                                                            endif
                                                                                                                                        endif
                                                                                                                                    endif
                                                                                                                                endif
                                                                                                                            endif
                                                                                                                        endif
                                                                                                                    endif
                                                                                                                endif
                                                                                                            endif
                                                                                                        endif
                                                                                                    endif
                                                                                                endif
                                                                                            endif
                                                                                        endif
                                                                                    endif
                                                                                endif
                                                                            endif
                                                                        endif
                                                                    endif
                                                                endif
                                                            endif
                                                        endif
                                                    endif
                                                endif
                                            endif
                                        endif
                                    endif
                                endif
                            endif
                        endif
                    endif
                    if(i=="0000")then
                        if(S=="H") then
                            set i = "0041"
                        else
                            if(S=="I") then
                                set i = "0042"
                            else
                                if(S=="J") then
                                    set i = "0043"
                                else
                                    if(S=="K") then
                                        set i = "0044"
                                    else
                                        if(S=="L") then
                                            set i = "0045"
                                        else
                                            if(S=="M") then
                                                set i = "0046"
                                            else
                                                if(S=="N") then
                                                    set i = "0047"
                                                else
                                                    if(S=="O") then
                                                        set i = "0048"
                                                    else
                                                        if(S=="P") then
                                                            set i = "0049"
                                                        else
                                                            if(S=="Q") then
                                                                set i = "0050"
                                                            else
                                                                if(S=="R") then
                                                                    set i = "0051"
                                                                else
                                                                    if(S=="S") then
                                                                        set i = "0052"
                                                                    else
                                                                        if(S=="T") then
                                                                            set i = "0053"
                                                                        else
                                                                            if(S=="U") then
                                                                                set i = "0054"
                                                                            else
                                                                                if(S=="V") then
                                                                                    set i = "0055"
                                                                                else
                                                                                    if(S=="W") then
                                                                                        set i = "0056"
                                                                                    else
                                                                                        if(S=="X") then
                                                                                            set i = "0057"
                                                                                        else
                                                                                            if(S=="Y") then
                                                                                                set i = "0058"
                                                                                            else
                                                                                                if(S=="Z") then
                                                                                                    set i = "0059"
                                                                                                else
                                                                                                    if(S=="[") then
                                                                                                        set i = "0060"
                                                                                                    else
                                                                                                        if(S=="\\") then
                                                                                                            set i = "0061"
                                                                                                        else
                                                                                                            if(S=="]") then
                                                                                                                set i = "0062"
                                                                                                            else
                                                                                                                if(S=="^") then
                                                                                                                    set i = "0063"
                                                                                                                else
                                                                                                                    if(S=="_") then
                                                                                                                        set i = "0064"
                                                                                                                    else
                                                                                                                        if(S=="`") then
                                                                                                                            set i = "0065"
                                                                                                                        else
                                                                                                                            if(S=="a") then
                                                                                                                                set i = "0066"
                                                                                                                            else
                                                                                                                                if(S=="b") then
                                                                                                                                    set i = "0067"
                                                                                                                                else
                                                                                                                                    if(S=="c") then
                                                                                                                                        set i = "0068"
                                                                                                                                    else
                                                                                                                                        if(S=="d") then
                                                                                                                                            set i = "0069"
                                                                                                                                        else
                                                                                                                                            if(S=="e") then
                                                                                                                                                set i = "0070"
                                                                                                                                            else
                                                                                                                                                if(S=="f") then
                                                                                                                                                    set i = "0071"
                                                                                                                                                else
                                                                                                                                                    if(S=="g") then
                                                                                                                                                        set i = "0072"
                                                                                                                                                    else
                                                                                                                                                        if(S=="h") then
                                                                                                                                                            set i = "0073"
                                                                                                                                                        else
                                                                                                                                                            if(S=="i") then
                                                                                                                                                                set i = "0074"
                                                                                                                                                            else
                                                                                                                                                                if(S=="j") then
                                                                                                                                                                    set i = "0075"
                                                                                                                                                                else
                                                                                                                                                                    if(S=="k") then
                                                                                                                                                                        set i = "0076"
                                                                                                                                                                    else
                                                                                                                                                                        if(S=="l") then
                                                                                                                                                                            set i = "0077"
                                                                                                                                                                        else
                                                                                                                                                                            if(S=="m") then
                                                                                                                                                                                set i = "0078"
                                                                                                                                                                            else
                                                                                                                                                                                if(S=="n") then
                                                                                                                                                                                    set i = "0079"
                                                                                                                                                                                else
                                                                                                                                                                                    if(S=="o") then
                                                                                                                                                                                        set i = "0080"
                                                                                                                                                                                    endif
                                                                                                                                                                                endif
                                                                                                                                                                            endif
                                                                                                                                                                        endif
                                                                                                                                                                    endif
                                                                                                                                                                endif
                                                                                                                                                            endif
                                                                                                                                                        endif
                                                                                                                                                    endif
                                                                                                                                                endif
                                                                                                                                            endif
                                                                                                                                        endif
                                                                                                                                    endif
                                                                                                                                endif
                                                                                                                            endif
                                                                                                                        endif
                                                                                                                    endif
                                                                                                                endif
                                                                                                            endif
                                                                                                        endif
                                                                                                    endif
                                                                                                endif
                                                                                            endif
                                                                                        endif
                                                                                    endif
                                                                                endif
                                                                            endif
                                                                        endif
                                                                    endif
                                                                endif
                                                            endif
                                                        endif
                                                    endif
                                                endif
                                            endif
                                        endif
                                    endif
                                endif
                            endif
                        endif
                    endif
                    if(i=="0000")then
                        if(S=="p") then
                            set i = "0081"
                        else
                            if(S=="q") then
                                set i = "0082"
                            else
                                if(S=="r") then
                                    set i = "0083"
                                else
                                    if(S=="s") then
                                        set i = "0084"
                                    else
                                        if(S=="t") then
                                            set i = "0085"
                                        else
                                            if(S=="u") then
                                                set i = "0086"
                                            else
                                                if(S=="v") then
                                                    set i = "0087"
                                                else
                                                    if(S=="w") then
                                                        set i = "0088"
                                                    else
                                                        if(S=="x") then
                                                            set i = "0089"
                                                        else
                                                            if(S=="y") then
                                                                set i = "0090"
                                                            else
                                                                if(S=="z") then
                                                                    set i = "0091"
                                                                else
                                                                    if(S=="{") then
                                                                        set i = "0092"
                                                                    else
                                                                        if(S=="|") then
                                                                            set i = "0093"
                                                                        else
                                                                            if(S=="}") then
                                                                                set i = "0094"
                                                                            else
                                                                                if(S==" ") then
                                                                                    set i = "0095"
                                                                                else
                                                                                    set i = "0000"
                                                                                endif
                                                                            endif
                                                                        endif
                                                                    endif
                                                                endif
                                                            endif
                                                        endif
                                                    endif
                                                endif
                                            endif
                                        endif
                                    endif
                                endif
                            endif
                        endif
                    endif
                    set I = I + i
                    set St = SubStringBJ(St, 2, StringLength(St))
    endif
            endif
        endloop
    endfunction
    function S2G takes string Str returns string
        set St = Str
        call ExecuteFunc ("F_S2G")
        return I
    endfunction
    function G2S takes string Str returns string
        local string Gb = Str
        local string SS = ""
        loop
            exitwhen StringLength(Gb)< 4
            set SS = SS + LoadStr(udg_H_zifuji, 0, S2I(SubStringBJ(Gb, 1, 4)))
            set Gb = SubStringBJ(Gb, 5, StringLength(Gb))
        endloop
        return SS
    endfunction
    function Gb2312_Init takes nothing returns nothing
        set udg_H_zifuji = YDWEInitHashtable()
        call SaveStr(udg_H_zifuji, 0, 0, "")
        call SaveStr(udg_H_zifuji, 0, 1, "~")
        call SaveStr(udg_H_zifuji, 0, 2, "!")
        call SaveStr(udg_H_zifuji, 0, 3, "\"")
        call SaveStr(udg_H_zifuji, 0, 4, "#")
        call SaveStr(udg_H_zifuji, 0, 5, "$")
        call SaveStr(udg_H_zifuji, 0, 6, "%")
        call SaveStr(udg_H_zifuji, 0, 7, "&")
        call SaveStr(udg_H_zifuji, 0, 8, "'")
        call SaveStr(udg_H_zifuji, 0, 9, ")")
        call SaveStr(udg_H_zifuji, 0, 10, "(")
        call SaveStr(udg_H_zifuji, 0, 11, "*")
        call SaveStr(udg_H_zifuji, 0, 12, "+")
        call SaveStr(udg_H_zifuji, 0, 13, ".")
        call SaveStr(udg_H_zifuji, 0, 14, "-")
        call SaveStr(udg_H_zifuji, 0, 15, ",")
        call SaveStr(udg_H_zifuji, 0, 16, "/")
        call SaveStr(udg_H_zifuji, 0, 17, "0")
        call SaveStr(udg_H_zifuji, 0, 18, "1")
        call SaveStr(udg_H_zifuji, 0, 19, "2")
        call SaveStr(udg_H_zifuji, 0, 20, "3")
        call SaveStr(udg_H_zifuji, 0, 21, "4")
        call SaveStr(udg_H_zifuji, 0, 22, "5")
        call SaveStr(udg_H_zifuji, 0, 23, "6")
        call SaveStr(udg_H_zifuji, 0, 24, "7")
        call SaveStr(udg_H_zifuji, 0, 25, "8")
        call SaveStr(udg_H_zifuji, 0, 26, "9")
        call SaveStr(udg_H_zifuji, 0, 27, ":")
        call SaveStr(udg_H_zifuji, 0, 28, ";")
        call SaveStr(udg_H_zifuji, 0, 29, "<")
        call SaveStr(udg_H_zifuji, 0, 30, "=")
        call SaveStr(udg_H_zifuji, 0, 31, ">")
        call SaveStr(udg_H_zifuji, 0, 32, "?")
        call SaveStr(udg_H_zifuji, 0, 33, "@")
        call SaveStr(udg_H_zifuji, 0, 34, "A")
        call SaveStr(udg_H_zifuji, 0, 35, "B")
        call SaveStr(udg_H_zifuji, 0, 36, "C")
        call SaveStr(udg_H_zifuji, 0, 37, "D")
        call SaveStr(udg_H_zifuji, 0, 38, "E")
        call SaveStr(udg_H_zifuji, 0, 39, "F")
        call SaveStr(udg_H_zifuji, 0, 40, "G")
        call SaveStr(udg_H_zifuji, 0, 41, "H")
        call SaveStr(udg_H_zifuji, 0, 42, "I")
        call SaveStr(udg_H_zifuji, 0, 43, "J")
        call SaveStr(udg_H_zifuji, 0, 44, "K")
        call SaveStr(udg_H_zifuji, 0, 45, "L")
        call SaveStr(udg_H_zifuji, 0, 46, "M")
        call SaveStr(udg_H_zifuji, 0, 47, "N")
        call SaveStr(udg_H_zifuji, 0, 48, "O")
        call SaveStr(udg_H_zifuji, 0, 49, "P")
        call SaveStr(udg_H_zifuji, 0, 50, "Q")
        call SaveStr(udg_H_zifuji, 0, 51, "R")
        call SaveStr(udg_H_zifuji, 0, 52, "S")
        call SaveStr(udg_H_zifuji, 0, 53, "T")
        call SaveStr(udg_H_zifuji, 0, 54, "U")
        call SaveStr(udg_H_zifuji, 0, 55, "V")
        call SaveStr(udg_H_zifuji, 0, 56, "W")
        call SaveStr(udg_H_zifuji, 0, 57, "X")
        call SaveStr(udg_H_zifuji, 0, 58, "Y")
        call SaveStr(udg_H_zifuji, 0, 59, "Z")
        call SaveStr(udg_H_zifuji, 0, 60, "[")
        call SaveStr(udg_H_zifuji, 0, 61, "\\")
        call SaveStr(udg_H_zifuji, 0, 62, "]")
        call SaveStr(udg_H_zifuji, 0, 63, "^")
        call SaveStr(udg_H_zifuji, 0, 64, "_")
        call SaveStr(udg_H_zifuji, 0, 65, "`")
        call SaveStr(udg_H_zifuji, 0, 66, "a")
        call SaveStr(udg_H_zifuji, 0, 67, "b")
        call SaveStr(udg_H_zifuji, 0, 68, "c")
        call SaveStr(udg_H_zifuji, 0, 69, "d")
        call SaveStr(udg_H_zifuji, 0, 70, "e")
        call SaveStr(udg_H_zifuji, 0, 71, "f")
        call SaveStr(udg_H_zifuji, 0, 72, "g")
        call SaveStr(udg_H_zifuji, 0, 73, "h")
        call SaveStr(udg_H_zifuji, 0, 74, "i")
        call SaveStr(udg_H_zifuji, 0, 75, "j")
        call SaveStr(udg_H_zifuji, 0, 76, "k")
        call SaveStr(udg_H_zifuji, 0, 77, "l")
        call SaveStr(udg_H_zifuji, 0, 78, "m")
        call SaveStr(udg_H_zifuji, 0, 79, "n")
        call SaveStr(udg_H_zifuji, 0, 80, "o")
        call SaveStr(udg_H_zifuji, 0, 81, "p")
        call SaveStr(udg_H_zifuji, 0, 82, "q")
        call SaveStr(udg_H_zifuji, 0, 83, "r")
        call SaveStr(udg_H_zifuji, 0, 84, "s")
        call SaveStr(udg_H_zifuji, 0, 85, "t")
        call SaveStr(udg_H_zifuji, 0, 86, "u")
        call SaveStr(udg_H_zifuji, 0, 87, "v")
        call SaveStr(udg_H_zifuji, 0, 88, "w")
        call SaveStr(udg_H_zifuji, 0, 89, "x")
        call SaveStr(udg_H_zifuji, 0, 90, "y")
        call SaveStr(udg_H_zifuji, 0, 91, "z")
        call SaveStr(udg_H_zifuji, 0, 92, "{")
        call SaveStr(udg_H_zifuji, 0, 93, "|")
        call SaveStr(udg_H_zifuji, 0, 94, "}")
        call SaveStr(udg_H_zifuji, 0, 95, "Λ")
        call SaveStr(udg_H_zifuji, 0, 96, "·")
        call SaveStr(udg_H_zifuji, 0, 97, "ˉ")
        call SaveStr(udg_H_zifuji, 0, 98, "ˇ")
        call SaveStr(udg_H_zifuji, 0, 99, "¨")
        call SaveStr(udg_H_zifuji, 0, 100, "Α")
        call SaveStr(udg_H_zifuji, 0, 101, "Β")
        call SaveStr(udg_H_zifuji, 0, 102, "Γ")
        call SaveStr(udg_H_zifuji, 0, 103, "Δ")
        call SaveStr(udg_H_zifuji, 0, 104, "Ε")
        call SaveStr(udg_H_zifuji, 0, 105, "Ζ")
        call SaveStr(udg_H_zifuji, 0, 106, "Η")
        call SaveStr(udg_H_zifuji, 0, 107, "Θ")
        call SaveStr(udg_H_zifuji, 0, 108, "Ι")
        call SaveStr(udg_H_zifuji, 0, 109, "Κ")
        call SaveStr(udg_H_zifuji, 0, 110, " ")
        call SaveStr(udg_H_zifuji, 0, 111, "Μ")
        call SaveStr(udg_H_zifuji, 0, 112, "Ν")
        call SaveStr(udg_H_zifuji, 0, 113, "Ξ")
        call SaveStr(udg_H_zifuji, 0, 114, "Ο")
        call SaveStr(udg_H_zifuji, 0, 115, "Π")
        call SaveStr(udg_H_zifuji, 0, 116, "Ρ")
        call SaveStr(udg_H_zifuji, 0, 117, "Σ")
        call SaveStr(udg_H_zifuji, 0, 118, "Τ")
        call SaveStr(udg_H_zifuji, 0, 119, "Υ")
        call SaveStr(udg_H_zifuji, 0, 120, "Φ")
        call SaveStr(udg_H_zifuji, 0, 121, "Χ")
        call SaveStr(udg_H_zifuji, 0, 122, "Ψ")
        call SaveStr(udg_H_zifuji, 0, 123, "Ω")
        call SaveStr(udg_H_zifuji, 0, 124, "α")
        call SaveStr(udg_H_zifuji, 0, 125, "β")
        call SaveStr(udg_H_zifuji, 0, 126, "γ")
        call SaveStr(udg_H_zifuji, 0, 127, "δ")
        call SaveStr(udg_H_zifuji, 0, 128, "ε")


        call SaveStr(udg_H_zifuji, 2, 0, "0")
        call SaveStr(udg_H_zifuji, 2, 1, "1")
        call SaveStr(udg_H_zifuji, 3, 0, "~")
        call SaveStr(udg_H_zifuji, 3, 1, "!")
        call SaveStr(udg_H_zifuji, 3, 2, "@")
        call SaveStr(udg_H_zifuji, 3, 3, "#")
        call SaveStr(udg_H_zifuji, 3, 4, "$")
        call SaveStr(udg_H_zifuji, 3, 5, "%")
        call SaveStr(udg_H_zifuji, 3, 6, "^")
        call SaveStr(udg_H_zifuji, 3, 7, "&")
        call SaveStr(udg_H_zifuji, 3, 8, "*")
        call SaveStr(udg_H_zifuji, 3, 9, "(")
        call SaveStr(udg_H_zifuji, 3, 10, ")")
        call SaveStr(udg_H_zifuji, 3, 11, "_")
        call SaveStr(udg_H_zifuji, 3, 12, "+")
        call SaveStr(udg_H_zifuji, 3, 13, "Q")
        call SaveStr(udg_H_zifuji, 3, 14, "W")
        call SaveStr(udg_H_zifuji, 3, 15, "E")
        call SaveStr(udg_H_zifuji, 3, 16, "R")
        call SaveStr(udg_H_zifuji, 3, 17, "T")
        call SaveStr(udg_H_zifuji, 3, 18, "Y")
        call SaveStr(udg_H_zifuji, 3, 19, "U")
        call SaveStr(udg_H_zifuji, 3, 20, "I")
        call SaveStr(udg_H_zifuji, 3, 21, "O")
        call SaveStr(udg_H_zifuji, 3, 22, "P")
        call SaveStr(udg_H_zifuji, 3, 23, "{")
        call SaveStr(udg_H_zifuji, 3, 24, "}")
        call SaveStr(udg_H_zifuji, 3, 25, "|")
        call SaveStr(udg_H_zifuji, 3, 26, "A")
        call SaveStr(udg_H_zifuji, 3, 27, "S")
        call SaveStr(udg_H_zifuji, 3, 28, "D")
        call SaveStr(udg_H_zifuji, 3, 29, "F")
        call SaveStr(udg_H_zifuji, 3, 30, "G")
        call SaveStr(udg_H_zifuji, 3, 31, "H")
        call SaveStr(udg_H_zifuji, 3, 32, "J")
        call SaveStr(udg_H_zifuji, 3, 33, "K")
        call SaveStr(udg_H_zifuji, 3, 34, "L")
        call SaveStr(udg_H_zifuji, 3, 35, ":")
        call SaveStr(udg_H_zifuji, 3, 36, "Z")
        call SaveStr(udg_H_zifuji, 3, 37, "X")
        call SaveStr(udg_H_zifuji, 3, 38, "C")
        call SaveStr(udg_H_zifuji, 3, 39, "V")
        call SaveStr(udg_H_zifuji, 3, 40, "B")
        call SaveStr(udg_H_zifuji, 3, 41, "N")
        call SaveStr(udg_H_zifuji, 3, 42, "M")
        call SaveStr(udg_H_zifuji, 3, 43, "<")
        call SaveStr(udg_H_zifuji, 3, 44, ">")
        call SaveStr(udg_H_zifuji, 3, 45, "?")
        call SaveStr(udg_H_zifuji, 3, 46, "`")
        call SaveStr(udg_H_zifuji, 3, 47, "1")
        call SaveStr(udg_H_zifuji, 3, 48, "2")
        call SaveStr(udg_H_zifuji, 3, 49, "3")
        call SaveStr(udg_H_zifuji, 3, 50, "4")
        call SaveStr(udg_H_zifuji, 3, 51, "5")
        call SaveStr(udg_H_zifuji, 3, 52, "6")
        call SaveStr(udg_H_zifuji, 3, 53, "7")
        call SaveStr(udg_H_zifuji, 3, 54, "8")
        call SaveStr(udg_H_zifuji, 3, 55, "9")
        call SaveStr(udg_H_zifuji, 3, 56, "0")
        call SaveStr(udg_H_zifuji, 3, 57, "-")
        call SaveStr(udg_H_zifuji, 3, 58, "=")
        call SaveStr(udg_H_zifuji, 3, 59, "q")
        call SaveStr(udg_H_zifuji, 3, 60, "w")
        call SaveStr(udg_H_zifuji, 3, 61, "e")
        call SaveStr(udg_H_zifuji, 3, 62, "r")
        call SaveStr(udg_H_zifuji, 3, 63, "t")
        call SaveStr(udg_H_zifuji, 3, 64, "y")
        call SaveStr(udg_H_zifuji, 3, 65, "u")
        call SaveStr(udg_H_zifuji, 3, 66, "i")
        call SaveStr(udg_H_zifuji, 3, 67, "o")
        call SaveStr(udg_H_zifuji, 3, 68, "p")
        call SaveStr(udg_H_zifuji, 3, 69, "[")
        call SaveStr(udg_H_zifuji, 3, 70, "]")
        call SaveStr(udg_H_zifuji, 3, 71, "a")
        call SaveStr(udg_H_zifuji, 3, 72, "s")
        call SaveStr(udg_H_zifuji, 3, 73, "d")
        call SaveStr(udg_H_zifuji, 3, 74, "f")
        call SaveStr(udg_H_zifuji, 3, 75, "g")
        call SaveStr(udg_H_zifuji, 3, 76, "h")
        call SaveStr(udg_H_zifuji, 3, 77, "j")
        call SaveStr(udg_H_zifuji, 3, 78, "k")
        call SaveStr(udg_H_zifuji, 3, 79, "l")
        call SaveStr(udg_H_zifuji, 3, 80, ";")
        call SaveStr(udg_H_zifuji, 3, 81, "'")
        call SaveStr(udg_H_zifuji, 3, 82, "z")
        call SaveStr(udg_H_zifuji, 3, 83, "x")
        call SaveStr(udg_H_zifuji, 3, 84, "c")
        call SaveStr(udg_H_zifuji, 3, 85, "v")
        call SaveStr(udg_H_zifuji, 3, 86, "b")
        call SaveStr(udg_H_zifuji, 3, 87, "n")
        call SaveStr(udg_H_zifuji, 3, 88, "m")
        call SaveStr(udg_H_zifuji, 3, 89, ",")
        call SaveStr(udg_H_zifuji, 3, 90, ".")
        call SaveStr(udg_H_zifuji, 3, 91, "/")
    endfunction
endlibrary

#endif
