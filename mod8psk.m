function complex = mod8psk(type, Es, bits)
    x = pi/8:pi/4:15/8*pi;
    comp_arr = sqrt(Es)*cos(x) + sqrt(Es)*sin(x)*j;
    if strcmp(type,'grey')
        map = {[0, 0, 0], [0, 1, 0], [0, 1, 1], [0, 0, 1], [1, 0, 1], [1, 1, 1], [1, 1, 0], [1, 0, 0]};
    elseif strcmp(type,'natural')
        map = {[0, 0, 0], [0, 0, 1], [0, 1, 0], [0, 1, 1], [1, 0, 0], [1, 0, 1], [1, 1, 0], [1, 1, 1]};
    else 
        map = {[0, 0, 0], [0, 0, 1], [0, 1, 0], [0, 1, 1], [1, 0, 0], [1, 0, 1], [1, 1, 0], [1, 1, 1]};
    end
    complex = [];
    [l,w] = size(bits);
    for set = 1:3:w-2
        position = -1;
        for i = 1:numel(map)
            if isequal(bits(set:1:set+2),map{i})
                position = i;
            end
        end
        complex = [complex comp_arr(position)];
    end
    return;
end