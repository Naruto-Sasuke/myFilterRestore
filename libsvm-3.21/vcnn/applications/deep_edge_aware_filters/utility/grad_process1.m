function [f,ff] =  grad_process1( S ,v, h,beta,index)
%UNTITLED5 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
%SΪ�����ԭͼ
%vΪ��������ĺ����֣�hΪ���������������
%betaΪƽ�����
f=S;
 [N,M,D] = size(S);
I=zeros(N,M);J=I;
for k=1:N
    J(k,:)=(0:(M-1));
end
for k=1:M
    I(:,k)=(0:(N-1));
end
Dh_FFT=1-exp(-1i*2*pi*J/M);
Dv_FFT=1-exp(-1i*2*pi*I/N);
Denormin2=conj(Dh_FFT).*Dh_FFT+conj(Dv_FFT).*Dv_FFT;
if D>1
    Denormin2 = repmat(Denormin2,[1,1,D]);
end
Normin1 = fft2(f);
%%
miu=0.25;%��ֵҪ����
delta=4*miu;
delta_max=1e10;
iter=0;
eps=1e-5;
%% initilation
dx=[S(:,1,:) - S(:,end,:),diff(S,1,2)];
dy=[S(1,:,:) - S(end,:,:);diff(S,1,1)];
n=numel(f);
ff=zeros(200,1);
while  delta<delta_max
%  while iter<201%����������ֹͣ����
     
     %%S-subproblem
     pre=S;
      iter=iter+1;
    Denormin=1+delta*Denormin2;
    tmp= [ -diff(dx,1,2), dx(:,end,:)-dx(:,1,:)]+[ -diff(dy,1,1); dy(end,:,:)-dy(1,:,:)];
    Normin =Normin1+delta*fft2(tmp);
    S = real(ifft2(Normin./Denormin));
    %figure,imshow(S);
    post=S;
    c=imabsdiff(pre,post);
    c=c.^2;
    ff(iter)=sqrt(sum(c(:))/n);
      
    %%d-subproblem
%    dxp=dx;dyp=dy;
    dxp=dx;
    dyp=dy;
    DhS=[S(:,1,:) - S(:,end,:),diff(S,1,2)];
    DvS=[S(1,:,:) - S(end,:,:);diff(S,1,1)];
%    dx=solve_Lp( DhX, miu/delta, p );
%    dy=solve_Lp( DvX, miu/delta, p );
    dx=1/(2*beta+delta)*(2*beta*h+delta*DhS);
    dy=1/(2*beta+delta)*(2*beta*v+delta*DvS);

    h=dx;
    v=dy;
    
   %% check the stopping criterion
    dxd=dxp-dx;
    dyd=dyp-dy;
    
    normdx=norm(dxd(:));
    normdy=norm(dyd(:));
%         disp(normdx/norm(dxp(:)));
%         disp(normdx/norm(dyp(:)));  
    if normdx/norm(dxp(:))+ normdy/norm(dyp(:))<=4*eps
        break;
    end
%     
    
    %% update delta 
    if (normdx+normdy)*delta/(norm(DhS(:))+norm(DvS(:)))<10
        rao=2.9;
    else
        rao=2;
    end
    delta=rao*delta;
end
 f=S;
[m,n,ch] = size(f);
imgRestore = zeros(m,n,ch);
imgRestore(:,:,1) = f(:,:,1).*index.i;
imgRestore(:,:,2) = f(:,:,2).*index.i;
imgRestore(:,:,3) = f(:,:,3).*index.i;
f = imgRestore;




