#ifndef jzzhDef
#define jzzhDef

library jzzh
	globals
        private real R2s_Real = 0
        private string R2s_S = ""
        private real s2R_R = 0
        private string s2R_Str = ""
        private real R2B_Real = 0
        private string R2B_S = ""
        private real B2R_R = 0
        private string B2R_Str = ""
        private string BB2S_Str = ""
        private string BB2S_SS = ""
        private string SS2B_Str = ""
        private string SS2B_BB = ""
	endglobals
    function F_R2s takes nothing returns nothing
        local integer js = 1
        set R2s_S = ""
        loop
            exitwhen js > 3
            set R2s_S = LoadStr(udg_H_zifuji, 3, R2I(ModuloReal(R2s_Real, 92)))+ R2s_S
            set R2s_Real = I2R(R2I(R2s_Real / 92))
            set js = js + 1
        endloop
    endfunction
    //将10进制实数转换为3字节92进制的字符串,最大实数为778687
    function R2s takes real R returns string
        set R2s_Real = RMaxBJ(R, 0)
        call ExecuteFunc ("F_R2s")
        return R2s_S
    endfunction
    function F_s2R takes nothing returns nothing
        local integer js1 = 1
        local integer js2
        local string s
        set s2R_R = 0
        loop
            exitwhen js1 > 3
            set js2 = 0
            loop
                exitwhen js2 > 91
                set s = SubStringBJ(s2R_Str, 4 - js1, 4 - js1)
                if(LoadStr(udg_H_zifuji, 3, js2)==s)then
                    set s2R_R = s2R_R + I2R(js2)*(Pow(92, (js1 - 1)))
                    set js2 = 92
                else
                    set js2 = js2 + 1
                endif
            endloop
            set js1 = js1 + 1
        endloop
    endfunction
    //将3字节92进制的字符串转换为10进制实数
    function s2R takes string S returns real
        set s2R_Str = S
        call ExecuteFunc ("F_s2R")
        return s2R_R
    endfunction
    function F_R2B takes nothing returns nothing
        local integer js = 1
        set R2B_S = ""
        loop
            exitwhen js > 19
            set R2B_S = LoadStr(udg_H_zifuji, 2, R2I(ModuloReal(R2B_Real, 2)))+ R2B_S
            set R2B_Real = I2R(R2I(R2B_Real / 2))
            set js = js + 1
        endloop
    endfunction
    //将10进制实数转换为19字节2进制的字符串
    function R2B takes real R returns string
        set R2B_Real = RMaxBJ(R, 0)
        call ExecuteFunc ("F_R2B")
        return R2B_S
    endfunction
    function F_B2R takes nothing returns nothing
        local integer js = 1
        set B2R_R = 0
        loop
            exitwhen js > 19
            if(SubStringBJ(B2R_Str, 20 - js, 20 - js)=="1")then
                set B2R_R = B2R_R + (Pow(2, (js - 1)))
            endif
            set js = js + 1
        endloop
    endfunction
    //将19字节2进制的字符串转换为10进制实数
    function B2R takes string S returns real
        set B2R_Str = S
        call ExecuteFunc ("F_B2R")
        return B2R_R
    endfunction
    function F_BB2S takes nothing returns nothing
        local string s1 = R2s(B2R(SubStringBJ(BB2S_Str, 1, 19)))
        local string s2 = R2s(B2R(SubStringBJ(BB2S_Str, 20, 38)))
        local string s3 = R2s(B2R(SubStringBJ(BB2S_Str, 39, 57)))
        local string s4 = R2s(B2R(SubStringBJ(BB2S_Str, 58, 76)))
        local string s5 = R2s(B2R(SubStringBJ(BB2S_Str, 77, 95)))
        local string s6 = R2s(B2R(SubStringBJ(BB2S_Str, 96, 114)))
        local string s7 = R2s(B2R(SubStringBJ(BB2S_Str, 115, 133)))
        local string s8 = R2s(B2R(SubStringBJ(BB2S_Str, 134, 152)))
        local string s9 = R2s(B2R(SubStringBJ(BB2S_Str, 153, 171)))
        local string s10 = R2s(B2R(SubStringBJ(BB2S_Str, 172, 190)))
        local string s11 = R2s(B2R(SubStringBJ(BB2S_Str, 191, 209)))
        local string s12 = R2s(B2R(SubStringBJ(BB2S_Str, 210, 228)))
        local string s13 = R2s(B2R(SubStringBJ(BB2S_Str, 229, 247)))
        local string s14 = R2s(B2R(SubStringBJ(BB2S_Str, 248, 266)))
        local string s15 = R2s(B2R(SubStringBJ(BB2S_Str, 267, 285)))
        local string s16 = R2s(B2R(SubStringBJ(BB2S_Str, 286, 304)))
        local string s17 = R2s(B2R(SubStringBJ(BB2S_Str, 305, 323)))
        local string s18 = R2s(B2R(SubStringBJ(BB2S_Str, 324, 342)))
        local string s19 = R2s(B2R(SubStringBJ(BB2S_Str, 343, 361)))
        local string s20 = R2s(B2R(SubStringBJ(BB2S_Str, 362, 380)))
        local string s21 = R2s(B2R(SubStringBJ(BB2S_Str, 381, 399)))
        set BB2S_SS = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10 + s11 + s12 + s13 + s14 + s15 + s16 + s17 + s18 + s19 + s20 + s21
    endfunction
    //将399字节2进制的字符串转换为可以存到服务器存档的63字节92进制字符串
    function BB2S takes string S returns string
        set BB2S_Str = S
        call ExecuteFunc ("F_BB2S")
        return BB2S_SS
    endfunction
    function F_SS2B takes nothing returns nothing
        local string s1 = R2B(s2R(SubStringBJ(SS2B_Str, 1, 3)))
        local string s2 = R2B(s2R(SubStringBJ(SS2B_Str, 4, 6)))
        local string s3 = R2B(s2R(SubStringBJ(SS2B_Str, 7, 9)))
        local string s4 = R2B(s2R(SubStringBJ(SS2B_Str, 10, 12)))
        local string s5 = R2B(s2R(SubStringBJ(SS2B_Str, 13, 15)))
        local string s6 = R2B(s2R(SubStringBJ(SS2B_Str, 16, 18)))
        local string s7 = R2B(s2R(SubStringBJ(SS2B_Str, 19, 21)))
        local string s8 = R2B(s2R(SubStringBJ(SS2B_Str, 22, 24)))
        local string s9 = R2B(s2R(SubStringBJ(SS2B_Str, 25, 27)))
        local string s10 = R2B(s2R(SubStringBJ(SS2B_Str, 28, 30)))
        local string s11 = R2B(s2R(SubStringBJ(SS2B_Str, 31, 33)))
        local string s12 = R2B(s2R(SubStringBJ(SS2B_Str, 34, 36)))
        local string s13 = R2B(s2R(SubStringBJ(SS2B_Str, 37, 39)))
        local string s14 = R2B(s2R(SubStringBJ(SS2B_Str, 40, 42)))
        local string s15 = R2B(s2R(SubStringBJ(SS2B_Str, 43, 45)))
        local string s16 = R2B(s2R(SubStringBJ(SS2B_Str, 46, 48)))
        local string s17 = R2B(s2R(SubStringBJ(SS2B_Str, 49, 51)))
        local string s18 = R2B(s2R(SubStringBJ(SS2B_Str, 52, 54)))
        local string s19 = R2B(s2R(SubStringBJ(SS2B_Str, 55, 57)))
        local string s20 = R2B(s2R(SubStringBJ(SS2B_Str, 58, 60)))
        local string s21 = R2B(s2R(SubStringBJ(SS2B_Str, 61, 63)))
        set SS2B_BB = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10 + s11 + s12 + s13 + s14 + s15 + s16 + s17 + s18 + s19 + s20 + s21
    endfunction
    //将63字节92进制的字符串转换为399字节2进制字符串
    function SS2B takes string S returns string
        set SS2B_Str = S
        call ExecuteFunc ("F_SS2B")
        return SS2B_BB
    endfunction
endlibrary

#endif
