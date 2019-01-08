*================================================================================;
*Macro para a seleção de modelos lineares;
*================================================================================;
%macro selecao(y=,xs=,banco=);
ods trace on / listing;

proc reg data=&banco;
	model &y = &xs
	/selection=rsquare start=2 stop=11 mse aic bic cp adjrsq;
ods output SubsetSelSummary=selecao(drop=ModelIndex dependent model RSquare Control);
run;

ods trace off;
proc print data=selecao noobs;
run;

*R2 ajustado;
proc sort data=selecao;by Adjrsq;run;
data selecao;set selecao;
rajscore=_N_;run;

*AIC;
proc sort data=selecao;by descending AIC;run;
data selecao;set selecao;
AICscore=_N_;run;

*BIC;
proc sort data=selecao;by descending BIC;run;
data selecao;set selecao;
BICscore=_N_;run;

*EQM;
proc sort data=selecao;by descending MSE;run;
data selecao;
set selecao;SSEscore=_N_;run;

*Soma dos ranks;
data rank_final(keep=VarsInModel numinmodel rank cp);set selecao;
	rank=sum(rajscore,AICscore,BICscore,SSEscore);
run;
proc sort data=	rank_final;by descending rank;run;
proc print data=rank_final(obs=5) noobs;
run;
%mend;

%selecao(y=pesonasc,xs=diacabeca idadegest idademae idadepai numcigmae
alturamae pesomae escpai numcigpai alturapai,banco=dados);
