clc;
clear;
close all;

%%
h=19.6e-3;
h_s=0.8e-3;
w_c=10e-3;
e_r=3.35; %Rogers
%e_r=1; %luft
w_0=298e6*2*pi;
c=300e6;
l=125e-3;
Z0=50;
N=2;

%e_r=1/((1/e_r1)*(h_s/h)+(1/e_r2)*((h-h_s)/h));

if (w_c/h)<=1
    e_e=(e_r+1)/2+(e_r-1)/(2*sqrt(1+(12*h/w_c)))+0.02*(e_r-1)*(1-w_c/h)^2; %Zhang2001 
else 
    e_e=(e_r+1)/2+(e_r-1)/(2*sqrt(1+(12*h/w_c)));
end

k_0=w_0*sqrt(1.257e-6*8.854e-12);
beta=k_0*sqrt(e_e); %Wikipedia

C_T=(sin(beta*l/N))/(w_0*Z0*(1-cos(beta*l/N)));
C_S=1/2*C_T;
