%Yutao Han - Cornell University
%11.17.2017
%testing SM Kernel

%%
clear all; close all;

tic 

% load airlinedata
% x=xtrain;
% y=ytrain;
% xstar=xtest;

% load tempdata.txt
% xtrain=tempdata(:,1);
% ytrain=tempdata(:,2);
% x=xtrain;
% y=ytrain;
% xtest=[95:135]';
% xstar=xtest;
% xtest=x;
% xstar=xtest;

gg1=[-15:.2:-5]';
yy1=sinc(gg1+10);
gg2=[5:.2:15]';
yy2=sinc(gg2-10);
xtrain=[gg1;gg2];
ytrain=[yy1;yy2];
x=xtrain;
y=ytrain;
xtest=[-5:.2:5]';
xstar=xtest;


[N,D]=size(x);%Dimension of input "x"
Q=10;%Number of Gaussian Mixture Components

nlml=Inf;
n_it=10;

for j=1:n_it
flag=0;
log_hyp_init=initSMhypersadvanced(Q,x,y,flag);
%function hypinit = initSMhypersadvanced(Q,x,y,flag)
%log_hyp_init=initSMhypers(Q,x,y);%initialise SM hyperparameters
%function hypinit = initSMhypers(Q,x,y)
%hypinit(1:Q) = log(w); weights
%hypinit(Q+(1:Q*D)) = log(m(:)); frequencies
%hypinit(Q+Q*D+(1:Q*D)) = log(s(:)); length scales

aa=10;
bb=40;
sigma_n_init=(bb-aa)*rand+aa;
%sigma_n_init=15;%intial guess for noise, need smarter way to initialize sigma_n_init
                  %for non-noise models this should be close to zero
log_hyp_init=[log_hyp_init; log(sigma_n_init)];

shortrun=100;%short run function evaluations

k=@covSMfast;%cov function handle

log_hyp_opt=minimize(log_hyp_init,'NLP_SM',-shortrun,x,y,k,Q,D);
%log_hyp_opt=minimize(log_hyp_init,'NLP_SM_nonoise',-shortrun,x,y,k,Q,D);

%function [nlml, dnlml] = NLP_SM_nonoise(log_hyp,x,y,k,Q,D)
%[nlml_new, dnlml] = NLP_SM_nonoise(log_hyp_opt,x,y,k,Q,D);
%function [nlml, dnlml] = NLP_SM(log_hyp,x,y,k,Q,D)
[nlml_new, dnlml]=NLP_SM(log_hyp_opt,x,y,k,Q,D);

if (nlml_new < nlml)%replace the initialized hyperparameters, if better nlml achieved
    log_hyp_proc = log_hyp_opt;
    nlml = nlml_new;
end

print_j=j
end

%after initializing hyperparameters, marginalize over them
longrun=1000;
%log_hyp_opt=minimize(log_hyp_proc,'NLP_SM_nonoise',-longrun,x,y,k,Q,D);
log_hyp_opt=minimize(log_hyp_proc,'NLP_SM',-longrun,x,y,k,Q,D);

%now given final optimized hyperparameters, do prediction
%find E, and Cov
%[E,Cov]=SM_pred_nonoise(log_hyp_opt,x,y,xstar,k,Q,D);
[E,Cov]=SM_pred(log_hyp_opt,x,y,xstar,k,Q,D);

y_star_pred=E;
SD_star_pred=sqrt(diag(Cov));

toc

figure
%plot confidence bounds
ci_colour=[7 7 7]/8;
lower=y_star_pred-2*SD_star_pred;
upper=y_star_pred+2*SD_star_pred;
ciplot(lower,upper,xstar,ci_colour)
hold on
plot(xtrain,ytrain,'b','LineWidth',2);%plot training data
% plot(gg1,yy1,'b','LineWidth',2);%plot training data
% hold on
% plot(gg2,yy2,'b','LineWidth',2);%plot training data
% hold on
%plot(xtest,ytest,'g','LineWidth',2);%plot test data
%hold on
plot(xstar,y_star_pred,'k','LineWidth',2);%plot predicted data

%%
%check derivatives
% check_params=log_hyp_init;
% check_params(end)=.00005;
% checkgrad('NLP_SM_nonoise', check_params, 1e-5,x,y,k,Q,D)
%%
[nlml, dnlml,M,inv_M,log_det_M] = NLP_SM_nonoise(log_hyp_opt,x,y,k,Q,D);
