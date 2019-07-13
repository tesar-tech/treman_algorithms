clc
close all
clear 

% tento skitpt umoznuje spusteni nasledujicich funkci:
%     LoadMT-nacteni a predzpracovani dat
%     FreqAnalysisMT- vypocet frekvence a vykonu tresu a zobrazeni vykon.
%     spektra
%     AmpliAnalysisMT- vypocet amplitudy tresu a zobrazeni prubehu amplitudy
%     v grafu

%%  celkovy seznam pacientu
seznam = { '50'};

%%  seznam pacientu deleny podle typu tresu
% ET=
% seznam={'02','03','04','08','10','16','19','20','24','25','27','28','29','33','34','35'}; 
% DT=
% seznam={'01','06','07','09','11','12','13','14','17','18','21','23','26','30','38','44','45'}; 
% ED=
% seznam={'05','15','31','32','36','37','46'}; 
% K=
% seznam={'39','40','41','42','43','47','48','49','50'}; 

%%  cyklus pro spousteni jednotlivych funkci

for n = 1:length(seznam)
   LoadMT(seznam{n});
   FreqAnalysisMT(seznam{n});
%    AmpliAnalysisMT(seznam{n});
   waitforbuttonpress
end

%%

[updater, acc] = LoadMT('../testsets/radim01');




