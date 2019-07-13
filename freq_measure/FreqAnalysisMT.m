function [frequencyMax, maxValuePower] = FreqAnalysisMT( txtFolder ) 

% Tato funkce nacte *.mat soubory ze zadane slozky a vypocita amplitudove
% a vykonove spektrum signalu a do slozky frequency ulozi maximalni 
% frekvenci a vykon signalu. Vstupem funkce je slozka pacienta, ktereho
% chceme analyzovat.

%%  vytvoreni slozky frequency
if ~exist([txtFolder '/frequency'], 'dir')
    mkdir([txtFolder '/frequency']);
end

%% nacteni *.mat souboru
    matList = dir([txtFolder '/results/*.mat']);
    numberMatFiles = length(matList(:,1));  % pocet .mat souboru
    fileNames = cell(numberMatFiles,1);

for i = 1:numberMatFiles
    fileNames{i,1} = matList(i,1).name; % nazvy souboru bez pripony
    fileNames{i,1} = regexprep(fileNames{i,1},'.mat','');
end

    clear i matList
    display(' ');
    display('Vypocet vykonu a frekvence tresu')
    display(strcat('ID pacienta:',num2str(txtFolder)))
    display('Budou zpracovany tyto soubory:')
for i =1:numberMatFiles
    display(strcat( num2str(i), ') ' ,fileNames{i,1} ))
end

%%  hlavni smycka pro vyhodnoceni ddt

for i = 1:numberMatFiles
%%  nacte i-ty *.mat soubor 
    load([txtFolder '/results/' char(fileNames(i,1))])
    
    dataLength = length(packetCount);
    
%%   tvorba masky frekvenci
    fvector = (0:dataLength)*updateRate/dataLength;
    m = fvector > 2 & fvector < 12;
    for g=2:dataLength
        if m(g)==1 && m(g-1)==0
            ind=g-1;
        end
    end
    
%%   vypoèet frekvence tøesu pomoci FFT  
    Fp=abs(fft(acc(:,1)))+abs(fft(acc(:,2))) + abs(fft(acc(:,3)));
      
%%   vypocet vykonu z FFT
    Power=  (Fp(m).*Fp(m))/dataLength;
    [maxValuePower,indexMaxp] = max(Power);
    frequencyMax = fvector(indexMaxp+ind) ;  
 
%%  zobrazeni dat do grafu   
   figure (1)
   subplot(5,2,i)
   plot(fvector(m),Power,'color',[0,0.5,0])
   hold on 
   plot(fvector(indexMaxp+ind),maxValuePower,'rx','markersize', 14)
   line([fvector(indexMaxp+ind) fvector(indexMaxp+ind)], [0 (max(Power))],'color','r','LineWidth',1.5)
   hold off
   title(fileNames(i,1),'FontSize',14 );
   xlabel('frekvence (Hz)');
   ylabel({'výkonové'; 'spektrum'});  
   
%%   vypocet vykonu v dB
    vykon=10*log10(maxValuePower);
    
%%   zobrazeni frekvence do command window   
    display(' ')
    display(strcat( fileNames{i,1}));
    display(strcat('  frekvence tresu:', num2str(frequencyMax), ' (Hz)'));
    display(strcat('  vykon tresu:', num2str(vykon), ' (dB)'));

%%   ulozeni dat
    save([txtFolder '/frequency/' fileNames{i,1} '_frequency'],'frequencyMax','maxValuePower','vykon');

    clear vykon vysla spektrum t fvector acceleration freeAcceleration packetCounter updateRate accRefFrame accRefFrameFree M rychlost draha amplituda  timeVector pC acc  newPacketCounter
end

    clear fileID i rowIndex updateRateCell matrix ind g accclear
end

