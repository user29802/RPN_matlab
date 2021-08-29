function [dbrick]=databrick_final(rows)
%This function generates the number values, left to right, for part number,
%p(failure), p(~detection), andseverity. It also generates RPN values for
%each part number based on the three other "measurements."

global dbrick

r=(.0001:1/rows:.9999);
pfail=[];
for i=1:rows
    thing=rand(1,1);
    val=(thing*r(i)^2);
    pfail=[pfail val];
end

pfail=pfail';

r=(.01:1/rows:99);
sev=[];
for i=1:rows
    thing=rand(1,1);
    val=(thing*r(i)^2);
    sev=[sev val];
end

sev=sev';

pdet=[];
for i=1:rows
    thing=rand(1,1);
    pdet=[pdet thing];
end

pdet=pdet';

rpn=pfail.*sev.*pdet;

partno=1:1:rows;
partno=partno';

dbrick=[partno pfail pdet sev rpn];

end
