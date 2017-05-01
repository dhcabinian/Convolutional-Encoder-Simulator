function bits = demod8psk(type, Es, complex)
    x = pi/8:pi/4:15/8*pi;
    comp_arr = sqrt(Es)*cos(x) + sqrt(Es)*sin(x)*j;
    if strcmp(type,'grey')
        map = {[0, 0, 0], [0, 1, 0], [0, 1, 1], [0, 0, 1], [1, 0, 1], [1, 1, 1], [1, 1, 0], [1, 0, 0]};
    elseif strcmp(type,'natural')
        map = {[0, 0, 0], [0, 0, 1], [0, 1, 0], [0, 1, 1], [1, 0, 0], [1, 0, 1], [1, 1, 0], [1, 1, 1]};
    else 
        map = {[0, 0, 0], [0, 0, 1], [0, 1, 0], [0, 1, 1], [1, 0, 0], [1, 0, 1], [1, 1, 0], [1, 1, 1]};
    end
    [l,w] = size(complex);
    bits = [];
    for num = 1:w
        position = -1;
        min_dist = 10000*Es;
        for i = 1:numel(comp_arr)
            distance = abs(complex(num)-comp_arr(i));
            if distance < min_dist
                min_dist = distance;
                position = i;
            end
        end
        bits = [bits map{position}];
    end
    return;
end