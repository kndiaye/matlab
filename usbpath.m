function [USBDIR]=usbpath()
% USBPATH - Retrieves directory of the USB drive on the current OS
USBDIR='';
[hostname,hostname]=system('hostname');
switch upper(deblank(hostname))
    case 'KARIMND'
        USBDIR = 'I:/';
    case 'LENA138.LENA.CHUPS.JUSSIEU.FR'
        USBDIR = '/mount/usb/';
end
