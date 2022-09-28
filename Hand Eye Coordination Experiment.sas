data handeye;
  input circle distance hand cycles;
datalines;

1 -1 -1 20
-1 -1 1 15
-1 1 -1 14
1 1 1 20
-1 1 1 12
-1 -1 -1 17
1 1 -1 18
1 -1 1 22
-1 -1 1 16
-1 1 1 15
-1 1 -1 14
1 1 -1 17
1 1 1 21
-1 -1 -1 18
1 -1 1 23
1 -1 -1 21
;
run;

/* ----------------------------------- */
/*  		UNIVARIATE ANALYSIS 	   */
/* ----------------------------------- */
proc univariate data=handeye;
   histogram;
run;

/* ----------------------------------- */
/*  		BIVARIATE ANALYSIS 	   */
/* ----------------------------------- */

/*Box plot */
PROC SGPLOT  DATA = handeye;
   VBOX cycles 
   / category = circle;
   title 'Number of Cycles vs. Circle Size ';
RUN;

/*Box plot */
PROC SGPLOT  DATA = handeye;
   VBOX cycles 
   / category = distance;
   title 'Number of cycles vs. Distance';
RUN;

/*Box plot */
PROC SGPLOT  DATA = handeye;
   VBOX cycles 
   / category = hand;
   title 'Number of cycles vs. Hand Type';
RUN;


/*model 1 with all the interactions*/
proc glm data=handeye;
  class circle distance hand cycles;
    model cycles = circle|distance|hand;
    estimate 'circle' circle -1 1;
    estimate 'distance' distance -1 1;
    estimate 'hand' hand -1 1;
run;

/*model 2 (removed the 3 way interatcions as not signficant)*/
proc glm data=handeye;
  class circle distance hand cycles;
    model cycles = circle distance hand circle*distance circle*hand distance*hand;
run;

/*model 3 (removed all the 2 way interatcions except circle*hand)*/
proc glm data=handeye;
  class circle distance hand cycles;
    model cycles = circle distance hand circle*hand / SOLUTION ALPHA=.05 CLPARM;
    estimate 'circle' circle -1 1;
    estimate 'distance' distance -1 1;
    estimate 'hand' hand -1 1;
	output out=outdat p=yhat r=resid;
	
	means circle*hand/tukey alpha=0.05 cldiff;
	lsmeans circle*hand / tdiff pdiff adjust=tukey stderr;
run;

goptions reset=all;

/*Model Diagnostics*/
symbol1 v=dot c=blue h=1.2;
axis1 label=('RESIDUALS');
axis2 label=(angle=90 'FITTED VALUES');
proc gplot;
  plot resid*yhat;
  title 'Fitted Values against Residuals';
run;

proc univariate data=outdat plot normal;
  var resid;
run;

/* Residual Sequence Plot */
data resids;
  set outdat;
run;

data resids2;
  set resids;
  order = _n_;
run;

proc print data=resids2;
run;

goptions reset=all;
goptions hsize=5;
goptions vsize=4;
proc gplot data=resids2;
  plot resid*order / vaxis=axis1 haxis=axis2 ;
  title2 "Sequence plot of the residuals";
  axis1 label = (a=90 'Residual');
  axis2 label=('Order');
  symbol1 v=dot c=blue h=.8;
run;

/* No need for remedies like box-cox as model assumptions are being satisfied*/

