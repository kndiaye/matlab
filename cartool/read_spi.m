function [XYZ]=read_spi(spifile)
%read_ris() - reads SPI Solution Points Irregularly spaced file (Cartool)
%   [XYZ]=read_spi(spifile)
[XYZ(:,1) XYZ(:,2) XYZ(:,3)]=textread(spifile,'%f %f %f');