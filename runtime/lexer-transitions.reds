Red/System [
    Note: "Auto-generated lexical scanner transitions table"
] 
#enum lex-states! [
    S_START 
    S_LINE_CMT 
    S_LINE_STR 
    S_SKIP_STR 
    S_M_STRING 
    S_SKIP_MSTR 
    S_FILE_1ST 
    S_FILE 
    S_FILE_STR 
    S_HDPER_ST 
    S_HERDOC_ST 
    S_HDPER_C0 
    S_HDPER_CL 
    S_SLASH_1ST 
    S_SLASH 
    S_SLASH_N 
    S_SHARP 
    S_BINARY 
    S_LINE_CMT2 
    S_CHAR 
    S_SKIP_CHAR 
    S_CONSTRUCT 
    S_ISSUE 
    S_NUMBER 
    S_DOTNUM 
    S_DECIMAL 
    S_DECEXP 
    S_DECX 
    S_DEC_SPECIAL 
    S_TUPLE 
    S_DATE 
    S_TIME_1ST 
    S_TIME 
    S_PAIR_1ST 
    S_PAIR 
    S_MONEY_1ST 
    S_MONEY 
    S_MONEY_DEC 
    S_INT_HEX 
    S_HEX 
    S_HEX_END 
    S_HEX_END2 
    S_LESSER 
    S_TAG 
    S_TAG_STR 
    S_TAG_STR2 
    S_SIGN 
    S_DOTWORD 
    S_DOTDEC 
    S_WORD_1ST 
    S_WORD 
    S_WORDSET 
    S_PERCENT 
    S_URL 
    S_EMAIL 
    S_REF 
    S_EQUAL 
    S_PATH 
    S_PATH_NUM 
    S_PATH_W1ST 
    S_PATH_WORD 
    S_PATH_SHARP 
    S_PATH_SIGN 
    --EXIT_STATES-- 
    T_EOF 
    T_ERROR 
    T_BLK_OP 
    T_BLK_CL 
    T_PAR_OP 
    T_PAR_CL 
    T_MSTR_OP 
    T_MSTR_CL 
    T_MAP_OP 
    T_PATH 
    T_CONS_MK 
    T_CMT 
    T_COMMA 
    T_STRING 
    T_WORD 
    T_ISSUE 
    T_INTEGER 
    T_REFINE 
    T_CHAR 
    T_FILE 
    T_BINARY 
    T_PERCENT 
    T_FLOAT 
    T_FLOAT_SP 
    T_TUPLE 
    T_DATE 
    T_PAIR 
    T_TIME 
    T_MONEY 
    T_TAG 
    T_URL 
    T_EMAIL 
    T_HEX 
    T_RAWSTRING 
    T_REF
] 
skip-table: #{
0100000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
000000
} 
type-table: #{
000007070707080808080707070F130F1429000A0A00140B0C0C0C0C0C272F2B
2B2525313131000B0F0B2C2C2C2C0F0F0C0F0F100F092D320F190B0F0F140F00
00220000000000070000000000070F140B130A0829260C0C272F252B312C092D
0B0732
} 
transitions: #{
0000171742434445464102103131323232322732270D412A3238064C01372F23
2E2E320041324140014B01010101010101010101010101010101010101010101
0101010101010101010101010101414B024102020202020202024D0202020202
0202020202020202020202020202020202020302020241410202020202020202
0202020202020202020202020202020202020202020202020202020202024141
0404040404040404464704040404040404040404040404040404040404040404
0404050404044141040404040404040404040404040404040404040404040404
040404040404040404040404040441414E4E07074E4E4E4E0A4E080707340707
0707070707070707070709074E4E07070707074E0707414E5353070753535353
5353410707530707070707070707070707070707535307070707070707074153
0841080808080808080853080808080808080808080808080808080808080808
08080808080841414E4E07074E4E4E4E0A4E4E07070707070707070707074E07
070709074E0707070707074E0707414E0A0A0A0A0A0A0A0A0A0B0A0A0A0A0A0A
0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A41410A0A0A0A0A0A0A0A
0A0B0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0C0A0A0A0A0A0A0A0A0A0A0A4141
61614141616161616141614141414141414141414141416141410C4161414141
41414161414141614E4E0E0E4E4E4E4E4E4E4E4E0E330E0E0E0E0E0E0E0F0E0E
0E0E0E414E4E0E0E0E0E0E4E0E0E414E51510E0E515151515151510E0E410E0E
0E0E0E0E0E510E0E0E0E0E4151510E0E0E0E0E510E0E41514E4E32324E4E4E4E
4E4E4E4E3232323232323232320F3232323241414E4E32413232324E3232414E
414116161541484111411316164116161616161616161641411616414F4F1616
1616164F1616414F111111114141414141544141414111111111111111114141
4111414112414141114141414111414112111212121212121212121212121212
1212121212121212121212121212121212121212121241411313131313131313
1313521313131313131313131313131313131313131313131313141313134141
1313131313131313131313131313131313131313131313131313131313131313
131313131313414115151515154A151515151515151515151515151515151515
151515151515151515151515151541414F4F16164F4F4F4F4F4F4F1616411616
1616161616411616161616164F4F16161616164F1616414F5050171750505050
50505010171F211E291A1B41261E41504141555050361841411E415041414150
56561919565656565656561C19412141411A1A41415641564141555656414141
414141564141415656561919565656565656564119562141411A1A4141564156
4141555656361D41414141564141415656561A1A565656565656564141564141
414141414156415641414156563641411A1A41564141415656561B1B56565656
565656414156414129412741275641564141555641361D411A1A415641414156
57575657575757575757574141411C1C1C1C1C1C1C5757571C1C415757411C41
1C1C41571C1C415758581D1D5858585858585841415841414141414141584158
4141414158411D41414141584141415859591E1E595959595959591E1E1E1E1E
1E1E1E1E1E1E1E591E1E414159411E591E1E4159411E41594141202041414141
4141414141414141414141414141414141414141414141414141414141414141
5B5B20205B5B5B5B5B5B5B414120414141414141415B415B414141415B412041
4141415B4141415B414122224141414141414141414141414141414141414141
414141414136414122224141414141415A5A22225A5A5A5A5A5A5A41415A4141
41222241415A415A414141415A3622414141415A4141415A4141242441414141
4141414141414141414141414141414141414141414141414141414141414141
5C5C24245C5C5C5C5C5C5C5C245C414141414141415C415C414141415C412541
4141415C4141415C5C5C25255C5C5C5C5C5C5C5C255C414141414141415C415C
414141415C4141414141415C4141415C41412626414141414141414141414141
2841264126414141414141414136414141414141414141414E4E27274E4E4E4E
4E4E4E4E323332322832273227494E32323241414E3632243232324E3232414E
6060323260606060606060413233323232323232324960323232414160363224
3232326032324160606041416060606060606041414141414141414141496060
414141416036412441414160414141604E4E2B2B4E4E4E4E4E4E4E2B2D332B2B
2B2B2B2B2B2B2B2A32322B2B4E2B2B2B2B322B4E2B2B414E2B2B2B2B2B2B2B2B
2B2B2C2B2D2B2B2B2B2B2B2B2B2B2B2B5D2B2B2B2B2B2B2B2B2B2B2B2B2B4141
2C2C2C2C2C2C2C2C2C2C2B2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C2C
2C2C2C2C2C2C41412D2D2D2D2D2D2D2D2D2D2D2D2B2D2D2D2D2D2D2D2D2D2D2D
2D2D2D2D2D2D2D2D2D2D2D2D2D2D41414E4E17174E4E4E4E4E4E4E4E41323232
3232323232324E32323241324E322F243232414E3232414E4E4E30304E4E4E4E
4E4E4E4E323332323232323232494E32323241414E3632413030324E3232414E
5656303056565656565656414156214141303041415641564141554141364141
30304156414141564141414141414141414141414141323232323232320D412A
323834414141324132323241323241414E4E32324E4E4E4E4E4E4E4E32333232
3232323232494E4E323241414E3632233232324E3232414E4E4E35354E4E4E4E
4E4E4E35353535353535353535354E41353535354E3535353535354E3535414E
4E4E41414E4E4E4E4E4E4141414141414141414141414E41414134414E414141
4141414E4141414E5E5E35355E5E5E5E5E5E5E35353535353535353535355E5E
413535355E3535353535415E3535415E5F5F36365F5F5F5F5F5F5F4141413636
36363636365F5F5F414136415F4136413636415F3636415F6262373762626262
6262624141373737373737373737416241413741624137413737416237374162
4E4E32324E4E4E4E4E4E4E41324E323232323232324E4E32323241414E413241
3232324E3232414E41413A3A414144454141023D3B3B3C3C3C3C3C3C3C41412A
3C3C414141373C233E3E41413C3C414150503A3A50505050505050413A502141
411A1A4141504150414155415036184141414150414141504141414141414141
4141414141413C3C3C3C3C3C3C41413C3C3C414141413C413C3C41413C3C4141
4E4E3C3C4E4E4E4E4E4E4E413C4E3C3C3C3C3C3C3C4E4E3C3C3C41414E363C23
3C3C3C4E3C3C414E414116161541414141411316164116161616161616411641
414116414141161616161641161641414E4E3A3A4E4E4E4E4E4E4E4141323232
3232323232324E41323241414E3232233232414E3232414E
}