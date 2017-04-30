function complex = mod8psk(type, Es, bits)
    x = pi/8:pi/4:15/8*pi;
    comp_arr = Es/2*cos(x) + Es/2*sin(x)*j;
    if strcmp(type,'grey')
        map = {[0, 0, 0], [0, 1, 0], [0, 1, 1], [0, 0, 1], [1, 0, 1], [1, 1, 1], [1, 1, 0], [1, 0, 0]};
    elseif strcmp(type,'natural')
        map = {[0, 0, 0], [0, 0, 1], [0, 1, 0], [0, 1, 1], [1, 0, 0], [1, 0, 1], [1, 1, 0], [1, 1, 1]};
    else 
        map = {[0, 0, 0], [0, 0, 1], [0, 1, 0], [0, 1, 1], [1, 0, 0], [1, 0, 1], [1, 1, 0], [1, 1, 1]};
    end
    position = -1;
    for i = 1:numel(map)
        if isequal(bits,map{i})
            position = i;
        end
    end
    complex = comp_arr(position);
    return;
end