function getBestDialog(filterType)
if ~exist(strcat(filterType,'Mat','.mat'),'file')
    imgRestore = im2double(imread('temp.jpg'));
    Ori = im2double(imread('vcnn/applications/filterRestore/images/lena.jpg'));
    maxPSNR = 0;
    tempRestore = double(zeros(size(Ori)));
    index = {};
    for i = 0.8:0.05:1.3
        for j = 0.8:0.05:1.3
            for k = 0.8:0.05:1.3
                tempRestore(:,:,1) = imgRestore(:,:,1).*i;
                tempRestore(:,:,2) = imgRestore(:,:,2).*j;
                tempRestore(:,:,3) = imgRestore(:,:,3).*k;
                psnr = csnr(255*Ori,255*tempRestore,0,0);
                if maxPSNR < psnr
                    maxPSNR = psnr;
                    index.i = i;
                    index.j = j;
                    index.k = k;
                    fprintf('%g,%g,%g\n',i,j,k);
                end
            end
        end
    end
%      for i = 1.4:0.2:1.9
%         for j = 1.4:0.2:1.9
%             for k = 1.4:0.2:1.9
%                 tempRestore(:,:,1) = imgRestore(:,:,1).*i;
%                 tempRestore(:,:,2) = imgRestore(:,:,2).*j;
%                 tempRestore(:,:,3) = imgRestore(:,:,3).*k;
%                 psnr = csnr(255*Ori,255*tempRestore,0,0);
%                 if maxPSNR < psnr
%                     maxPSNR = psnr;
%                     index.i = i;
%                     index.j = j;
%                     index.k = k;
%                     fprintf('%g,%g,%g\n',i,j,k);
%                 end
%             end
%         end
%     end
    save(strcat(filterType,'Mat'),'index');
else
    % do nothing
end
