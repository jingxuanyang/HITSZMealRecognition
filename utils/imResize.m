% resize the images
clear all;
fromfolder='./HitMealDataset/';
tofolder='./HitMealDataset400x300/';
extend='.jpg';

for i=1:202
    str1=num2str(i,'%d');
    str2=strcat(fromfolder,str1);
    str4=strcat(tofolder,str1);
    read_name=strcat(str2,extend);
    write_name=strcat(str4,extend);
    a=imread(read_name);
    b=imresize(a,[300,400]);
    imwrite(b,write_name);
   
end