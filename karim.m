%donnee
[Channel,F,imegsens,ieegsens,iothersens,irefsens,grad_order_no,no_trials,filter,Time, RunTitle] = ds2brainstorm(fic_ds,0);
%1er essai
champ=F{1};
%MEG
champ_meg   = champ(imegsens,:);
%EEG
champ_eeg   = champ(ieegsens,:);

%maillage (.tri)
[noeud,face,n_noeud,n_face]	= lfictri(fic_tri);-----------> 120000 noeuds

%matrice de gain et maillage format olivier
load(fic_gain)      gain_5000.mat
-->vmat  [imegsens,n_noeud]
load(fic_maillage)  maillage_5000.mat
-->noeud, face,xyz=noeud(1:3,:), voisin (voisinage des noeuds), aire (surface des dipoles)

%minimum norm
[[J_meg;J_oculaire],residus]   = mne(champ_meg,[vmat oculaire],lambda);
lambda  = 1e-4;    (explique pratiquement toutes les donnees)

%projection
meg_corrige = vmat*J_meg;

%svd
[U,S,V] = svd(champ_oculaire);
%vecteurs spatiaux V horizontal (a verifier)
