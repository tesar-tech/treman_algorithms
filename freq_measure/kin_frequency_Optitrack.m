function [ Frequency, Power ] = kin_frequency_Optitrack( txtFolder )
%% kin_frequency
% Tato funkce vypocita dominantni frekvenci a vykon kinetickeho tresu prave
% a leve ruky.
% Vstupem teto funkce je ID probanda, ktereho chceme hodnotit.
% Vystupem je graficke zobrazeni vykonoveho spektra v rozsahu 2-12 Hz 
% a vyznacene urcene frekvence tresu.
% Vystupnimi parametry jsou Frequency, coz odpovida frekvenci tresu prave 
% a leve ruky  a promenna Power, ktera urcuje vykon tresu v dB pro pravou
% a pro levou ruku daneho probanda.

%% nacteni nazvu *.mat souboru ve slozce
matList = dir([txtFolder '/*.mat']);
numberMatFiles = length(matList(:,1));  % pocet .mat souboru
fileNames = cell(numberMatFiles,1);

for i = 1:numberMatFiles
    fileNames{i,1} = matList(i,1).name; % nazvy souboru bez pripony
    fileNames{i,1} = regexprep(fileNames{i,1},'.mat','');
end

clear i matList

% zobrazeni ID probanda do okna
disp('Výpoèet frekvence a výkonu tøesu')
disp(strcat('ID probanda:',num2str(txtFolder)))

% identifikace ukonu TKinR a TKinL
L=zeros(numberMatFiles,1);
R=zeros(numberMatFiles,1);
for i = 1:numberMatFiles
    L(i,1)=strcmp(fileNames{i,1},'TKinL');
    R(i,1)=strcmp(fileNames{i,1},'TKinR');
end
idx=find(sum([R L],2));

%  smycka pro analyzu dat
for m=1:2
    %  nacteni souboru;
    load([txtFolder '/' char(fileNames(idx(m),1))])
    
    % uprava dat dat
    data_filtr=sgolayfilt(Data,4,61);
    data_filtr2=(Data-data_filtr);
    
    % urceni delky casoveho kroku
    stepSize=median(TimeVector(2:end) - TimeVector(1:end-1));

    % vypocet spektralniho odhadu
    updateRate=120;
    [pxx,fvector2] = pwelch(data_filtr2,360,[],[],updateRate);
    
    % tvorba masky frekvenci v rozsahu 2 az 12 Hz
    m2 = fvector2 >2 & fvector2 < 12;
    for g=2:length(fvector2)
        if m2(g)==1 && m2(g-1)==0
            ind2=g-1;
        end
    end
    
    % soucet x, y a z slozek
    Welch=(sum(pxx,2));
    
    % vypocet vykonua frekvence tresu
    [maxValuePower2,indexMaxp2] = max(Welch(m2));
    Frequency(m) = fvector2(indexMaxp2+ind2) ;
    Power(m)=10*log10(max(Welch(m2)));
    
    %  zobrazeni dat do grafu
    figure(5)
    subplot(2,1,m)
    plot(fvector2(m2),10*log10(Welch(m2)),'b')
    hold on
    plot(fvector2(indexMaxp2+ind2),10*log10(maxValuePower2),'rx','markersize', 12)
    line([fvector2(indexMaxp2+ind2) fvector2(indexMaxp2+ind2)], [0 10*log10((max(Welch(m2))))],'color','r','LineWidth',1.5)
    hold off
    title(['Frekvence tøesu' fileNames(idx(m),1)])
    xlabel('frekvence (Hz)');
    ylabel({'výkonové'; 'spektrum (dB)'});
    axis tight
    clear pxx fvector2 Welch
end

end

