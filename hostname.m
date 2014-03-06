function h=hostname()
[h,h]=system('hostname');
h=deblank(h);

