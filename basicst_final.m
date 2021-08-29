function [bdist,b95]=basicst_final(rows)
%This function conducts the basic descriptive stats for the main program.

global dbrick

rpn=dbrick(:,5);
a=rpn;
    
%Finding outliers using Pth

sortedrpn=sort(dbrick(:,5));%sorting the RPNs
noneeded=int16(.05*rows);%determining how many values i need for P95
b95=sortedrpn(rows-noneeded);%finding the cut off value

%finding outliers using binomial dist
%creating the variables with which to sort the distribution of classes
classes=int8(sqrt(length(rpn)));  %define the number of classes for the variable
sml=min(rpn);                     %defining the smallest value in a
bg=max(rpn);                      %max value in a
range=bg-sml;                   %range of values in a
csize=range/double(classes);    %class size of values in a


class_cutoffs=[];        %empty array in which to stuff the class values

for i=0:double(classes)-1 %for loop to count the variable class dist
    co=sml+csize*i;
    class_cutoffs=[class_cutoffs co];
end

%counting the distributions of values in each class

dist_counts=[];         %empty array in which to stuff the class counts
for i=1:length(class_cutoffs)%for loop to count the occurrences between each class
    if i==1
        dcount=length(find(rpn<class_cutoffs(1+i)));
    elseif i~=1&i~=length(class_cutoffs)
        dcount=length(find(rpn>=class_cutoffs(i)&rpn<class_cutoffs(i+1)));
    else
        dcount=length(find(rpn>=class_cutoffs(i)));
    end
    dist_counts=[dist_counts dcount];
end

pdist=[];
for ii=1:length(class_cutoffs)
    cum=sum(dist_counts(1:ii))/length(rpn);
    pdist=[pdist cum];
end

cutoffpos=find(pdist>=.95);
bdist=class_cutoffs(cutoffpos(1));

%binominf=[class_cutoffs' dist_counts' pdist'];

end