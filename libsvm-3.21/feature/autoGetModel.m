close all;

epoc = 100;
filtersList = {'ll'}; 

fprintf('epoc:');
for index = 1:numel(filtersList)
    for i = 1:epoc
        close all;
        tic;
%        getModel2(filtersList{index},false);
        getModel3(filtersList{index},false);
        toc;
        j = mod(i,5);
        if j
            fprintf('%d\t',i);
        else
            fprintf('\n');
        end
    end
end
