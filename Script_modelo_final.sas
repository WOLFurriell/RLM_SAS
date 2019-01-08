*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
*===================================================================================================;
* O MODELO FINAL;
*===================================================================================================;
ods _all_ close;options printerpath=png nodate papersize=('18cm','20cm');title;
*ods printer file="D:\Estatística\REGRESSÃO\Trabalho\Latex\reg_final.png" 
dpi=400 style=myAnalysis;
ods exclude NObs DiagnosticsPanel ResidualPlot ResidualPlot; 
proc reg data=dados;
	model pesonasc = diacabeca idadegest numcigmae alturamae pesomae alturapai;
run;
ods printer  close; 
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
* Multicolinearidade;

ods trace on / listing;
ods output ParameterEstimates=multicolinearidade(keep=variable label VarianceInflation tolerance);
proc reg data=dados;
	model pesonasc = diacabeca idadegest numcigmae alturamae pesomae alturapai/
collin vif tol p r;
ods output OutputStatistics=pred_resid_final;
run;
ods trace off;

ods _all_ close;options printerpath=png nodate papersize=('10cm','6cm');
ods noptitle;title;
*ods printer file="D:\Estatística\REGRESSÃO\Trabalho\Latex\multicolin_final.png" 
dpi=400 style=myAnalysis;
proc print data=multicolinearidade(rename=(VarianceInflation=VIF)) noobs;
run;
ods printer  close; 

*Painel de diagn�sticos;
ods graphics on / reset = all height=8 in width=8 in border=off ;
*ods listing image_dpi=300 gpath="D:\Estatística\REGRESSÃO\Trabalho\Latex";
ods graphics / imagename = "painel";
ods exclude NObs ANOVA FitStatistics ParameterEstimates ResidualPlot ResidualPlot; 
proc reg data=dados;
	model pesonasc = diacabeca idadegest numcigmae alturamae pesomae alturapai;
run;
ods listing close;

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
*Homoscedasticidade;

*Gr�fico res�duos vs preditos;
ods graphics on / reset = all height=8 in width=8 in border=off ;
*ods listing image_dpi=300 gpath="D:\Estatística\REGRESSÃO\Trabalho\Latex";
ods graphics / imagename = "res_pred_geral";
proc sgplot data=resid_pred;
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
parms beta0 beta1 beta3 beta4 beta5 beta6;
pesonasc=beta0 + beta1*diacabeca + beta2*idadegest + beta3*numcigmae + beta4*alturamae + 
beta5*pesomae + beta6*alturapai;
fit pesonasc/white breusch=(1 diacabeca idadegest numcigmae alturamae pesomae alturapai);
ods output HeteroTest=white_pagan_final;
run;
ods trace off;

ods _all_ close;options printerpath=png nodate papersize=('12cm','4cm');
ods noptitle;title;
*ods printer file="D:\Estatística\REGRESSÃO\Trabalho\Latex\white_pagan_final.png" 
dpi=400 style=myAnalysis;
proc print data=white_pagan1(drop=equation EstType) noobs;
run;
ods printer  close; 

*Gráfico resíduos vs preditos;
ods graphics on / reset = all height=8 in width=8 in border=off ;
*ods listing image_dpi=300 gpath="D:\Estatística\REGRESSÃO\Trabalho\Latex";
ods graphics / imagename = "res_pred_final";
proc sgplot data=pred_resid_final;
	scatter y=Residual x=PredictedValue/
markerattrs=(symbol=circlefilled color=black);
refline 0/lineattrs=(color=blue thickness=3);
xaxis grid; 
yaxis grid; 
run;
ods listing close;

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
*Indepência dos resíduos;
* testes de normalidade;
ods _all_ close;options printerpath=png nodate papersize=('10cm','6cm');
ods noptitle;title;
*ods printer file="D:\Estatística\REGRESSÃO\Trabalho\Latex\erro_normal_final.png" 
dpi=400 style=myAnalysis;
ods trace on / listing;
ods exclude Moments BasicMeasures TestsForLocation Quantiles ExtremeObs; *Excluir outputs indesejados;
proc univariate data=Pred_resid_final normal;
 var residual;
run;
ods trace off;
ods printer  close; 

*QQ Normal plot 2;
proc kde data=Pred_resid_final out=den;
  var residual;run;
proc sort data=den;
  by residual;run;
symbol1 c=blue i=join v=none height=1;
proc gplot data=den;
  plot density*residual=1;
run;quit;

ods graphics on / reset = all height=8 in width=8 in border=off ;
*ods listing image_dpi=300 gpath="D:\Estatística\REGRESSÃO\Trabalho\Latex";
ods graphics / imagename = "qqplot_final";
proc univariate data=Pred_resid_final normal;
 var residual;
 qqplot residual / normal(color=black mu=est sigma=est l=1);
run;
ods listing close; 

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

*retirando os pontos influentes pelas estatatísticas;
*opções de plot (CooksD RStudentByLeverage DFFITS DFBETAS);
proc reg data=dados plots(label)=(DFFITS);
	id identifica__o;
	model pesonasc = diacabeca idadegest
	numcigmae alturamae pesomae alturapai;
	reweight Rstudent.>3;
	reweight h.>0.02;
run;

*retirando os pontos influentes por caso;
proc reg data=dados plots(label)=(RstudentByleverage);
	id identifica__o;
	model pesonasc = diacabeca idadegest
	numcigmae alturamae pesomae alturapai/r influence;
	reweight identifica__o=442;
	reweight identifica__o=436;
	ods output OutputStatistics=saida;
run;

*Gráfico de leverage;
data saida;
set saida;
Label = identifica__o;
if HatDiagonal < 0.025 and RStudent < 3 then
   Label = " ";
run;

proc sgplot data = saida;
scatter x = HatDiagonal y = RStudent/datalabel=Label 
markerattrs=(symbol=circlefilled color=black);
refline 0.023/axis=X lineattrs=(color=red thickness=1);
refline 3/axis=Y lineattrs=(color=red thickness=1);
xaxis grid; 
yaxis grid; 
run;

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
*modelo sem os pontos influentes;
data dados_out;
merge saida dados;
by identifica__o;
run;

data dados_out;
set dados_out;
Label = identifica__o;
if ((HatDiagonal > 0.025) or (RStudent>3) and (DFFITS>0.02 and DFFITS<(-0.02))) then Label="out";
if label NE "out" then delete;
run;

proc print data=dados_out(keep=identifica__o) noobs;
run;

*++++;
proc reg data=dados_out;
	model pesonasc = diacabeca idadegest
	numcigmae alturamae pesomae alturapai;
	ods output ParameterEstimates=estimativas2;
run;
data estimativas2(keep=Label Estimate Probt StdErr 
rename=(Label=label2 estimate=estimate2 probt=probt2 StdErr=StdErr2));
set estimativas2;
run;
data estimativas(keep=Estimate Probt StdErr);
set estimativas;
run;
data comparacao;
retain probt2 StdErr2 estimate2 label2 Estimate StdErr Probt;
set estimativas;
set estimativas2;
run;
*comparacao das estimativas dos modelos com e sem pontos influentes;
ods _all_ close;options printerpath=png nodate papersize=('12cm','8cm');
ods noptitle;title;
*ods printer file="D:\Estatística\REGRESSÃO\Trabalho\Latex\comparacao.png" 
dpi=400 style=myAnalysis;
proc print data=comparacao noobs;
run;
ods printer  close; 

*Verificando os modelos e realizando as comparações;


proc reg data=Dados;
	model pesonasc = diacabeca idadegest
	numcigmae alturamae pesomae alturapai;
reweight identifica__o=436;
reweight identifica__o=17;
run;




