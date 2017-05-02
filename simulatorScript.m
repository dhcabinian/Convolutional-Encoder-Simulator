msgLength = 12;
constName = '8PSK';
if strcmp(constName, 'QPSK')
    constSize = 4;
else
    constSize = 8;
end
constMap = 'Natural';
decodeType = 'Hard';
encodeName = 'Unencoded';
framesError = 100;


simulator(msgLength, encodeName, constName, constSize, constMap, decodeType, framesError)
function simulator(msgLength, encodeName, constName, constSize, constMap, decodeType, framesError)
    figureWindowTitle = sprintf('%s.%s.%s.%s',constName, constMap, decodeType, encodeName);
    figure('Name', figureWindowTitle, 'NumberTitle', 'off');
    xAxisEbs =[]; %initialize arrays for plotting
    yAxisBers = [];
    n = msgLength;
    k = msgLength;
    for dBEbN0 = -2:1:8
        EbN0 = 10^((dBEbN0)/10);
        N0 = 2; %number of symbols
        Eb = EbN0 * N0;
        if strcmp('QPSK', constName)
            Es = Eb * 2 * k / n;
        else
            Es = Eb * 3 * k / n;
        end
        % Model parameters
        %Es = 1; % energy per QPSK symbol
        %Eb = Es/2*(n/k); % energy per coded bit
        sigma2 = N0/2; % noise variance
        bit_err = 0; % initialize the number of bit errors
        error_counter = 0;
        message_counter = 0;
        if strcmp('Unencoded', encodeName)
            c = Constellation(constSize,constMap,Es);
        else
            encoder = ConvEncode(encodeName);
            c = Constellation(constSize,constMap,Es);
            decoder = ViterbiDecode(encoder,c,decodeType);
        end
        % Simulation of single transmission
        while(error_counter < framesError)
            message_counter = message_counter + 1;
            msg = (rand(1,k)>0.5); % generates k bits uniformly at random
            if strcmp('Unencoded', encodeName)
                cdwrd = msg;
            else
                cdwrd = encoder.encodeMsg(msg); % encodes message msg into codeword cdwrd of n bits
            end
            if mod(n,2)==1
                cdwrd = [cdwrd 0]; % padding if odd length
            end
            symb = c.modulate(cdwrd);
            rcvd_symb = symb + sqrt(sigma2)*(randn(size(symb))+j*randn(size(symb))); % channel noise
            rcvdBits = c.demodulate(rcvd_symb); %demod8psk('natural',Es,rcvd);
            if strcmp('Unencoded', encodeName)
                cdwrd_est = rcvdBits;
            else
                cdwrd_est = decoder.decodeMsg(rcvdBits); % form an estimate cdwrd ?est
            end
            bit_err = bit_err + sum(msg(1:n)~=cdwrd_est(1:n));
            new_error_bool = 0;
            if (sum(msg(1:n)~=cdwrd_est(1:n))>0)
                error_counter = error_counter+1;
                new_error_bool = 1;
            end
            ber = bit_err/(message_counter*msgLength);
            if(new_error_bool)
                p2 = plot(10*log10([xAxisEbs Eb/N0]), [yAxisBers ber], '--r');
                set(gca,'YScale','log');
                set(findall(gca, 'Type', 'Line'),'LineWidth',2);
                set(gcf, 'Units', 'inches'); % set units
                PaperWidth = 6; % paper width
                PaperHeight = PaperWidth*(sqrt(5)-1)/2; % paper height
                afFigurePosition = [1 1 PaperWidth PaperHeight]; % set
                grid on;
                set(gcf, 'Position', afFigurePosition); % set figure position on paper [left bottom width height] 7 set(gcf, ?PaperPositionMode?, ?auto?); %
                set(gca, 'Units','normalized','Position',[0.1 0.15 0.85 0.8]); % fit axes within figure
                %saveas(gcf, 'test', 'pdf'); % save figure as ?test.pdf?
                drawnow;
                counter = 0;
            end
            if error_counter > 50
                break;
            end
        end
        xAxisEbs = [xAxisEbs Eb/N0]; % add new points to arrays for plotting
        yAxisBers = [yAxisBers ber];
        saveStateName = sprintf('%s.%s.%s.%s.mat',constName, constMap, decodeType, encodeName);
        save(saveStateName);
    end
    figureWindowTitle = sprintf('%s.%s.%s.%s',constName, constMap, decodeType, encodeName);
    figure('Name', figureWindowTitle, 'NumberTitle', 'off');
    hold off;
    hold on;
    p2 = plot(10*log10(xAxisEbs), yAxisBers, '--r');
    set(gca,'YScale','log');
    grid on;
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gcf, 'Units', 'inches'); % set units
    PaperWidth = 6; % paper width
    PaperHeight = PaperWidth*(sqrt(5)-1)/2; % paper height
    %set(fid, 'PaperSize', [PaperWidth PaperHeight]); % set
    afFigurePosition = [1 1 PaperWidth PaperHeight]; % set
    set(gcf, 'Position', afFigurePosition); % set figure position on paper [left bottom width height] 7 set(gcf, ?PaperPositionMode?, ?auto?); %
    set(gca, 'Units','normalized','Position',[0.1 0.15 0.85 0.8]); % fit axes within figure
    saveStateName = sprintf('%s.%s.%s.%s.mat',constName, constMap, decodeType, encodeName);
    saveas(gcf, saveStateName, 'pdf'); % save figure as ?test.pdf?
    titleString = sprintf('Frame and Bit Error Rates vs E_b/N_0 for %s, %s, %s, %s.',constName, constMap, decodeType, encodeName);
    title(titleString); %title
    xlabel('Power Efficiency E_b/N_0 (dB)'); %label axis
    ylabel('Bit Error Rate (%)');
    legendBerTitle = sprintf('%s, %s, %s, %s BER',constName, constMap, decodeType, encodeName);
    legend(p2,legendBerTitle); %insert legend
end