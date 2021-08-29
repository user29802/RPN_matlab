%primary_new

clear all

%clearing figures 1-6 in case they're currently open
for i=1:6
    a=ishandle(i);
    if a==1
        close(i)
    else
    end
end

global dbrick

%determining the data for the evaluation--mock data if needed for
%demonstration purposes or importing a file if needed

impd='Import file';
mockd='mock data';

[testfout]=testf_final(impd,mockd);

ds=testfout;

if ds==2
    %generating dbrick values if .txt file is not used.
    fprintf('\t\t...Generating data set.\n')
    trash=sprintf('\t\t...Enter number of samples desired. Should be 100<=x<=1000.\n\t\t\t');
    rows=input(trash);
    nrows=int32(rows);
    rowtest=rows-double(nrows);
    
    while rows<100||rows>1000||rowtest~=0
        if rows<100||rows>1000
            fprintf('\t\t...Error: sample size not optimal.\n')
            trash=sprintf('\t\t...Enter number of samples desired. Should be 100<=x<=1000.\n\t\t\t');
            rows=input(trash);
        else
            fprintf('\t\t...Error: sample size is not a whole number.\n')
            trash=sprintf('\t\t...Enter number of samples desired. Should be 100<=x<=1000.\n\t\t\t');
            rows=input(trash);
        end
        nrows=int32(rows);
        rowtest=rows-double(nrows);
    end
        
    [dbrick]=databrick_final(rows);
    
else
    %If a .txt file was selected, the following lines are used. 51-72 open a
    %figure that display the requirements for the .txt file.
    figure(1)
    set(gca,'XColor','none','YColor','none');
    str1={'Rules for imported files:'};
    str2={'1. Input file needs to be named ''input.txt.'''};
    str3={'2. There should be four columns of information:'};
    str4={'Col 1: part number'};
    str5={'Col 2: P(failure)'};
    str6={'Col 3: P(detection)'};
    str7={'Col 4: Severity'};
    str8={'3. Columns must have *spaces* between values.'};
    str9={'4. You must have 100<=x<=1000 rows of data.'};
    
    text(.1,.9,str1, 'Color', 'b','FontSize',12)
    text(.1,.79,str2, 'Color', 'b','FontSize',12)
    text(.1,.68,str3, 'Color', 'b','FontSize',12)
    text(.2,.625,str4, 'Color', 'b','FontSize',12)
    text(.2,.57,str5, 'Color', 'b','FontSize',12)
    text(.2,.515,str6, 'Color', 'b','FontSize',12)
    text(.2,.46,str7, 'Color', 'b','FontSize',12)
    text(.1,.35,str8, 'Color', 'b','FontSize',12)
    text(.1,.24,str9, 'Color', 'b','FontSize',12)
    
    %opens the .txt file and calculates the RPN value column.
    fileID=fopen('input.txt','r');
    data='%f';
    a=fscanf(fileID,data);
    solver=length(a)/4;
    
    val1=[];
    for i=0:solver-1
        a1=a((i*4)+1);
        val1=[val1 a1];
    end
    partno=val1';
    
    val2=[];
    for i=0:solver-1
        a1=a((i*4)+2);
        val2=[val2 a1];
    end
    pfail=val2';
    
    val3=[];
    for i=0:solver-1
        a1=a((i*4)+3);
        val3=[val3 a1];
    end
    pdet=val3';
    
    val4=[];
    for i=0:solver-1
        a1=a((i*4)+4);
        val4=[val4 a1];
    end
    sev=val4';
    rpn=pfail.*pdet.*sev;
    
    dbrick=[partno pfail pdet sev rpn];
    
    %tests the .txt file to make sure that it has the correct parameters.
    %If it does not, it stops the program (because you'll need to fix the
    %file or use the auto-generated values).
    if solver~=length(partno)&solver~=length(pfail)&...
            solver~=length(pdet)&solver~=length(sev)
        fprintf('\t\t...Column lengths not the same or may contain alphanumeric values. Stopping program.\n');
        return
    elseif solver<100|solver>1000
        fprintf('\t\t...Data must be between 100<=x<=1000. Stopping program.\n');
        return
        %elseif
        
    else
    end
    
    %the following lines have two functions: allow you to break the program
    %if you imported a .txt file to evaluate dbrick and allow time to read
    %the figure, in case it closes too soon.
    
    trash=sprintf('\t\t...Press (1) to continue program or (2) to exit.\n\t\t\t');
    z=input(trash);
    if z==2
        close(1)
        return
    else
        close(1)
    end
    
end

%beginning the evaluation

rows=length(dbrick);

%passes dbrick and the number of rows to run the two descriptive stats
[bdist,b95]=basicst_final(rows);

simpmed=median(dbrick(:,5));
simpmean=mean(dbrick(:,5));

%these figs are meant to help determine which stat method might be of most
%interest.
figure(1)
set(gca,'XColor','none','YColor','none');
str1={'Median RPN value: ' num2str(round(simpmed,3))};
str2={'Mean RPN value: ' num2str(round(simpmean,3))};
str3={'Breakpoint value for P95: ' num2str(round(b95,3))};
str4={'Breakpoint value for binom. dist.: ' num2str(round(bdist,3))};
    
text(.1,.8,str1, 'Color', 'b','FontSize',12)
text(.1,.69,str3, 'Color', 'b','FontSize',12)

text(.1,.47,str2, 'Color', 'b','FontSize',12)
text(.1,.36,str4, 'Color', 'b','FontSize',12)

figure(2)
subplot(1,2,1)
hist(dbrick(:,5),30)
title('histogram of RPNs')

subplot(1,2,2)
boxplot(dbrick(:,5))
title('boxplot of RPNs')

p='P(95)';
binom='binomial evaluation';
z=1;
    
while z==1
    %the following presents a figure containing the problematic part
    %numbers and associated RPN values.
    [testfout]=testf_final(p, binom);
    if testfout==1
        fprintf('\t\t...95th RPN breakpoint part numbers and RPN scores:\n')
        [sol,partn,RPNv]=RPNtable_final(b95);
        
    else
        fprintf('\t\t...Binom. dist. breakpoint part numbers and RPN scores:\n')
        [sol,partn,RPNv]=RPNtable_final(bdist);
    end
    
    figure(3)
    set(gcf,'Position',[100 100 272 532])
    tbl=table(partn,RPNv);
    TString=evalc('disp(tbl)');
    TString = strrep(TString,'<strong>','\bf');
    TString = strrep(TString,'</strong>','\rm');
    TString = strrep(TString,'_','\_');
    annotation(gcf,'Textbox','String',TString,'Interpreter','tex',...
        'Position',[0 0 1 1]);
    
    %gives the option to look at the other descriptive stat method
    addtl='Other evaluation method';
    nope='done';
    [testfout]=testf_final(addtl,nope);
    
    if testfout==1
        close(3)
        
    else
    end
    z=testfout;
end

%some users only want to know the problem parts and don't look further
%under the hood. For those users, you can end the program here.
stpnow_yes='End program now';
stpnow_no='continue';
[testfout]=testf_final(stpnow_yes,stpnow_no);
stpnow=testfout;

%if the program will end, users have the option to save dbrick and the
%problem part number/RPN values into two .txt files.
if stpnow==1
    savenow='Save data to .txt file? Yes';
    savenow_no='No';
    [testfout]=testf_final(savenow,savenow_no);
    if testfout==1
        writematrix(sol,'RPNBreakpoint_basic.txt');
        writematrix(dbrick,'all_parts_and_values.txt');
    else
    end
    
    %if users wish to evaluate the other descriptive stats, this closes any
    %open figures so that they will not print on top of each other.
    for i=1:3   
        a=ishandle(i);
        if a==1
            close(i)
        else
        end
    end
    
    return
else
end

%here medians and boxplots are used to individually evaluate specific
%problematic parts (because means are assumed to be too skewed).

probfail=median(dbrick(:,2));
probdetec=median(dbrick(:,3));
sev=median(dbrick(:,4));

%evaluating specific part numbers to determine underlying causes for high
%RPN values. Lines 260-272 are just trying to get a valid part number.
lmt=1;
while lmt==1
    trash=sprintf('\t\t...Enter a part number for evaluation.\n\t\t\t');
    speceval=input(trash);
    loop=1;
    while loop==1
        try
            dbrick(speceval,1)
            loop=2;
        catch
            fprintf('\t\t...Value does not match part number.\n');
            trash=sprintf('\t\t...Enter a part number for evaluation.\n\t\t\t');
            speceval=input(trash);
        end
    end
    
    %identifying and printing the parameters for the specified part number.
    pnprobfail=round(dbrick(speceval,2),3);
    pnprobdetec=round(dbrick(speceval,3),3);
    pnsev=round(dbrick(speceval,4),3);
    
    fprintf('\t\t...Median P(failure) is %f; part %f failure is %f.\n',probfail,speceval,pnprobfail)
    fprintf('\t\t...Median P(~detection) is %f; part %f P(~detection) is %f.\n',probdetec,speceval,pnprobdetec)
    fprintf('\t\t...Median severity is %f; part %f severity is %f.\n',sev,speceval,pnsev)
    
    %this part sucked. super useful, but it could def be improved upon.
    figure(4)
    set(gcf,'Position',[357 345 560 420])
    boxplot(dbrick(:,2))
    figstr1={'\leftarrow' num2str(pnprobfail)};
    text(1,pnprobfail,figstr1)
    title(['Part ', num2str(speceval), ' P(failure): ', num2str(pnprobfail)])
    
    figure(5)
    set(gcf,'Position',[438 292 560 420])
    boxplot(dbrick(:,3))
    figstr2={'\leftarrow' num2str(pnprobdetec)};
    text(1,pnprobdetec,figstr2)
    title(['Part ', num2str(speceval), ' P(~detection): ', num2str(pnprobdetec)])
    
    figure(6)
    set(gcf,'Position',[519 239 560 420])
    boxplot(dbrick(:,4))
    figstr3={'\leftarrow' num2str(pnsev)};
    text(1,pnsev,figstr3)
    title(['Part ', num2str(speceval), ' Severity: ', num2str(pnsev)])
    
    %users need to be able to evaluate more than one part number, so...
    moreparts='Evaluate more part numbers? Yes';
    nomoreparts='No';
    [testfout]=testf_final(moreparts,nomoreparts);
    
    if testfout==1
        for i=4:6   %closing figures so that they can be rerun w/o error
            a=ishandle(i);
            if a==1
                close(i)
            else
            end
        end
    else
        %if evaluation is completed, users can save the data as .txt files.
        savenow='Save data to .txt files? Yes';
        savenow_no='No';
        [testfout]=testf_final(savenow,savenow_no);
        if testfout==1
            writematrix(sol,'RPNBreakpoint_basic.txt');
            writematrix(dbrick,'all_parts_and_values.txt');
        else
        end
        lmt=2;
        %closing all the figures.
        for i=1:6
            a=ishandle(i);
            if a==1
                close(i)
            else
            end
        end
    end
end
