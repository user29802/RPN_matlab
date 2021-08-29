function [sol,partn,RPNv]=RPNtable_final(varargin)
%This function takes the input for b95 (P95) or bdist and generates the
%list of part numbers and RPN values exceeding the specified input (sol),
%the breakpoint part number (partn), and the associated RPN value (RPNv).

global dbrick

%varargin{1}: b95 or bdist
        %b95 is the tag for P95
        %bdist is the tag for binom.d
        
%varagin{2}: dbrick

%sol is the solution matrix that includes the part number and the RPN;
    %needed for text tabl
%partn is a standalone matrix for the part numbers; needed for figure
%RPNv is a standalone matrix for the RPN; needed for figure
      
a=[find(dbrick(:,5)>=varargin{1})];
sol=[];
for i=1:length(a)
    r=[dbrick(a(i),5)];
    sol=[sol r];
    
end
sol=sol';
sol=[a sol];



partn=sol(:,1);
RPNv=sol(:,2);

end

