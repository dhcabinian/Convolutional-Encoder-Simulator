function bits = demod8psk(type, Es, complex)
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
    min_dist = 10000*Es;
    for i = 1:numel(comp_arr)
        distance = abs(complex-comp_arr(i));
        if distance < min_dist
            min_dist = distance;
            position = i;
        end
    end
    bits = map{position};
    return;
end