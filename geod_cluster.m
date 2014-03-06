function [GD,TC, GDbis, PCL]=geod_cluster(VC, Coord, SS)

% function [GD, TC, GDbis, PCL] = geod_cluster(VC , Coord, SS )
% la function geodbis est la fonction geod qui 
% construit - à partir du vecteur de connectivité VC et du 
% tableau Coord des coordonnées de chacune des sources (c'est le FV.vertices) - les distances géodésiques 
% de chacune des sources aux graines de la liste SS.
%
% 
% 'GD' sera le tableau des distances géodésiques de chacune de nos sources
% à chacune des graines
% 'TC' sera le tableau donnant les no de chacune des sur-parcelles
% auxquelles appartiennent chacune des sources
% 'GDbis' est la liste des distances (GDbis(s,1)) de chacune des sources s a sa graine la
%  plus proche (GDbis(s,2))
%  PCL est la liste des sources de chacune des parcelles


K=size(SS,1);            %nombre de graines

nv= size(Coord, 1);     % nombre de sources
TC = cell(nv,1);    % la 'cell' TC sera la liste des sur-parcelles dont
                    % fait partie chaque source, initialisée au vide.
                   
Vis = zeros(nv,1);    % Vis[i] indique si la source i a déjà été visitée
                    
PH = cell(K,1);      % PH sera une structure cell de taille K x dmax x Nmax qui sera le 
                    % tableau de "piles hierarchiques" de G. Flandin. 
                    % Attention: dans la colonne d de PH(k) on a les
                    % sources à la distance d-1 (en mm)

infty = 10000;                    
                    
GD = infty*ones(K,nv);  % tableau des distances géodésiques de la source i à 
                        % la graine k (en mm). Il est initialisé à infty, qui
                        % est pour nous la distance infinie (on pourrait
                        % plutot prendre un 'sparse' mais bon...)

GDbis = ones(nv,2);     % nous donne pour chaque source s, sa graine la plus 
                        % proche GDbis(s,2), et la distance a cette graine GDbis(s,1)                   
                        
                        
PCL = cell(K,1);        % liste de chacune des parcelles, ie pour la graine k les sources associees
                        

GDbis(:,1)=infty*GDbis(:,1);            
GDbis(:,2)=0*GDbis(:,2);

S=SS;

% on initialise les valeurs de nos tableaux pour nos graines

for k=1:K,
    S(k,2)=0;
    TC(S(k,1))={[k]};
    GD(k,S(k,1))=0;
    GDbis(S(k,1),1)=0;
    GDbis(S(k,1),2)=k;
    Vis(S(k,1))=1;
    PH(k,1)={[S(k,1)]};
end





nsv=K ;      % nsv indique le nombre de sources visitées, initialisé à K car 
            % les graines ont déjà été visitées

d=0 ;        % d est la distance à laquelle on se trouve dans nos piles hierarchiques   
            
while nsv<nv,       % tant qu'on n'a pas visite toutes les sources (on affinera apres, 
                    % on arretera la boucle quand chaque source aura ete
                    % visitée p fois (p=3,4,...,K?))
    
        nsf=0;                  % ce sera le nb de k tq (d<size(PH(k,:),2)). s'il est egal à 0 
                                % à la fin ca veut dire que tous nos
                                % voisins ont ete visite donc on peut
                                % s'arreter.
 %   nsv2=nsv;                                
                                
    for k=1:K 
        
        if (d<size(PH(k,:),2))
        
            nsf=nsf+1;
            
        for s=1:size(PH{k,d+1},2)
            ss=PH{k,d+1}(s);
            for v = 1:size(VC{ss},2)     % la on regarde chaque voisin de notre source S
                V = VC{ss}(v);
                de=0;
                for i=1:3
                    de=de+(Coord(ss)-Coord(V))^2;
                end 
                dist = floor( d + 1000*sqrt(de));        %on a la distance en millimetres
        %        dist = floor( d + sqrt(de));
                k;
                dist2 = GD(k,V);
               
                if dist<GDbis(V,1)
                    GDbis(V,1)=dist;
                    GDbis(V,2)=k;
                end
                
                if dist<dist2
                    GD(k,V)= dist ;          
                    
                    if(dist>S(k,2)),
                        S(k,2)=dist;
                        PH(k,dist+1)={[V]};
                    else    
                        PH(k,dist+1)={[PH{k,dist+1},V]};
                    end    
                    
                    
                    if dist2<infty         % si le voisin regardé n'est pas à l'infini il faut
                                            % l'enlever de la pile où il était auparavant
                        q=1;
                        while PH{k,dist2+1}(q)~=V
                            q=q+1;
                        end
                        
                        PH{k,dist2+1}=PH{k,dist2+1}(:,(1:end)~=q);
                    end
                end
                
                
                if Vis(V)==0         % si on a jamais visite cette source, on note la pcl k et on 
                    TC(V)={[k]}  ;     % signale qu'on vient de visiter cette source
                    Vis(V)=1    ;
                    nsv=nsv+1   ;
                    
                    
                        
                else 
                    if dist2==infty          % si dist2=infty, la source n'a jamais ete visitee par
                        TC(V)={[TC{V},k]};   % la parcelle k, donc on ajoute la pcl k dans la liste.
                    end                      % sinon elle est dans la pcl k donc rien a preciser 
                    
                end
                
       
            end    
        end
        
    end
    end
    
    nsv2=nsv;
    
    if nsf==0
%        nsv2=nsv;
        nsv=nv;
        
    end

    d=d+1;


end    

Nbsourcesnonvisitees= nsv - nsv2;

I=find(GDbis(:,2)==0);


for s=1:nv
    if GDbis(s,2)>0
        PCL(GDbis(s,2))={[PCL{GDbis(s,2)},s]};
    end
end

while Nbsourcesnonvisitees>0

for s=1:nv                                  % c'est juste une boucle rajoutee car je suis tombe 
                                            % sur des sources qui 'boguaient' systematiquement
                                            % sans comprendre pourquoi. Donc on attribue aux sources
                                            % pas suffisamment visitees la mm parcelle que son premier
                                            % voisin. L'indicateur 'nsf' dans le reste du programme 
    l=1;                                    % sert ainsi a eviter les boucles sans fin dues 
                                            % a ces sources a probleme
    
    if GDbis(s,2)==0
    %   s
        while (GDbis(s,2)==0 & (l<size(VC{s},2)+1))                   
            GDbis(s,2)=GDbis(VC{s}(l),2);
            l=l+1;
        end
    %    l
        if GDbis(s,2)==0
            if s<nv
                GDbis(s,2)=GDbis(s+1,2);
            else
                GDbis(s,2)=GDbis(s-1,2);
            end
        end
    
    
        if GDbis(s,2)>0
            for i=1:size(VC{s},2)
                if GDbis(VC{s}(i),2)==0
                    GDbis(VC{s}(i),2)=GDbis(s,2);
                    PCL(GDbis(s,2))={[PCL{GDbis(s,2)},VC{s}(i)]};
                end
            end
            PCL(GDbis(s,2))={[PCL{GDbis(s,2)},s]};
        end
    end
        
end

I=find(GDbis(:,2)==0);
Nbsourcesnonvisitees=size(I,1);

end


