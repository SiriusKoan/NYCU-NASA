awk ' BEGIN{
        files[0]="sudo";
        files[1]="ip";
        files[2]="user";
        tmp=1;
        month["Jan"]="01";
        month["Feb"]="02";
        month["Mar"]="03";
        month["Apr"]="04";
        month["May"]="05";
        month["Jun"]="06";
        month["Jul"]="07";
        month["Aug"]="08";
        month["Sep"]="09";
        month["Oct"]="10";
        month["Nov"]="11";
        month["Dec"]="12";
    }
    {
        if (/sudo/) {
            split($0,full,"COMMAND=");
            if (full[2] != ""){
                split(full[1],info," ");
                if (length(info[2])==1) {
                    info[2]="0"info[2];
                }
                if (tmp == 1){
                    tmp = 2;
                    content[0]=info[6]" used sudo to do `"full[2]"` on 2021-"month[info[1]]"-"info[2]" "info[3]content[0]
                } else {
                    content[0]=info[6]" used sudo to do `"full[2]"` on 2021-"month[info[1]]"-"info[2]" "info[3]"\n"content[0]
                }
            }
        }
        if (/.*error: PAM.*/) {
            count[$NF]++;
            if(NF==13) count2[$11]++
        }
        if (/last message repeated [0-9]* times/ && match(prev,/.*error: PAM.*/)) {
            n=split(prev,prev_split," ");
            count[prev_split[n]]+=$9;
            count2[prev_split[11]]+=$9;
        }
    }
    {prev=$0}
    END {
        tmp = 1;
        for (word in count) {
            if(tmp == 1) {
                tmp = 2;
                content[1]=word" failed to log in "count[word]" times"content[1]
            }
            else {
                content[1]=word" failed to log in "count[word]" times\n"content[1]
            }
        }
    }
    END {
        tmp = 1;
        for ( word in count2 ) 
            if(tmp == 1){
                tmp = 2;
                content[2]=word" failed to log in "count2[word]" times"content[2]
            } else {
                content[2]=word" failed to log in "count2[word]" times\n"content[2]
            }
    }
    END { 
        for (j in files) print content[j] > ("audit_" files[j] ".txt")
    }'

