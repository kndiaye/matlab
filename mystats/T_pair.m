function [] = T_pair(dat,tail,B)
%T_paired(dat,tail,B) produce p-values per la verifica dellipotesi di uguaglianza in
%media di due campioni appaiati.
%
%Parametri in ingresso:
% dat= matrice di dati
% tail direzine delle alternative (vettore 1 X numero di varibili)
%	    tail =   1, alternativa: "media1 > 0" 
%	    tail =  -1, alternativa: "media1 < 0."
% B = Numero permutazioni 
%
%ATTENZIONE!!! disporre i dati in modo 'X-Y'; ovvero inserire la matrice delle differenze delle misurazioni tra il 
%               il tempo 1 e il tempo 2.
%
%By DEFALUT: tail=-1, B=1000;
%
%
%References: Pesarin, F.(2001) Multivariate Permutation Test with Application in Biostatistcs. Wiley, New York.
%
%Livio Finos, Dipartimento di Sci. Statistiche - Università di Padova.
%versione 2.0, 	16 Marzo 2003.


 ora=cputime;
if nargin == 1
   tail=-ones(1,size(dat,2));
   B=1000;
end

[n n_var]=size(dat);

% calcolo stat test per dati osservati
Tperm((B+1),:)=  mean(dat) ./ (std(dat) ./ sqrt(n));


% calcolo stat test per B permutazioni
for i=1:B
   perm=repmat(2.*binornd(1,.5,n,1)-1,1,n_var);
   Tperm(i,:)= mean(perm.*dat) ./ (std(perm.*dat) ./ sqrt(n)) ;
end
%Tperm
%cambio segni delle statistiche a seconda della direzione della ipotesi alternativa in modo che a
%valori alti della stat test corrispondano p-value bassi (significativi).

for i=1:n_var
   if tail(i)==0
      Tperm(:,i)=abs(Tperm(:,i));
   else
      Tperm(:,i)=Tperm(:,i).*tail(i);
   end
end



%[NULL Index]=sort(Tperm,1);
%for j=1:n_var
%      rango(Index(:,j),j)=((B+1):-1:1)';
%end
%clear NULL Index;
%
%
%decommentare le precedenti righe e commentare le successive 5 per ottenere un algoritmo più veloce (e corretto) 
%ma meno buono nel caso di valori (nei dati di origine) ripetuti, sempre buono per dati continui 
%(o con buona approssimazione al continuo).

%calcolo del p-value per ogni valore della matrice di statistiche test Tperm (B+1)Xn_var.
for i=1:B+1
   for j=1:n_var
      rango(i,j)=sum(Tperm(i,j)<=Tperm(:,j));
   end
end


rango=rango/(B+1);


%calcolo dei valori delle funzioni di combinazione.

   TpermTipp= max(1-rango,[],2);
   TpermFish= -2*(sum(log(rango),2));
   Ninv=norminv(1-rango);
   TpermLipt= sum(Ninv,2);


%calcolo del p-value dei test combinati
rangoFish=sum(TpermFish(B+1)<=TpermFish)/(B+1);
rangoTipp=sum(TpermTipp(B+1)<=TpermTipp)/(B+1);
rangoLipt=sum(TpermLipt(B+1)<=TpermLipt)/(B+1);

   
%output.
 time=cputime-ora;   
   fprintf('\n Numerosità del campione: %3.0f ', n);
      fprintf('\n \n');
      
   fprintf(' Direzione delle ipotesi alternative \n \t');
   for var=1:n_var
      fprintf('var %3.0f \t',var);
   end
   fprintf('\n \t');
   for var=1:n_var
      fprintf('%3.0f \t \t',tail(var));
   end
   fprintf('\n \n');
   
   fprintf(' Numero Permutazioni= %3.0f. \t  Tempo: %3.2f. \n \n',B,time);

   
   fprintf(' p-values parziali \n');
   for var=1:n_var
      fprintf('\t var %3.0f ',var);
   end
      fprintf('\n \t');
      
   for var=1:n_var
         fprintf(' %3.4f \t',rango(B+1,var));
   end
      fprintf('\n');
   
    fprintf('\n \n p-value Globale \n');
  
   fprintf('\t FISHER \t \t %3.4f \n',rangoFish);
   fprintf('\t TIPPETT \t \t %3.4f \n',rangoTipp);
   fprintf('\t LIPTAK \t \t %3.4f \n 	 ',rangoLipt);
   fprintf('\n \n \n \n');
      


%pval=[rango(B+1,:) rangoFish rangoTipp rangoLipt];