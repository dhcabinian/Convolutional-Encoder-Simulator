classdef Constellation
    properties
        imagKeyMapping;
        bitKeyMapping;
        constBitSize;
    end
    
    methods
        function obj = Constellation(constellationSize,type, Es)
            if constellationSize == 4
                obj.constBitSize = 2;
                x = pi/4:pi/2:7*pi/4;
                compArr = Es/2*cos(x) + Es/2*sin(x)*j;
                if strcmp(type,'grey')
                    map = {[0 0], [0 1], [1 1], [1 0]};
                elseif strcmp(type,'natural')
                    map = {[0 0], [0 1], [1 0], [1 1]};
                elseif strcmp(type,'set')
                    map = {[0 0], [0 1], [1 0], [1 1]};
                else 
                    error('Correct type not provided');
                end   
            elseif constellationSize == 8
                obj.constBitSize = 3;
                x = pi/8:pi/4:15/8*pi;
                compArr = Es/2*cos(x) + Es/2*sin(x)*j;
                if strcmp(type,'grey')
                    map = {[0, 0, 0], [0, 1, 0], [0, 1, 1], [0, 0, 1], [1, 0, 1], [1, 1, 1], [1, 1, 0], [1, 0, 0]};
                elseif strcmp(type,'natural')
                    map = {[0, 0, 0], [0, 0, 1], [0, 1, 0], [0, 1, 1], [1, 0, 0], [1, 0, 1], [1, 1, 0], [1, 1, 1]};
                elseif strcmp(type,'set')
                    map = {[0, 0, 0], [0, 0, 1], [0, 1, 0], [0, 1, 1], [1, 0, 0], [1, 0, 1], [1, 1, 0], [1, 1, 1]};
                else 
                    error('Correct type not provided');
                end
            else
                error('Constellation size input not valid')
            end
            mapDec = {};
            imagStringKeys = {};
            for index = 1:length(map)
                decimalRep = bi2de(map{index},'left-msb');
                mapDec{end + 1} = decimalRep;
                imagStringKey = compToString(compArr(index));
                imagStringKeys{end + 1} = imagStringKey;
            end 
            compCellArr = num2cell(compArr);
            bitKeyMapping = containers.Map(mapDec, compCellArr);
            imagKeyMapping = containers.Map(imagStringKeys, map);
            obj.bitKeyMapping = bitKeyMapping;
            obj.imagKeyMapping = imagKeyMapping;
            return
        end
        
        function imagArr = modulate(obj, bits)
            imagArr = [];
            while mod(length(bits), obj.constBitSize) ~= 0 
                bits = [bits 0];
            end
            
            numberOfSymbols = length(bits) / obj.constBitSize;
            symbols = transpose(reshape(bits, [], numberOfSymbols));
            for row = 1:size(symbols,1)
                symbol = symbols(row, :);
                imagArr = [imagArr obj.bitKeyMapping(bi2de(symbol,'left-msb'))];
            end
            return
        end
        
        function codewordCellArr = demodulate(obj, imagArr)
            codewordCellArr = {};
            for comp = imagArr
                keys = obj.bitKeyMapping.keys();
                min_dist = [];
                min_bit = [];
                for key = keys
                    distance = abs(comp-obj.bitKeyMapping(key{1}));
                    if isempty(min_bit) || distance < min_dist
                        min_dist = distance;
                        min_bit = key{1};
                    end
                end
                bitsStr = dec2bin(min_bit);
                bits = zeros(1, length(bitsStr));
                for index = 1:length(bitsStr)
                    bits(index) = str2double(bitsStr(index));
                end
                codewordCellArr{end + 1} = bits;
            end
            return
        end
    end
end

function compString = compToString(comp)
    compString = num2str(comp);
    return
end

function comp = compFromString(compString)
    comp = str2double(compString);
    return
end