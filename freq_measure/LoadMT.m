function [ updateRate, acc] = LoadMT( txtFolder )

%   Tato funkce nacte *.txt soubory ze zadane slozky a odebere ze zrychleni
%   gravitacni slozku, vysledna data nasledne ulozi do aktualni slozky
%   do slozky results s nazvy jednotlivych ukonu. Vstupem funkce je nazev
%   slozky pacienta, u ktereho chceme predzpracovat data.

%%  vytvoreni slozky results ve slozce pacienta
 if ~exist([txtFolder '/results'], 'dir')
     mkdir([txtFolder '/results']);
 end

%% nacte nazvy .txt souboru ze slozky data
    txtList = dir([txtFolder '/*.txt']);
    numberTxtFiles = length(txtList(:,1));  % pocet .txt souboru
    fileNames = cell(numberTxtFiles,1);

for i = 1:numberTxtFiles
    fileNames{i,1} = txtList(i,1).name;
    fileNames{i,1} = regexprep(fileNames{i,1},'.txt','');
end

    display(' ');
    display('Predzpracovani dat z akcelerometru')
    display(strcat('ID pacienta:',num2str(txtFolder)))
    display(' ')
    display(['Pocet *.txt souboru s daty: ' num2str(numberTxtFiles)])
    display(' ')

    clear txtList i

    updateRateAll = zeros(numberTxtFiles,1);

%%  cyklus procházejici jednotlive ukony
for i = 1:numberTxtFiles
%%  otevre i-ty *.txt soubor ke cteni
    fileID = fopen([txtFolder '/' fileNames{i, 1} '.txt'],'r');
    
%%  vzorkovaci frekvence
    rowIndex = 2;
    updateRateCell = textscan(fileID, '%*s %*s %*s %s', 1,'delimiter',' ','headerlines', rowIndex-1);
    updateRateAll(i,1) = str2double(char(regexprep(updateRateCell{1,1},'Hz',''))); 
    updateRate = updateRateAll(i,1);
    
    display('Vzorkovaci frekvence dat: ');
    display([ fileNames{i,1} 'je ' updateRateCell{1,1}])
   
   
    rowIndex = 5;
    tempVar = textscan(fileID, '%[^\n]',1,'Headerlines',rowIndex-1);
    columnNames = regexp(tempVar{1},'[,]*','split');    
    columnNumber = length(columnNames{1,1}) - 1;
    
%%  nacteni dat do promennych
    for j = 1:columnNumber
        isEqual = strcmp(char(columnNames{1,1}{1,j}),'PacketCounter');
        if isEqual == 1 
            indexPacketCounter = j;
        end
        isEqual = strcmp(char(columnNames{1,1}{1,j}),'Acc_X');
        if isEqual == 1 
            indexAccX = j;
        end
        isEqual = strcmp(char(columnNames{1,1}{1,j}),'FreeAcc_X');
        if isEqual == 1 
            indexFreeAccX = j;
        end     
        isEqual = strcmp(char(columnNames{1,1}{1,j}),'Mat[1][1]');
        if isEqual == 1 
            indexMatrix = j;
        end      
    end
        

    data = textscan(fileID, repmat('%f%s%s%s%s%s%s%s%s',[1,1]));
    packetCounter = data{1,indexPacketCounter};
    acceleration = [data{1,indexAccX} data{1,indexAccX+1} data{1,indexAccX+2}];   
    freeAcc = [data{1,indexFreeAccX} data{1,indexFreeAccX+1} data{1,indexFreeAccX+2}];   
    matrix=[data{1,indexMatrix} data{1,indexMatrix+1} data{1,indexMatrix+2} data{1,indexMatrix+3} data{1,indexMatrix+4} data{1,indexMatrix+5} data{1,indexMatrix+6} data{1,indexMatrix+7} data{1,indexMatrix+8}];
    display('Potrebna data nactena.');
    
%%  odstraneni gravitacni slozky zrychleni
    M = reshape(matrix',3,3,[]);
    for k = 1:length(M)
        accRefFrame(k,:) = (M(:,:,k)*acceleration(k,:)')';
    end
    
    for k = 1:length(M)
        accRefFrameFree(k,:)=accRefFrame(k,:)-median(accRefFrame);
    end
   
%%  interpolace dat   
    newPacketCounter = packetCounter;
    newPacketCounter(packetCounter < packetCounter(1)) = packetCounter(packetCounter < packetCounter(1))+ 2^16;
    packetCount = newPacketCounter(1):newPacketCounter(end);
    
    dataLength = length(packetCount);
    acc = [];
    acc(:,1) = interp1(newPacketCounter,accRefFrameFree(:,1),packetCount,'packetCounthip');
    acc(:,2) = interp1(newPacketCounter,accRefFrameFree(:,2),packetCount,'packetCounthip');
    acc(:,3) = interp1(newPacketCounter,accRefFrameFree(:,3),packetCount,'packetCounthip');
    timeVector = zeros(dataLength,1);
    
%%  casovy vektor
    for z = 1:dataLength
        timeVector(z,1) = (packetCount(1,z) - packetCount(1,1)) / updateRate;
    end

%%  ulozeni dat do *. mat s nazvem *.txt souboru
    save([txtFolder '/results/' fileNames{i,1}],'packetCount','timeVector','acc','acceleration','matrix','updateRate');
 
    display(strcat('Data byla ulozena do souboru:', fileNames{i,1}, '.mat.'));
    display(' ');
    
    fileID = fclose(fileID);
    
    clear  accRefFrameFree  acc timeVector newPacketCounter
end

    clear fileID i rowIndex updateRateCell
end

