fish_config theme choose ansi

function show256colors
    for i in (seq 0 255)
        printf "\e[48;5;%dm %3d \e[0m" $i $i
        if test (math $i % 8) -eq 7
            printf "\n"
        end
    end
end

function show16colors
    set_color --print-colors
end
