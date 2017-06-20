function [Izhen,PSNR,CompressionRatio]=IzhenYaSuo(frameI)
%%% ��ʼ����
%DCT �任
OriginalImage=double(frameI); % ͼ����������ת��
[am,an]=size(OriginalImage);% �õ�ͼ��Ĵ�С
ImageSub=OriginalImage-128;
fun1=@dct2;
TCM=blkproc(ImageSub,[8,8],fun1); % ʹ��dct2�������ж�άDCT�任���õ��任ϵ������TCM
%3.����
Q=[16 11 10 16 24 40 51 61
12 12 14 19 26 58 60 55
14 13 16 24 40 57 69 56
14 17 22 29 51 87 80 62
18 22 37 56 68 109 103 77
24 35 55 64 81 101 113 92
49 64 78 87 103 121 120 101
72 92 95 98 112 100 103 99];% ����������
TCM_Q=blkproc(TCM,[8,8],'round( x./P1)',Q);% ��ͼ������������õ��������TCM����TCM_Q��
%Z��ɨ��
TCM_Q_col=im2col(TCM_Q,[8,8],'distinct'); % ��ÿ��8*8 ���ݿ������ϵ���ų����������õ�64* ���ݿ�������С�ľ���TCM_Q_col��
Num_col=size(TCM_Q_col,2);% �õ�TCM_Q_col�������������ݿ�ĸ���Num_col�� 
order=[1 9 2 3 10 17 25 18 ...
11 4 5 12 19 26 33 41 ...
34 27 20 13 6 7 14 21 ...
28 35 42 49 57 50 43 36 ...
29 22 15 8 16 23 30 37 ...
44 51 58 59 52 45 38 31 ...
24 32 39 46 53 60 61 54 ...
47 40 48 55 62 63 56 64];
TCM_Q_colZ=TCM_Q_col(order,:);% ��z ��ɨ�跽ʽ�Ա任ϵ����������
%5.����
%5.1ֱ�����룬dcΪֱ��ϵ����dcdpcmΪֱ����ֵ�����
dc=zeros(Num_col,1);
dcdpcm=zeros(Num_col,1);
for j=1:Num_col
dc(j)=TCM_Q_colZ(1,j); % ��DC ϵ�����е�һ��ʸ����
end
dcdpcm(1)=dc(1);
for j=2:Num_col
dcdpcm(j)=dc(j)-dc(j-1); % ��DC ϵ����DPCM ����
end
dcdmax=max(dcdpcm); %���ֱ��
dcdmin=min(dcdpcm); %��Сֱ��
dch=histc(dcdpcm,[dcdmin:dcdmax]); %ͳ�Ƹ���ֵ��ֱ��ͼ
dcnum=length(dcdpcm);
dcp=dch/dcnum; %�������ֵ�ĸ���
dcsymbols=[dcdmin:dcdmax]; %ֱ������ֵ
[dcdict,dcavglen]=huffmandict(dcsymbols,dcp); %�����ֵ�dcdict������ƽ���볤
dcencoded=huffmanenco(dcdpcm,dcdict); % ��DC ϵ����DPCM ����Huffman ���룬�õ�ֱ������dcencoded

%5.2��������
% ������ACԪ���������зŵ�ac��,ÿһ�о���eob ��Ϊ����,����count������Ԫ�� 
eob=max(ImageSub(:))+1; % ����һ�����������
num=numel(TCM_Q_colZ)+size(TCM_Q_col,2);
ac=zeros(num,1);
count=0;
for j=1:Num_col
i=max(find(TCM_Q_colZ(:,j)));%find ����ΪѰ��yy �����з���Ԫ�ص�λ�ã�max ����Ϊȡ��������ֵ�����޷���Ԫ�ػ���Ϊ�գ�����empty
if isempty(i)
i=1;
end
p=count+1;
q=p+i-1;
if i==1
ac(q)=eob;
end
ac(p:q)=[TCM_Q_colZ(2:i,j);eob];
count=q;
end
ac((count+1):end)=[];% ɾ��ac�е�����Ԫ��
acmax=max(ac); %�����
acmin=min(ac); %��С����
ach=histc(ac,[acmin:acmax]); %ͳ�Ƹ���ֵ��ֱ��ͼ
acnum=length(ac);
acp=ach/acnum; %�������ֵ�ĸ���
acsymbols=[acmin:acmax]; %��������ֵ
[acdict,acavglen]=huffmandict(acsymbols,acp); %�����ֵ�dcdict������ƽ���볤
acencoded=huffmanenco(ac,acdict); % ��AC ϵ������Huffman���룬�õ���������acencoded


%����
dcdecoded=huffmandeco(dcencoded,dcdict); %ֱ��Huffman����
%����ֱ������ָ�ֱ��������������TCM_Q_colZ_Rec�ĵ�һ��
TCM_Q_colZ_Rec(1,1)=dcdecoded(1);
for i=2:Num_col
TCM_Q_colZ_Rec(1,i)=TCM_Q_colZ_Rec(1,i-1)+dcdecoded(i); % �����i��ֱ������������ֱ����������TCM_Q_colZ_Rec�ĵ�i�е�1�С�
end
acdecoded=huffmandeco(acencoded,acdict); %����Huffman����
%���ݽ�������ָ���������������TCM_Q_colZ_Rec�ĵ�2-64��
j=1; %j������¼�ڼ���
k=2; %k������¼�ڼ���
maxk=1;
count=0; %count������¼����������eob�ĸ�������count=63ʱ����һ��eob����Ϊ�������������롣
for i=1:size(acdecoded)
if acdecoded(i)==eob
TCM_Q_colZ_Rec(k:64,j)=0;
j=j+1;
k=2;
else
TCM_Q_colZ_Rec(k,j)=acdecoded(i);
k=k+1;
end
end
%��Z��ɨ��
order2=[
1 3 4 10 11 21 22 36 ...
2 5 9 12 20 23 35 37 ...
6 8 13 19 24 34 38 49 ...
7 14 18 25 33 39 48 50 ...
15 17 26 32 40 47 51 58 ...
16 27 31 41 46 52 57 59 ...
28 30 42 45 53 56 60 63 ...
29 43 44 54 55 61 62 64];
TCM_Q_col_Rec= TCM_Q_colZ_Rec(order2,:); %�÷�z ��ɨ�跽ʽ�Ա任ϵ����������
TCM_Q_Rec=col2im(TCM_Q_col_Rec,[8,8],[am,an],'distinct'); % ��TCM_Q_col_Rec��ÿ���������ų�8*8���ݿ飬�������Ϊͼ��size��
%������
TCM_Rec=blkproc(TCM_Q_Rec,[8,8],'round( x.*P1)',Q);
%��DCT�任
fun2=@idct2;
ImageSub_Rec=blkproc(TCM_Rec,[8,8],fun2);% ʹ��idct2�������ж�ά��DCT�任���õ�ImageSub_Rec
ReconImage=double(ImageSub_Rec)+128;
Izhen=uint8(ReconImage);

encoded_lenght=numel(dcencoded)+numel(acencoded); %���볤��
AverageBit=encoded_lenght/am/an; %�����������ʣ�ÿ��������ռ�ı�������
CompressionRatio=am*an*8/encoded_lenght; %����ѹ��������ԭͼ��С��ѹ����ı�ֵ��
e=double(Izhen)-double(frameI);
MSE=sqrt(sum(e(:).^2)/(an*am)); % ������ָ��������ֵ�������ֵ֮��ƽ��������ֵ����ΪMSE
PSNR=10*log(255*255/MSE)/log(10); %�����ֵ�����(dB)
end