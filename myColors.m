function [Couleur] = myColors()
% myColors() renvoie un Cell permettant d'automatiser les couleurs des plots pour chaque condition
% e.g. couleur=myColors; plot(x,y, couleur{1}) pour la condition i (où i=1:5)
Couleur={ {'Color', [0 0 0]} , {'Color', [1 0 0]} , {'Color', [0 0 1]} , {'Color', [0 1 0]} , {'Color', [1 0 1]} }
