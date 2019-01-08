*================================================================================;
*Macro para análise de pontos influentes;
*================================================================================;

data teste;
do mu = 0.05 , 0.25,0.5 ,0.75 ,0.95;
test=mu;
end;
run;

ods listing gpath="C:\Users\Furriell\Documents\SAS";
ods graphics on;
proc reg data=dados plots(label)=DFBETAS(unpack);
	id identifica__o;
	model pesonasc = diacabeca idadegest
	numcigmae alturamae pesomae alturapai;
	reweight identifica__o=436;
	reweight identifica__o=17;
run;
ods html close;
ods trace off;



ods listing gpath="C:\Users\Furriell\Documents\SAS";
proc reg data=dados plots(label)=all;
	id identifica__o;
	model pesonasc = diacabeca altura idadegest idademae numcigmae
alturamae pesomae idadepai escpai numcigpai alturapai;
run;
ods trace off;
