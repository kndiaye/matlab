disp('************************************************')
disp('*                                              *')
disp('*              BUGS in Matlab                  *')
disp('*                                              *')
disp('************************************************')

disp(['Version: ' version])

disp('------------------------------------------------')
disp('Matrix product is ill defined for "empty" arrays')
A=ones(2,0)
B=ones(0,3)
disp('A*B=')
A*B
disp('------------------------------------------------')



disp('------------------------------------------------')
disp('Matrix product is ill defined for "empty" arrays')
A=ones(2,2)
disp('A(:,[])*A(:,[])'' =')
A(:,[])*A(:,[])'
disp('size(A(:,[]))')
size(A(:,[]))
disp('------------------------------------------------')


disp('------------------------------------------------')
disp('  Inconsistent logics due to If short circuit')
disp(' if 1 | [] ; ''T'' , else ''F'',end ')
if 1 | [] ; disp('T') , else disp('F'), end
disp(' if [] | 1 ; ''T'' , else ''F'', end ')
if [] | 1 ; disp('T') , else disp('F'), end

disp('------------------------------------------------')
disp('  Inconsistent logics due to scalar expansion')
disp(' 1 == [] ')
1 == []
disp(' [] == 1 ')
[] == 1
disp(' [ 1 & [] ] ')
[ 1 & [] ]
disp(' [ [] & 1 ] ')
[ [] & 1 ]
disp(' [ 1 | [] ] ')
[ 1 | [] ]
disp(' [ [] | 1 ] ')
[ [] | 1 ]
% disp(' [ 1 || [] ] ')
% [ 1 || [] ]
% disp(' [ [] || 1 ] ')
% [ [] || 1 ]



disp('------------------------------------------------')
disp('      Fields of empty arrays of structs')
a=dir
b=a([]);
disp('b=setfield(a([]),''test'', [])')
try
b=setfield(b,'test', [])
catch ME
    disp('Error:')
    disp(ME.message)
end
    


% $$$ Groupes de discussion : comp.soft-sys.matlab
% $$$ De : Scott French <s...@frenchslinux.dhcp> - Rechercher les messages de cet auteur
% $$$ Date : 2000/09/13
% $$$ Objet : Re: if (1 | []) : inconsistencies?
% $$$ 
% $$$ Eric,
% $$$ 
% $$$ There are a couple of issues interacting here. First, there's scalar
% $$$ expansion. In an expression of the form
% $$$ 
% $$$ Scalar OPERATOR Matrix
% $$$ 
% $$$ Scalar is replaced by a matrix with the same dimensions as Matrix, and
% $$$ whose every element is Scalar. Then the operator's operation is
% $$$ performed. Applying this to the expression
% $$$ 
% $$$ 1 | []
% $$$ 
% $$$ You get the value 1 replaced by a matrix with the same dimensions as
% $$$ [], in other word, an empty matrix. So 1 | [] evaluates to [] | [],
% $$$ which is [].
% $$$ 
% $$$ Second, IF treats the empty matrix conditional as false. It probably
% $$$ should be treated as true, since technically every element of the
% $$$ empty matrix (what few of them there are) is nonzero. It was
% $$$ implemented with empty treated as false a long time ago, and when we
% $$$ tried to change it a few years ago we found that we broke such a large
% $$$ amount of code (just among the M-code in MATLAB and our toolboxes)
% $$$ that we decided it would cause more problems for our customers if we
% $$$ fixed it than if we left it alone.
% $$$ 
% $$$ Thirdly, in MATLAB 5.0, we added short circuited conditionals for IF
% $$$ and WHILE if the left hand side of the conditional is a
% $$$ scalar. Unfortunately, at the time, we didn't realize that empty
% $$$ matrices and scalar expansion violate a requirement for short
% $$$ circuiting. That is, in order to short circuit,
% $$$ 
% $$$ 1 | X == 1
% $$$ 
% $$$ has to be true for all values of X. If X is the empty matrix, though,
% $$$ then the requirement fails. Its worth pointing out that even if IF
% $$$ treated [] as true, we would still have a problem because to short
% $$$ circuit logical AND, you need
% $$$ 
% $$$ 0 & X == 0
% $$$ 
% $$$ to be true for all X, and if [] is treated as true, then this fails
% $$$ for X equal to [] as well.
% $$$ 
% $$$ Since short circuited conditionals have been part of MATLAB since
% $$$ version 5.0, we have the same issue as before, that is, maintaining
% $$$ backward compatibility versus improving/fixing the MATLAB language.
% $$$ 
% $$$ So now at least you know what is going on. You are the first person
% $$$ that I know of to state the issue as succinctly as you have, and as a
% $$$ result a bunch of us here are now in deep meditative trances trying to
% $$$ decide what the right thing to do is. In the meantime, if having [] be
% $$$ treated as false is a problem for you, you can pass conditional
% $$$ expressions that could potentially be empty through the ALL function
% $$$ first. If the short circuiting is a problem, you could call the
% $$$ functional form of OR, like this
% $$$ 
% $$$ if (or(1,[])), disp('T'), else disp('F'), end % F
% $$$ 
% $$$ I hope these suggestions are helpful.
% $$$ 
% $$$ Sincerely,
% $$$ Scott French
% $$$ Software Engineer
% $$$ 
% $$$ - Masquer le texte des messages pr?c?dents -
% $$$ - Afficher le texte des messages pr?c?dents -
% $$$ Eric Durant <edur...@umich.edu> writes:
% $$$ > After reading 2-12 ff. and 2-398 ff. in the Matlab Function Reference,
% $$$ > Volume 1, Version 5, I expect all of the following to give the same
% $$$ > result ('T'), but they don't.  Is this a bug or documentation error, or
% $$$ > have I missed something?
% $$$ 
% $$$ > expr=(1|[]); if expr , disp('T'), else disp('F'), end % F
% $$$ > expr=([]|1); if expr , disp('T'), else disp('F'), end % F
% $$$ >              if(1|[]), disp('T'), else disp('F'), end % T
% $$$ >              if([]|1), disp('T'), else disp('F'), end % F
% $$$ >         if(all(1|[])), disp('T'), else disp('F'), end % T
% $$$ >         if(all([]|1)), disp('T'), else disp('F'), end % T

% $$$ > I've tested this with R11.1 on PCWIN and SOL2.
% $$$ 
% $$$ > -- Eric Durant
% $$$ >    http://edurant.com/
% $$$ 
% $$$ -- 
% $$$ Scott French             E-mail - s...@mathworks.com
% $$$ The MathWorks, Inc.      WWW - http://www.mathwor