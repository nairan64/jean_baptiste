clear all; close all;

%ELEGIR MODO DE ENTRADA
prompt='Este programa permite identificar la nota que est� sonando en un instrumento. Hay dos opciones: grabar el sonido directamente (a tiempo real) con una interfaz, o introducir una muestra en formato .wav. �Cu�l eliges?';
button1=[];
while isempty(button1) 
    % Esto obliga a user a introducir una respuesta. Si no estuviera puesto as� el programa dar�a error
    % al cerrar la ventana emergente
button1= questdlg(prompt,'Elegir modo de entrada','Interfaz','Muestra.wav','Muestra.wav'); 
end


switch button1


%MODO INTERFAZ
    case 'Interfaz'
fs=44100;%Hz %Definir frecuencia de muestreo de la tarjeta de sonido
signal=audiorecorder(fs,16,1,3); %Los par�metros dependen de la tarjeta de sonido
%audiorecorder(fs/n�mero de bits/canal/ID de la tarjeta de sonido)

button2=[];
while isempty(button2) 
    prompt1='Cuando est�s preparada pulsa OK';
    % Esto obliga a user a introducir una respuesta. De nuevo, si no estuviera puesto as� el programa dar�a error
    % al cerrar la ventana emergente
button2= questdlg(prompt1,'Ready','OK','OK'); 
end

h=msgbox('Toca una nota');
pause(2)
close(h)
h=msgbox('Grabando...');

tlim=3;
recordblocking(signal,tlim) %Graba una muestra de 3 segundos y la guarda en 'signal.wav'
file='signal.wav';
y=getaudiodata(signal);
close(h)
%Crea un archivo de sonido con la grabaci�n
audiowrite(file,getaudiodata(signal),fs); 
info=audioinfo(file); 
L=info.TotalSamples;

%Si se quiere analizar solo una parte de la grabaci�n, se establece la
%cantidad de samples (L) de esta manera: Lo �nico que hay que cambiar es el
%plot ya que en la representaci�n gr�fica Matlab necesita que haya igual
%n�mero de elementos en x y en y.
% samples = [1,L];
% [Y, FS]=audioread(file,samples); 
    


%MODO MUESTRA
    case 'Muestra.wav'
prompt='Introduce tu muestra o elige una de la biblioteca'    ;   
button2=[];
while isempty(button2) 
    % Esto obliga a user a introducir una respuesta. Si no estuviera puesto as� el programa dar�a error
    % al cerrar la ventana emergente
button2= questdlg(prompt,'Muestra','Introducir mi muestra','Biblioteca','Introducir mi muestra'); 
end
switch button2
    
    
    case'Introducir mi muestra'
        %Abre un cuadro de texto emergente donde poner el nombre de el
        %archivo. El archivo debe estar en el mismo path que el programa.
        %Si no se introduce nada o se cierra la ventana elige un archivo
        %por defecto.
file=[];
prompt='Introduce el nombre del archivo. Si no introduces nada se proceder� con una muestra de ejemplo. Aseg�rate de que el archivo se encuentra en el mismo path que este script.';
default={'mtgcello-c4.wav'};
file= char(inputdlg(prompt,'Muestra.wav',[1 40],default));

if isempty(file)
file='mtgcello-c4.wav';  
end

    case 'Biblioteca'
        %Permite elegir una muestra de un conjunto f�cilmente
    ok=0;
    while ok==0 %Esto obliga a seleccionar un objeto de la lista
    [select,ok] = listdlg('Name','Biblioteca','ListString',...
        string({'Cello','Piano','Guitarra espa�ola','Viol�n','Saxo','Tono puro'}),...
        'SelectionMode','single','ListSize',[150 150],'PromptString','Elige una muestra:');
    end
if select ==1 %'Cello'
        file='mtgcello-c4.wav';
elseif select ==2 %Piano
        file='piano-a.wav';
elseif select ==3 %'Guitarra espa�ola'
        file='nylon-guitar__clean-e1st-harm.wav';
elseif select ==4 %'Viol�n'
        file='mtg__violin-d5.wav';
elseif select ==5 %'Saxo'
        file='mtg__sax-alto-e3.wav';
elseif select==6 %'Tono puro'
        file='puretone200hz-16k-wav.wav';
        
end %select

end %biblioteca o archivo propio


%leer la informaci�n del archivo de audio para poder aplicarle la fft
info=audioinfo(file);
L=info.TotalSamples;
samples = [1,L];
[y,fs]=audioread(file,samples);



%MatlabR2016b tiene un bug con la funci�n play que se arregla descargando este
%paquete https://www.mathworks.com/support/bugreports/1445234 . Esta parte
%del programa simplemente reproduce el archivo de sonido introducido por
%user, as� que si no quieres descargarlo el programa funciona con la funci�n mala as�:
%p=audioplayer(y(1:0.99*end),fs);
p=audioplayer(y,fs);
play(p);
tlim=info.Duration;

end %switch modo de entrada

    
    
    
%FFT
yy=abs(fft(y));
yynorm=yy/max(yy);

% Buscar los arm�nicos
maximos=(yynorm>0.3).*yynorm;
%Este par�metro es importante pues determina qu� entendemos por primer
%arm�nico. Probablemente dependa de los formants y por lo tanto de las
%caracter�sticas f�sicas y geom�tricas del instrumento. Este par�metro
%funciona para todos los instrumentos que he probado, pero no tendr�a por
%qu� hacerlo en otros.

%Se toman la mitad de las frecuencias porque la fft 'repite' las
%frecuencias al estar trabajando en n�meros reales
f=fs*(0:(L/2))/L; 


arm=find(maximos);
for i=1:length(arm)/2
     ff(i)=f(arm(i));
end


%Comparar la precuencia del arm�nico fundamental con una tabla de
%frecuencias/notas
load 'nota.mat'
load 'frecHz.mat'

eps=[4 7 15]; %Par�metro de tolerancia. Ajustado 'a mano'
%Cuanto mayores son las frecuencias, mayor es el espaciado entre notas
%seguidas y es por eso que hace falta ampliar el par�metro de tolerancia.

if ff(1)<=600
no=nota(find(abs(ff(1)-frecHz)<=eps(1)));
elseif ff(1)>=600 && ff(1)<=1030
no=nota(find(abs(ff(1)-frecHz)<=eps(2)));
else
no=nota(find(abs(ff(1)-frecHz)<=eps(3)));
end
if isempty(no)
form1=string('No ha sido posible reconocer la nota. La frecuencia del arm�nico fundamental es %d Hz');
%Para el caso de tonos puros, su frecuencia no tiene por qu� poder
%identificarse con una nota. En este caso el programa dice la frecuencia
%fundamental.
ss=char(sprintf (form1,ff(1)));
NO=[num2str(ff(1)),' Hz'];
else
form1=string('La nota es %s');
NO=string(no(1));
ss=char(sprintf (form1,NO));
end
msgbox(ss)



% Representaci�n gr�fica arm�nicos 
%Transformada de Fourier para toda la muestra
figure(1)
subplot(2,1,1)
plot(f,yynorm(1:length(f)))
ax=gca;
xlabel 'f (Hz)'
ylabel 'Amplitud relativa'
ax.XLim=[0 6*ff(1)]; 
ax.XTick=0:round(ff(1),1,'significant'):round(6*ff(1),1,'significant');
grid on
form2=string('FFT para %s (muestra completa)');
title ([sprintf(form2,NO)])


%Transformada de Fourier en el tiempo. Consiste en dividir los samples
%totales en particiones y hacer la fft en cada partici�n y despu�s
%representarlas en el tiempo en 3D
subplot(2,1,2)
%Numero de elementos: ajuste del n�mero de puntos del gr�fico
if ff(1)<300
N=ff(1)/5; 
else
N=ff(1)/10;
end
%Particiones: deben de ser n�meros enteros pues luego se utilizar�n como
%�ndices para el vector y
mesh=colon(1,round(length(y)/(2*N)),length(y)/2); 

%fft de cada partici�n
for ii=2:length(mesh)
     c(ii,:)=abs(fft(y(mesh(ii-1):mesh(ii))));
end

%Normalizaci�n respecto a la amplitud mayor de todas las particiones
for ii=1:length(mesh)
 cnorm(ii,:)=c(ii,:)/max(max(c));
end

%Se toman solo la mitad de los datos por estar en variable real
cnormp(:,:)=cnorm(:,1:floor(end/2));


[mm,nn]=size(cnormp);
tt=linspace(0,tlim,length(mesh));
fp=f(1:round(length(f)/nn):end);
h=surf(fp(1:min(nn,length(fp))),tt,cnormp(:,1:min(nn,length(fp))));
c=h.CData;
h.FaceColor= 'texturemap';
ax=gca;
ax.XLim=[0,6*ff(1)];
ax.YLim=[0, tlim];
ax.ZLim=[0,1];
ax.XTick=0:round(ff(1),1,'significant'):round(6*ff(1),1,'significant');
xlabel 'f (Hz)'
ylabel 't (s)'
zlabel 'Amplitud relativa'
form3=string('FFT(t) para %s');
title ([sprintf(form3,NO)])


%RECONSTRUCCI�N DE LA ONDA
button = questdlg('Ahora procederemos a reconstruir el sonido con la inversa de la FFT. Podemos introducir cualquier funci�n (p.ej. una gaussiana) para cambiar las amplitudes relativas de los arm�nicos y ver c�mo cambia el sonido de la onda reconstruida por la inversa de la transformada de Fourier.Estos son algunos ejemplos. Elige el que quieras escuchar:', ...
                            'Backwards',...
                            'Muestra entera','Desde el segundo arm�nico','Gaussiana','Muestra entera');
switch button
    
    case 'Muestra entera' %Reconstruye la muestra sin editar los datos
Y1=ifft(yy);
p1=audioplayer(y1,fs);
play(p1)

    case 'Desde el segundo arm�nico'
%Busca el arm�nico tal que la distancia entre los picos sea mayor o igual
%que la frecuencia fundamental. Dado que al sacar los picos de la fft salen
%frecuencias muy poco espaciadas (de un par de hercios) que corresponden al
%mismo pico, busca el siguiente pico.
if length(ff)==1
    msgbox('No ha sido posible detectar un segundo arm�nico en la muestra') %caso tonos puros
else
for ii=2:length(arm)
    aa(ii)=arm(ii)-arm(ii-1);
   end  
   eps=100;
y2=yy(find(abs(aa-arm(1))<=eps):end);
if isempty(y2)
     msgbox('No ha sido posible detectar un segundo arm�nico en la muestra') %caso muestras reales con arm�nicos demasiado d�biles
else
Y2=ifft(y2);
p2=audioplayer(Y2,fs);
play(p2)
end
end
    case 'Gaussiana'
y3=max(yy)*gaussmf(yy, [std(yy), mean(yy)]);
Y3=ifft(y3);
p3=audioplayer(Y3,fs);
play(p3)

end % switch

%Teresa Pelinski Ramos
