function [I] = ins_c(prenoms, datedenaissance, nir)
% ins_c - Calcul de l'Identification National de Santé, calculé (INS-C)
if nargin<1
    if 1

        prenoms = 'PHILIPPE  ';
        datedenaissance = '610217';
        nir = '1610275754289'
        % Hashage: 73ba73767e7a53da3a85fba9929cf62b9e63d01758deb9bf11e14cc40c58ea81
        % Résultat: 0 833 910 461 279 517 589 8
        % Clé: 58
    else
        prenoms = 'KARIMBABACARJOSEPH';
        datedenaissance = '790111';
        nir = '1790185191067';
    end
end

c = [prenoms(1:10) , datedenaissance , nir];
% SHA-256 hashing:
h=java.security.MessageDigest.getInstance('SHA-256');
h.update(uint8(c));
h = typecast(h.digest,'uint8');

h = h(1:8);
h = dec2bin(h)';
b = h(:)';
uint64(bin2dec(b(13:64)))
b = (uint64(bin2dec(b(1:12)) * 2^(64-12) + bin2dec(b(13:64))))
%I = sprintf('%.1f',double(b)/10000)
%I = I(1:end-2)
%rem((b),10000)
%sprintf('%d',ans)

