clc;clear all;
fileName = 'cat_video.avi' ;    %traffic.avi  D:666.avi
obj = VideoReader(fileName);
numFrames = obj.NumberOfFrames;% ֡������
II=rgb2gray(read(obj,1));
[M,N]=size(II);
File=zeros(M,N,numFrames);
File(:,:,1)=II(:,:);
for oo=1:3
X=input('�����봰�ڴ�С:   ');
Z=input('�������������ڰ뾶��С:   ');
Y=input('����������I֡�ļ����');
%WWW=floor(numFrames/Z);
%MOBAN=ones(X,X)/(X^2);  
IZhenWeiZhi=1;
for k = 2:numFrames% ��ȡ����
     frame =rgb2gray(read(obj,k));
     frameI=rgb2gray(read(obj,IZhenWeiZhi));
     if   ~(mod(k,Y)) %��������Ԥ��
         if k+Y<numFrames
         IZhenWeiZhi=k+Y;
         else
            IZhenWeiZhi=k;
         end
         [Izhen,PSNR,CompressionRatio]=IzhenYaSuo(frameI);
         File(:,:,k)=Izhen(:,:); 
         ZPSNR(k)=PSNR;
         YASUOLV(k)=CompressionRatio;    
     else   
         FrameI=frameI;
         [Pzhen,QQQ]=PzhenGuJi(frame,FrameI,X,Z);
         YASUOLV(k)=QQQ;
       %Pzhen=conv2(double(Pzhen),double(MOBAN),'same');%%%%%%%%%%%%%%��ͨ%%%%%%%%%%%%%
       File(:,:,k)=Pzhen(:,:);
       A=rgb2gray(read(obj,k));
       PP=double(A)-double(Pzhen);
       MSE=sqrt(sum(PP(:).^2)/(M*N)); % ������ָ��������ֵ�������ֵ֮��ƽ��������ֵ����ΪMSE
       ZPSNR(k)=10*log(255*255/MSE)/log(10);   
     end;%������ƶ�Ԥ�����
 end;

 subplot(2,2,oo);
 X=1:numFrames;
 for i=1:numFrames
     Y(i)=ZPSNR(i);
 end;
 save File;
 YaSuoLv=sum(YASUOLV)/(numFrames-1);
plot(X,Y,'r');
xlabel('��ǰ֡��');
ylabel('��ֵ�����');
title({'��Ƶѹ����Ϊ��',YaSuoLv});
implay(uint8(File));
%implay('F:MK.avi');
end;