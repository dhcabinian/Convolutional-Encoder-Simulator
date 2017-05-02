figure;
Ebs =[]; %initialize arrays for plotting
fers = [];
bers = [];
pus = [];
pls = [];
n = 10000;
k = 10000;
error_counter = 0;
for dBEbN0 = -2:1:10
    EbN0 = 10^((dBEbN0)/10);
    N0 = 2; %number of symbols
    Eb = EbN0 * N0;
    Es = Eb * 2 * k / n;
    % Model parameters
    %Es = 1; % energy per QPSK symbol
    %Eb = Es/2*(n/k); % energy per coded bit
    sigma2 = N0/2; % noise variance
    frame_err = 0; % initialize the number of frame errors
    bit_err = 0; % initialize the number of bit errors
    frame_nb = 0; % initialize the number of codeword transmissions
    counter = 0;
    pl=0; % initialize lower bound on Wilson interval;
    pu=1; % initialize upper bound on Wilson interval;
    da = 1.96;
    error_counter = 0;
    encoder = ConvEncode('G1');
    c = Constellation(4,'natural',Es);
    decoder = ViterbiDecode(encoder,c,'hard');
    % Simulation of single transmission
    while(((frame_nb<30)||(abs(pu-pl)>0.1*frame_err/frame_nb))&& error_counter < 10)
        counter = counter + 1; % counter for use to show difference in error rates
        frame_nb = frame_nb +1; % update count of frame simulations
        msg = (rand(1,k)>0.5); % generates k bits uniformly at random
        cdwrd = encoder.encodeMsg(msg); % REPLACE THIS LINE BY YOUR SOLUTION: encodes message msg into codeword cdwrd of n bits
        if mod(n,2)==1
            cdwrd = [cdwrd 0]; % padding if odd length
        end
        symb = c.modulate(cdwrd); %mod8psk('natural',Es,cdwrd); %sqrt(Es/2)*(1-2*cdwrd(1:2:end))+j*sqrt(Es/2)*(1-2*cdwrd(2:2:end)); % QPSK modulation
        rcvd = symb + sqrt(sigma2)*(randn(size(symb))+j*randn(size(symb))); % channel noise
        rcvd_dem = zeros(1,3*length(symb)); % demodulation with optimal decision
        rcvd_dem = c.demodulate(rcvd); %demod8psk('natural',Es,rcvd);
        %rcvd_dem(1:2:end) = (real(rcvd)<0); % hard decoding of in-phase (I) component
        %rcvd_dem(2:2:end) = (imag(rcvd)<0); % hard decoding of out-of-phase (Q) component
        %rcvd_dem = rcvd_dem(1:n); % removes the padded bits
        cdwrd_est = decoder.decodeMsg(rcvd_dem); % REPLACE THIS LINE BY YOUR SOLUTION: form an estimate cdwrd ?est
        bit_err = bit_err + sum(msg(1:n)~=cdwrd_est(1:n));
        frame_err = frame_err + (sum(msg(1:n)~=cdwrd_est(1:n))>0);
        if (sum(msg(1:n)~=cdwrd_est(1:n))>0)
            error_counter = error_counter+1;
        end
        fer = frame_err/frame_nb;
        ber = bit_err/(frame_nb*n);
        pu = (fer + (da^2)/(2*frame_nb) + da*sqrt((fer*(1-fer)/frame_nb + (da/(2*frame_nb))^2))) / (1+(da^2)/frame_nb);
        pl = (fer + (da^2)/(2*frame_nb) - da*sqrt((fer*(1-fer)/frame_nb + (da/(2*frame_nb))^2))) / (1+(da^2)/frame_nb);
        %p_err = sum(cdwrd~=cdwrd_est)/n; % computes the BER over the codeword
        %err = (perr>0); % computes whether a frame error occured
        if(counter == 1)   
            p0 = errorbar(10*log10([Ebs Eb/N0]),[fers fer],[fers fer]-[pls pl], [pus pu]-[fers fer], '--g');
            set(gca,'YScale','log');
            set(findall(gca, 'Type', 'Line'),'LineWidth',2);
            set(gcf, 'Units', 'inches'); % set units
            PaperWidth = 6; % paper width
            PaperHeight = PaperWidth*(sqrt(5)-1)/2; % paper height
            %set(fid, 'PaperSize', [PaperWidth PaperHeight]); % set
            afFigurePosition = [1 1 PaperWidth PaperHeight]; % set
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
    Ebs = [Ebs Eb/N0]; % add new points to arrays for plotting
    fers = [fers fer];
    bers = [bers ber];
    pus = [pus pu];
    pls = [pls pl];
    save('QPSKNaturalHardG1.mat');
end

figure('Name','8-PSK')
hold off;
errorbar(10*log10(Ebs),fers,fers-pls, pus-fers, '--k');
hold on;
p0 = plot(10*log10(Ebs),fers,'--g');
p1 = plot(10*log10(Ebs), bers, 'g--o');
%BER = qfunc(sqrt(2*Ebs));
%p2 = plot(10*log10(Ebs), BER, '--r');
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
saveas(gcf, 'test', 'pdf'); % save figure as ?test.pdf?

title('Frame and Bit Error Rates vs E_b/N_0 for 8-PSK'); %title
xlabel('Power Efficiency E_b/N_0 (dB)'); %label axis
ylabel('Bit Error Rate (%)');
legend([p0 p1],'8-PSK FER','8-PSK BER'); %insert legend

