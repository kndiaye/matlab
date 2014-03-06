% Candidats 2009
% ALAHYANE Nadia	 Admis à concourir
% AMIEZ Celine	 Admis à concourir
% ANTRI Myriam	 Admis à concourir
% BARAKAT Youssef	 Admis à concourir
% BARIK Jacques	 Admis à concourir
% BARRIERE Grégory	 Admis à concourir
% BEGUE Anne	 Admis à concourir
% BENCHENANE Karim	 Admis à concourir
% BENTURQUIA Nadia	 Admis à concourir
% BERANECK Mathieu	 Admis à concourir
% BIDET-ILDEI Christel	 Admis à concourir
% BLANGERO Annabelle	 Admis à concourir
% BOISTEL Renaud	 Admis à concourir
% BOMPAS Aline	 Admis à concourir
% BOUDIN Florian	 Admis à concourir
% BOULENGER Veronique	 Admis à concourir
% BRUEL JUNGERMAN Elodie	 Admis à concourir
% COENEN Olivier	 Admis à concourir
% COLLINS Thérèse	 Admis à concourir
% COPPOLA Vincent	 Admis à concourir
% COQUART Jérémy	 Admis à concourir
% DANGLOT Lydia	 Admis à concourir
% DE CHEVIGNY Antoine	 Admis à concourir
% DE MARGERIE Emmanuel	 Admis à concourir
% DELLEN Babette	 Admis à concourir
% DOLY Stephane	 Admis à concourir
% DUFOUR Valerie	 Admis à concourir
% DULIN David	 Admis à concourir
% DUPIERRIX Eve	 Admis à concourir
% DURAND Jean Baptiste	 Admis à concourir
% EGO-STENGEL Valérie	 Admis à concourir
% ELEORE Lyndell	 Admis à concourir
% FAURE Alexis	 Admis à concourir
% FERNANDEZ Julian	 Admis à concourir
% GENTY Emilie	 Admis à concourir
% GOMEZ Doris	 Admis à concourir
% GOUREVITCH Boris	 Admis à concourir
% GUILLEM Karine	 Admis à concourir
% HADJ-BOUZIANE Fadila	 Admis à concourir
% HANSARD Miles Edward	 Admis à concourir
% HERVE Pierre Yves	 Admis à concourir
% HICHEUR Halim	 Admis à concourir
% HOK Vincent	 Admis à concourir
% HOSY Eric	 Admis à concourir
% HUSKY Mathilde	 Admis à concourir
% HUYS Raoul	 Admis à concourir
% ISEL Frédéric	 Admis à concourir
% IZARD Véronique	 Admis à concourir
% KILAVIK Bjørg Elisabeth	 Admis à concourir
% LEBLOIS Arthur	 Admis à concourir
% LECOURTIER Lucas	 Admis à concourir
% LOPEZ Christophe	 Admis à concourir
% MADDEN Carol	 Admis à concourir
% MAIRESSE Jérome	 Admis à concourir
% MARQUES PEREIRA Patricia	 Admis à concourir
% MENDOZA Jorge	 Admis à concourir
% MICHELENA Pablo	 Admis à concourir
% MICHELET Thomas	 Admis à concourir
% MONTAGNINI Anna	 Admis à concourir
% MORICE Elise	 Admis à concourir
% MUNIER Claire Alice	 Admis à concourir
% NAVAILLES Sylvia	 Admis à concourir
% NAVARRO Jordan	 Admis à concourir
% PARRON Carole	 Admis à concourir
% PASCAL Frédéric	 Admis à concourir
% PASTORINI Chiara	 Admis à concourir
% PATINO VILCHIS Jose Luis	 Admis à concourir
% PIETROPAOLO Susanna	 Admis à concourir
% PLAILLY Jane	 Admis à concourir
% POIRIER Karine	 Admis à concourir
% REGUIGNE-KHAMASSI Mehdi	 Admis à concourir
% RIBOT Jérôme	 Admis à concourir
% ROUSTIT Christelle	 Admis à concourir
% SAGASPE Patricia	 Admis à concourir
% SARLEGNA Fabrice	 Admis à concourir
% SCHIRLIN Olivier	 Admis à concourir
% SELIMBEGOVIC Leila	 Admis à concourir
% SERGENT Claire	 Admis à concourir
% SMADJA Carole	 Admis à concourir
% SNOEREN Natalie	 Admis à concourir
% TAGLIABUE Michele	 Admis à concourir
% TRONEL Sophie	 Admis à concourir
% UPAL Roy	 Admis à concourir
% WARDAK Claire	 Admis à concourir
% WIRTH Sylvia	 Admis à concourir
% YALCIN CHRISTMANN Ipek	 Admis à concourir
clear 
clc
filename=mfilename('fullpath');
nc = 86;
[a ,nom(:,1),nom(:,2)]=textread(filename ,'%s%s%s%*[^\n]',nc, 'headerlines',1);
query = 'http://www.ncbi.nlm.nih.gov/pubmed/search?term=("2000"[Publication%20Date]%20:%20"3000"[Publication%20Date])%20AND%20("%s%%20%s"[au])';
for i=1:nc
%    nom={'Baillet', 'S'}
    q =sprintf(query, nom{i,1},nom{i,2}(1))
    t=urlread(q);
    pmid=findstr('pmid',t); 
    findstr('title',t(pmid(1)+[5:400]))
    return
end 