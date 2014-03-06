function [ output_args ] = respond( input_args )
%RESPOND Summary of this function goes here
%  Detailed explanation goes here
figure(1)
colormap gray
M=zeros(10,10);
F=ones(10,10)*32;
Z=M;
M(3:7,3:7)= ones(5,5)*64;
for i=1:10
    image(Z)
    pause(rand*5+.5)
    %image(M)        
    beep
    drawnow
    tic
    pause
    a(i)=toc
    image(F)
    pause(.2)
end
image(F)      
mean(a)