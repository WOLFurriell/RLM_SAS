*===================================================================================================;
*==== Regressão Linear =============================================================================;
*===================================================================================================;
proc delete data=_all_;
run;

* Templates =======================================================================================;
*Template tabelas;
proc template;
define style myAnalysis; parent= styles.Analysis;
replace Table from Output /
frame = void
rules = rows
cellpadding = 3pt
cellspacing = 0.0pt
borderwidth = 0.2pt;
class data /
 fontfamily = "Palatino"
fontsize = 8pt; 
end;
run;

*Template fontes gráficos;
proc template;
define style MyStyleDefault;
parent=Styles.statistical;
style GraphLabelText from GraphLabelText / fontsize =16pt;
style GraphValueText from GraphValueText / fontsize =12pt;
end;
run;

*===================================================================================================;
*Importando o banco de dados;
filename dados "D:\Estatística\REGRESSÃO\Trabalho\dados_peso.xls";
proc import datafile = dados
			out = dados
			dbms = xls replace;
	getnames = yes;
run;

*Atribuindo os labels;
data dados(rename=(diacabe_a=diacabeca));
set dados;
label 
/*Dados criança*/
diacabe_a = "diâmetro da cabeça (cm)"
altura = "altura ao nascer (cm)"
pesonasc = "peso ao nascer (kg)"
idadegest = "idade gestacional  (semanas)"
/*Dados Mãe*/
idademae = "idade da mãe (anos)"
numcigmae = "número de cigarros que fuma (número de cigarros/dia)"
alturamae= "altura da mãe  (m)"
pesomae = "peso antes da gravidez (kg)"
/*Dados Pai*/
idadepai = "idade do pai (anos)"
escpai = "escolaridade do pai (anos)"
numcigpai = "número de cigarros que fuma (número de cigarros/dia)"
alturapai = "altura do pai (m)";
run;
data dados;
set dados;
pesonasc = (pesonasc/1000);
run;

*===================================================================================================;
*Dicionário de dados;
ods trace on / listing;
ods output Variables=dicionario(drop=member len pos format type);
proc contents data=dados;
run;
ods trace off;
proc sort data=dicionario;
by num;
run;

*ODS PDF FILE="D:\Estatística\REGRESSÃO\Trabalho\Latex\dicionario.pdf" style=myAnalysis;
options orientation=landscape nodate nonumber center; 
ods noptitle;title;
Options papersize=("8cm" "20cm");
proc print data=dicionario(drop=num);
run;
ods pdf close;

*===================================================================================================;
*An�lise descritiva dos dados;

*Medidas de posição e dispersão;
ods _all_ close;options printerpath=png nodate papersize=('26cm','10cm');title;
ods printer file="D:\Estatística\REGRESSÃO\Trabalho\Latex\medidas.png" 
dpi=400 style=myAnalysis;
proc means data=dados mean min max std cv skewness kurtosis;
var diacabeca altura pesonasc idadegest idademae numcigmae alturamae pesomae
idadepai escpai numcigpai alturapai;
run;
ods printer close;

*===================================================================================================;
*Histograma para a variável resposta;
ods graphics on / reset = all height=8 in width=8 in border=off ;
*ods listing image_dpi=300 gpath="D:\Estatística\REGRESSÃO\Trabalho\Latex";
ods graphics / imagename = "hist_resposta";
ods html style = MyStyleDefault;
proc sgplot data=dados;
  histogram pesonasc/fillattrs=(color=PKGR);
  density pesonasc  / type=normal legendlabel="Normal" lineattrs=(pattern=solid color=BLACK);
  density pesonasc  / type=kernel legendlabel="Kernel" lineattrs=(pattern=solid color=RED);
  keylegend / location=inside position=topright across=1;
  yaxis label = "Frequ�ncia";
run;
ods listing close; 

*Macro para os histogramas;
%macro histograma(var=);
ods html style = MyStyleDefault;
proc sgplot data=dados;
   histogram &var/fillattrs=(color=LIGB);
   yaxis label = "Frequ�ncia";
run;
%mend;
%macro histograma2(var=);
ods html style = MyStyleDefault;
proc sgplot data=dados;
   histogram &var/fillattrs=(color=LIGB) binwidth=3;
   yaxis label = "Frequ�ncia";
run;
%mend;

*Gerando histogramas;
ods _all_ close; 
ods html path='c:\temp' (url=none) file='sastest.html';
options nodate nonumber;
title;
ods layout gridded columns=3 rows=4; 
ods region;%histograma2(var=diacabeca);
ods region;%histograma2(var=altura);
ods region;%histograma(var=pesonasc);
ods region;%histograma(var=idadegest);
ods region;%histograma(var=idademae);
ods region;%histograma2(var=numcigmae);
ods region;%histograma(var=alturamae);
ods region;%histograma(var=pesomae);
ods region;%histograma(var=idadepai);
ods region;%histograma2(var=escpai);
ods region;%histograma2(var=numcigpai);
ods region;%histograma(var=alturapai);
quit;
ods layout end;

*===================================================================================================;
*Verificando a relação linear da resposta com as covari�veis;
goptions reset=all ;
%macro relinear(var=);
ods html style = MyStyleDefault;
proc sgplot data=dados noautolegend;
	scatter y=pesonasc x=&var;
run;
%mend;

options nodate nonumber;
title;
ods html style = MyStyleDefault;
ods layout gridded columns=3 rows=4; 
ods region;%relinear(var=diacabeca);
ods region;%relinear(var=altura);
ods region;%relinear(var=idadegest);
ods region;%relinear(var=idademae);
ods region;%relinear(var=numcigmae);
ods region;%relinear(var=alturamae);
ods region;%relinear(var=pesomae);
ods region;%relinear(var=idadepai);
ods region;%relinear(var=escpai);
ods region;%relinear(var=numcigpai);
ods region;%relinear(var=alturapai);
quit;
ods layout end;

PROC GPLOT DATA=dados;
     PLOT pesonasc*alturapai;
RUN; 



*===================================================================================================;
* Modelo linear geral;
ods _all_ close;options printerpath=png nodate papersize=('21cm','21cm');title;
*ods printer file="D:\Estatística\REGRESSÃO\Trabalho\Latex\reg_geral.png" 
dpi=400 style=myAnalysis;
ods exclude NObs DiagnosticsPanel ResidualPlot ResidualPlot; 
proc reg data=dados;
	model pesonasc = diacabeca altura idadegest idademae numcigmae
alturamae pesomae idadepai escpai numcigpai alturapai;
run;
ods printer  close; 

*===================================================================================================;
* Multicolinearidade;
ods trace on / listing;
ods output CollinDiag=multicolin;
ods output ParameterEstimates=multicolinearidade(keep=variable label VarianceInflation tolerance);
proc reg data=dados;
	model pesonasc = diacabeca altura idadegest idademae numcigmae
alturamae pesomae idadepai escpai numcigpai alturapai/collin vif tol;
run;
ods trace off;

*Tabela VIF;
ods _all_ close;options printerpath=png nodate papersize=('12cm','8cm');
ods noptitle;title;
*ods printer file="D:\Estatística\REGRESSÃO\Trabalho\Latex\multicolinearidade.png" 
dpi=400 style=myAnalysis;
proc print data=multicolinearidade(rename=(VarianceInflation=VIF)) noobs;
run;
ods printer  close; 

*M�dia VIF;
ods _all_ close;options printerpath=png nodate papersize=('8cm','4cm');title;
ods printer file="D:\Estatística\REGRESSÃO\Trabalho\Latex\media_vif.png" 
dpi=400 style=myAnalysis;
proc means data=multicolinearidade;
	var VarianceInflation;
run;
ods printer  close; 

*Condition Index;
ods _all_ close;options printerpath=png nodate papersize=('20cm','17cm');
ods noptitle;title;
ods printer file="D:\Estatística\REGRESSÃO\Trabalho\Latex\Condition_ind.png" 
dpi=400 style=myAnalysis;
proc print data=multicolin(drop=model Dependent) noobs;
run;
ods printer  close; 

*===================================================================================================;
* Colinearidade;
* Correla��o;

data dados1;set dados;run;
proc datasets nolist; *retirando os labels; 
  modify dados1;
  attrib _all_ label='';
quit;

*Scatter plot matrix Pai x Mãe;
ods graphics on / reset = all height=8 in width=8 in border=off ;
ods listing image_dpi=300 gpath="D:\Estatística\REGRESSÃO\Trabalho\Latex";
ods graphics / imagename = "matrix_plot_paimae";
proc sgscatter data=dados1; 
matrix idademae numcigmae alturamae pesomae
idadepai escpai numcigpai alturapai /diagonal=(histogram kernel)
markerattrs=(symbol=circle size=5);
run;
ods listing close;

ods _all_ close;options printerpath=png nodate papersize=('25cm','17cm');title;
ods printer file="D:\Estatística\REGRESSÃO\Trabalho\Latex\pearson.png" 
dpi=500 style=myAnalysis;
ods exclude  VarInformation SimpleStats; *Excluir outputs indesejados;
options nolabel;
proc corr data=dados pearson;  
var pesonasc diacabeca altura idadegest idademae numcigmae alturamae pesomae
idadepai escpai numcigpai alturapai;
run;
ods printer  close; 

*===================================================================================================;
* Avaliando a idade da m�e e a idade do pai, sem a altura do ;

*Ajuste parcial;
ods _all_ close; 
ods html path='c:\temp' (url=none) file='sastest.html';
*+++++++++++++++++++++++++++++++++++++++++++++++;
*Modelo geral 1;
proc reg data=dados;
model pesonasc = diacabeca idadegest idademae idadepai numcigmae
alturamae pesomae escpai numcigpai alturapai /
selection=rsquare start=9 stop=9 mse aic bic press cp adjrsq jp p r;
ods output OutputStatistics=resid_pred1;
run;

*+++++++++++++++++++++++++++++++++++++++++++++++;
*Modelo geral 2;
proc reg data=dados;
model pesonasc = diacabeca idadegest idademae numcigmae
alturamae pesomae escpai numcigpai alturapai /mse aic bic press cp adjrsq jp p r;
ods output OutputStatistics=resid_pred2;
run;

proc reg data=dados;
model pesonasc = diacabeca idadegest idadepai numcigmae
alturamae pesomae escpai numcigpai alturapai /
selection=rsquare start=8 stop=9 mse aic bic press cp adjrsq jp;
run;

*===================================================================================================;
*DIAGNÓSTICO DE HOMOSCEDASTICIDADE;

*Gráfico resíduos vs preditos;
ods graphics on / reset = all height=8 in width=8 in border=off ;
ods listing image_dpi=300 gpath="D:\Estatística\REGRESSÃO\Trabalho\Latex";
ods graphics / imagename = "res_pred_geral_sempai";
proc sgplot data=resid_pred1;
	scatter y=Residual x=PredictedValue/
markerattrs=(symbol=circlefilled color=black);
refline 0/lineattrs=(color=red thickness=3);
xaxis grid; 
yaxis grid; 
run;
ods listing close;

*Breusch Pagan e White;
ods trace on / listing;
proc model data=dados;
parms beta0 beta1 beta3 beta4 beta5 beta6 beta7 beta9 beta10 beta11;
pesonasc=beta0+beta1*diacabeca+beta3*idadegest+beta4*idademae+beta5*numcigmae+
beta6*alturamae+beta7*pesomae+beta9*escpai+beta10*numcigpai+beta11*alturapai;
fit pesonasc/white breusch=(1 diacabeca idadegest idademae numcigmae
alturamae pesomae escpai numcigpai alturapai);
ods output HeteroTest=white_pagan1;
run;
ods trace off;

ods _all_ close;options printerpath=png nodate papersize=('12cm','6cm');
ods noptitle;title;
ods printer file="D:\Estatística\REGRESSÃO\Trabalho\Latex\white_pagan1.png" 
dpi=400 style=myAnalysis;
proc print data=white_pagan1(drop=equation EstType) noobs;
run;
ods printer  close; 

*===================================================================================================;
*Indep�ncia dos res�duos;

* testes de normalidade;
ods _all_ close;options printerpath=png nodate papersize=('10cm','6cm');
ods noptitle;title;
ods printer file="D:\Estatística\REGRESSÃO\Trabalho\Latex\erro_normal.png" 
dpi=400 style=myAnalysis;
ods trace on / listing;
ods exclude Moments BasicMeasures TestsForLocation Quantiles ExtremeObs; *Excluir outputs indesejados;
proc univariate data=resid_pred normal;
 var residual;
run;
ods trace off;
ods printer  close; 

*QQ Normal plot 2;
proc kde data=resid_pred out=den;
  var residual;run;
proc sort data=den;
  by residual;run;
symbol1 c=blue i=join v=none height=1;
proc gplot data=den;
  plot density*residual=1;
run;quit;
goptions reset=all;
ods graphics on / reset = all height=8 in width=8 in border=off ;
ods listing image_dpi=300 gpath="D:\Estatística\REGRESSÃO\Trabalho\Latex";
ods graphics / imagename = "qqplot";
proc univariate data=resid_pred normal;
 var residual;
 qqplot residual / normal(color=black mu=est sigma=est l=1);
run;
ods listing close; 

*===================================================================================================;
* Crit�rios de sele��o de vari�veis;
ods trace on / listing;
proc reg data=dados;
	model pesonasc = diacabeca idadegest idademae idade pai numcigmae
alturamae pesomae escpai numcigpai alturapai
/selection=rsquare start=2 stop=11 mse aic bic press cp adjrsq jp;
ods output SubsetSelSummary=selecao(drop=ModelIndex dependent model RSquare Control);
run;
ods trace off;
* Exportando as estat�sticas para sele��o;
ods _all_ close;options printerpath=png nodate papersize=('20cm','25cm');title;
*ods printer file="D:\Estatística\REGRESSÃO\Trabalho\Latex\selecao.png" 
dpi=400 style=myAnalysis;
proc print data=selecao noobs;
run;
ods printer close;

*======================================;
*Criando um score para escolha dos melhor modelo;
*R� ajustado;
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
*BIC;
proc sort data=selecao;by descending Jp;run;
data selecao;set selecao;
Jpscore=_N_;run;
*EQM;
proc sort data=selecao;by descending MSE;run;
data selecao;
set selecao;SSEscore=_N_;run;
*Soma dos scores;
data rank_final(keep=VarsInModel numinmodel rank cp);set selecao;
rank=sum(rajscore,AICscore,BICscore,SSEscore);
run;
proc sort data=	rank_final;by descending rank;run;

*===================================================================================================;
* Verificando a existência de pontos influentes;
ods listing gpath="C:\Users\Furriell\Documents\SAS";
ods graphics on;
proc reg data=dados plots(label)=all;
	id identifica__o;
	model pesonasc = diacabeca idadegest
	numcigmae alturamae pesomae alturapai/r influence;
	ods output OutputStatistics=saida;
	ods output ParameterEstimates=estimativas;
run;
ods html close;
ods trace off;

*===================================================================================================;
*===================================================================================================;
*===================================================================================================;

* Avaliação dos modelos finais;

*===================================================================================================;
*===================================================================================================;
*===================================================================================================;

ods _all_ close;options printerpath=png nodate papersize=('18cm','6cm');
ods noptitle;title;
ods printer file="D:\Estatística\REGRESSÃO\Trabalho\Latex\selecionados.png" 
dpi=400 style=myAnalysis;
proc print data=rank_final(obs=5) noobs;
run;
ods printer  close; 

%macro reg_final(vars=);
proc reg data=dados;
	model pesonasc = &vars;
run;
%mend;

%reg_final(vars=diacabeca idadegest numcigmae alturamae pesomae alturapai);
%reg_final(vars=diacabeca idadegest idademae numcigmae alturamae pesomae alturapai);
%reg_final(vars=diacabeca idadegest numcigmae alturamae pesomae escpai alturapai);
%reg_final(vars=diacabeca idadegest numcigmae alturamae pesomae numcigpai alturapai);
%reg_final(vars=diacabeca idadegest idademae numcigmae alturamae pesomae escpai alturapai);

*Comparando os melhores modelos;

proc reg data=dados;
model pesonasc = diacabeca idadegest idademae numcigmae alturamae pesomae alturapai/SS2;
teste1: test idademae=0;
run;

