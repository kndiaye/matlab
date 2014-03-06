function [varargout]=merror(msg)
% marche pas !
% on voit 'error in merror' appraitre sur l'écran...
[x,idb]=dbstack
if length(x)>1
    idb=2;
end
a=strread(msg, '%s');
msg=[];
for i=1:length(a)
    msg=[msg x(idb).name sprintf(': %s\n', a{i})]
end
error(msg)
if nargout>0
varargout={msg};
end 